-- Funkce pro Edge Functions. Volat je smí jen service role (backend);
-- přihlášený uživatel ani anon k nim přístup nemají.

-- ---------------------------------------------------------------------------
-- Bóďa: rezervace dotazu v měsíčním limitu (atomicky, i při souběhu)
-- ---------------------------------------------------------------------------

-- Zvýší počet dotazů v období o 1, pokud je pod limitem.
-- Vrací allowed (zda se dotaz smí položit) a used (počet po rezervaci,
-- resp. aktuální počet, když limit je vyčerpaný).
create or replace function public.assistant_usage_reserve(
  p_user_id uuid,
  p_period text,
  p_limit integer
)
returns table (allowed boolean, used integer)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_count integer;
begin
  if p_limit > 0 then
    insert into public.assistant_usage as u (user_id, period, count)
    values (p_user_id, p_period, 1)
    on conflict (user_id, period) do update
      set count = u.count + 1,
          updated_at = now()
      where u.count < p_limit
    returning u.count into v_count;

    if v_count is not null then
      return query select true, v_count;
      return;
    end if;
  end if;

  select u.count into v_count
  from public.assistant_usage u
  where u.user_id = p_user_id and u.period = p_period;

  return query select false, coalesce(v_count, 0);
end;
$$;

-- Po dotazu: přičte náklad; při chybě poskytovatele (p_refund) vrátí
-- rezervovaný dotaz. Vrací aktuální počet dotazů v období.
create or replace function public.assistant_usage_settle(
  p_user_id uuid,
  p_period text,
  p_cost_usd numeric,
  p_refund boolean default false
)
returns integer
language sql
security definer
set search_path = ''
as $$
  update public.assistant_usage u
  set cost_usd = u.cost_usd + greatest(coalesce(p_cost_usd, 0), 0),
      count = greatest(u.count - case when p_refund then 1 else 0 end, 0),
      updated_at = now()
  where u.user_id = p_user_id and u.period = p_period
  returning u.count;
$$;

-- ---------------------------------------------------------------------------
-- Platby: zápis nároku z události RevenueCat (idempotentně)
-- ---------------------------------------------------------------------------

-- Výsledek: 'applied' | 'duplicate' (stejná událost už zpracovaná) |
-- 'stale' (starší než poslední zpracovaná) | 'unknown_user'.
create or replace function public.apply_entitlement_event(
  p_user_id uuid,
  p_plan text,
  p_valid_until timestamptz,
  p_source text,
  p_event_id text,
  p_event_at timestamptz
)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_current public.entitlements%rowtype;
begin
  if not exists (select 1 from auth.users u where u.id = p_user_id) then
    return 'unknown_user';
  end if;

  insert into public.entitlements (user_id, plan)
  values (p_user_id, 'free')
  on conflict (user_id) do nothing;

  select * into v_current
  from public.entitlements e
  where e.user_id = p_user_id
  for update;

  if p_event_id is not null and v_current.last_event_id = p_event_id then
    return 'duplicate';
  end if;
  if v_current.last_event_at is not null and p_event_at is not null
     and p_event_at < v_current.last_event_at then
    return 'stale';
  end if;

  update public.entitlements e
  set plan = p_plan,
      valid_until = p_valid_until,
      source = coalesce(p_source, e.source),
      last_event_id = p_event_id,
      last_event_at = coalesce(p_event_at, e.last_event_at),
      updated_at = now()
  where e.user_id = p_user_id;

  return 'applied';
end;
$$;

-- ---------------------------------------------------------------------------
-- Smazání účtu: předání vlastnictví zahrady jinému členovi (atomicky)
-- ---------------------------------------------------------------------------

create or replace function public.transfer_garden_ownership(
  p_garden_id uuid,
  p_from_user uuid,
  p_to_user uuid
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not exists (
    select 1 from public.garden_members m
    where m.garden_id = p_garden_id and m.user_id = p_to_user
  ) then
    raise exception 'new_owner_not_member';
  end if;

  update public.gardens g
  set owner_id = p_to_user,
      updated_at = greatest(now(), g.updated_at)
  where g.id = p_garden_id and g.owner_id = p_from_user;

  if not found then
    raise exception 'garden_not_owned';
  end if;

  update public.garden_members m
  set role = 'owner', updated_at = now()
  where m.garden_id = p_garden_id and m.user_id = p_to_user;

  delete from public.garden_members m
  where m.garden_id = p_garden_id and m.user_id = p_from_user;
end;
$$;

-- ---------------------------------------------------------------------------
-- Oprávnění
-- ---------------------------------------------------------------------------

revoke all on function public.assistant_usage_reserve(uuid, text, integer) from public, anon, authenticated;
revoke all on function public.assistant_usage_settle(uuid, text, numeric, boolean) from public, anon, authenticated;
revoke all on function public.apply_entitlement_event(uuid, text, timestamptz, text, text, timestamptz) from public, anon, authenticated;
revoke all on function public.transfer_garden_ownership(uuid, uuid, uuid) from public, anon, authenticated;

grant execute on function public.assistant_usage_reserve(uuid, text, integer) to service_role;
grant execute on function public.assistant_usage_settle(uuid, text, numeric, boolean) to service_role;
grant execute on function public.apply_entitlement_event(uuid, text, timestamptz, text, text, timestamptz) to service_role;
grant execute on function public.transfer_garden_ownership(uuid, uuid, uuid) to service_role;
