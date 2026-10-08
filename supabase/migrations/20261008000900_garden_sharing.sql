-- Sdílení zahrady v rodině (V2, DECLOG D89).
--
-- Vlastník (s Premium) vytvoří pozvánku: kód z 8 znaků platný 7 dní, na
-- jedno použití. Kdo kód zadá, stane se členem s rolí editor. Pozvánky
-- se čtou a mění jen přes funkce níže; tabulka je pro klienta zavřená.

create table public.garden_invites (
  id uuid primary key default gen_random_uuid(),
  garden_id uuid not null references public.gardens (id) on delete cascade,
  code text not null unique check (code ~ '^[A-HJ-NP-Z2-9]{8}$'),
  role text not null default 'editor' check (role in ('editor', 'viewer')),
  created_by uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null,
  used_by uuid references auth.users (id) on delete set null,
  used_at timestamptz
);

create index garden_invites_garden_id_idx on public.garden_invites (garden_id);
create index garden_invites_created_by_idx on public.garden_invites (created_by);
create index garden_invites_used_by_idx on public.garden_invites (used_by);

alter table public.garden_invites enable row level security;
revoke all on table public.garden_invites from anon, authenticated;

-- Kód bez snadno zaměnitelných znaků (0/O, 1/I/L). Náhoda z
-- gen_random_uuid (kryptograficky silný generátor); 32 znaků = 5 bitů,
-- bajty 6 a 8 mají pevné bity verze, proto se nepoužijí.
create or replace function private.new_invite_code()
returns text
language sql
volatile
set search_path = ''
as $$
  select string_agg(
    substr('ABCDEFGHJKMNPQRSTUVWXYZ23456789A', (get_byte(b, i) % 32) + 1, 1),
    '' order by i
  )
  from (select uuid_send(gen_random_uuid()) as b) r,
       unnest(array[0, 1, 2, 3, 4, 5, 9, 10]) as i;
$$;

-- Pozvánka do zahrady. Jen vlastník a jen s Premium (kap. 11.2).
create or replace function public.create_garden_invite(p_garden_id uuid)
returns table (code text, expires_at timestamptz)
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_code text;
  v_expires timestamptz := now() + interval '7 days';
begin
  if not private.is_garden_member(p_garden_id, array['owner']) then
    raise exception 'not_owner' using errcode = '42501';
  end if;
  if not exists (
    select 1 from public.entitlements e
    where e.user_id = auth.uid()
      and e.plan = 'premium'
      and (e.valid_until is null or e.valid_until > now())
  ) then
    raise exception 'premium_required' using errcode = '42501';
  end if;
  loop
    v_code := private.new_invite_code();
    begin
      insert into public.garden_invites (garden_id, code, created_by, expires_at)
      values (p_garden_id, v_code, auth.uid(), v_expires);
      exit;
    exception when unique_violation then
      -- Kolize kódu je vzácná; zkusí se jiný.
    end;
  end loop;
  return query select v_code, v_expires;
end;
$$;

-- Přijetí pozvánky: člen s rolí z pozvánky. Kdo už členem je, zůstane
-- (pozvánka se nespotřebuje). Vrací id zahrady.
create or replace function public.accept_garden_invite(p_code text)
returns uuid
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_invite public.garden_invites%rowtype;
begin
  if auth.uid() is null then
    raise exception 'not_signed_in' using errcode = '42501';
  end if;
  select * into v_invite
  from public.garden_invites i
  where i.code = upper(regexp_replace(coalesce(p_code, ''), '[^A-Za-z0-9]', '', 'g'))
    and i.used_at is null
    and i.expires_at > now()
  for update;
  if not found then
    raise exception 'invalid_invite' using errcode = 'P0002';
  end if;
  if exists (
    select 1 from public.garden_members m
    where m.garden_id = v_invite.garden_id and m.user_id = auth.uid()
  ) then
    return v_invite.garden_id;
  end if;
  insert into public.garden_members (garden_id, user_id, role)
  values (v_invite.garden_id, auth.uid(), v_invite.role);
  update public.garden_invites
  set used_by = auth.uid(), used_at = now()
  where id = v_invite.id;
  return v_invite.garden_id;
end;
$$;

-- Členové zahrady se jménem a e-mailem (vidí je jen členové té zahrady).
create or replace function public.garden_member_list(p_garden_id uuid)
returns table (user_id uuid, role text, display_name text, email text, joined_at timestamptz)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not private.is_garden_member(p_garden_id) then
    raise exception 'not_member' using errcode = '42501';
  end if;
  return query
  select m.user_id, m.role, p.display_name, u.email::text, m.created_at
  from public.garden_members m
  join auth.users u on u.id = m.user_id
  left join public.profiles p on p.id = m.user_id
  where m.garden_id = p_garden_id
  order by (m.role = 'owner') desc, m.created_at;
end;
$$;

revoke all on function private.new_invite_code() from public, anon, authenticated;
revoke all on function public.create_garden_invite(uuid) from public, anon;
revoke all on function public.accept_garden_invite(text) from public, anon;
revoke all on function public.garden_member_list(uuid) from public, anon;
grant execute on function public.create_garden_invite(uuid) to authenticated;
grant execute on function public.accept_garden_invite(text) to authenticated;
grant execute on function public.garden_member_list(uuid) to authenticated;
