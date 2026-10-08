-- Zahradník Bóďa – jádro serverového schématu (spec kap. 7.4, 8.1, 11.2).
--
-- Konvence:
-- * snake_case, stejné názvy tabulek a sloupců jako lokální Drift databáze;
-- * číselníky jsou text + check (ne enum);
-- * synchronizované tabulky mají created_at, updated_at (čas změny na
--   zařízení), deleted_at (měkké mazání) a server_updated_at (nastavuje
--   server, podle něj se stahuje);
-- * pomocné funkce pro RLS a triggery jsou ve schématu private, které
--   PostgREST nevystavuje.

create schema if not exists private;
revoke all on schema private from public;
grant usage on schema private to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Obecné pomocné funkce
-- ---------------------------------------------------------------------------

-- Trigger pro všechny synchronizované tabulky (spec 7.4):
-- * vždy nastaví server_updated_at = clock_timestamp();
-- * při UPDATE zahodí zápis, který je starší než uložená verze
--   (NEW.updated_at < OLD.updated_at) => „poslední zápis vyhrává“ podle
--   času zařízení. Stejný čas se zapíše (idempotentní opakované odeslání);
-- * sloupce předané jako argumenty triggeru (garden_id, user_id) nejde
--   změnit: přesun řádku do jiné zahrady by obešel kontrolu členství.
create or replace function private.sync_row()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_new jsonb;
  v_old jsonb;
  v_col text;
begin
  if tg_op = 'UPDATE' then
    if new.updated_at < old.updated_at then
      return null;
    end if;
    if tg_nargs > 0 then
      v_new := to_jsonb(new);
      v_old := to_jsonb(old);
      foreach v_col in array tg_argv loop
        if (v_new -> v_col) is distinct from (v_old -> v_col) then
          raise exception 'column_immutable: %', v_col
            using errcode = '42501';
        end if;
      end loop;
    end if;
  end if;
  new.server_updated_at := clock_timestamp();
  return new;
end;
$$;

-- Jen razítko server_updated_at (pro tabulky, které nejdou přes outbox
-- zařízení, např. garden_members).
create or replace function private.touch_server_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.server_updated_at := clock_timestamp();
  return new;
end;
$$;

-- Bezpečný převod textu na uuid (null, když to uuid není).
create or replace function private.try_uuid(p_text text)
returns uuid
language sql
immutable
set search_path = ''
as $$
  select case
    when p_text ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
      then p_text::uuid
  end;
$$;

-- ---------------------------------------------------------------------------
-- profiles – 1 řádek na uživatele, id = auth.users.id
-- ---------------------------------------------------------------------------

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text check (display_name is null or char_length(display_name) <= 100),
  -- { quietHoursStart, quietHoursEnd, theme, digest }
  settings jsonb not null default '{}'::jsonb check (jsonb_typeof(settings) = 'object'),
  -- { analytics: {granted, at}, photoUpload: {granted, at},
  --   aiProcessing: {granted, at}, policyVersion }
  consents jsonb not null default '{}'::jsonb check (jsonb_typeof(consents) = 'object'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  server_updated_at timestamptz not null default clock_timestamp()
);

create trigger a_sync_row
  before insert or update on public.profiles
  for each row execute function private.sync_row();

-- ---------------------------------------------------------------------------
-- entitlements – nárok na Premium; zapisuje jen backend (service role)
-- ---------------------------------------------------------------------------

create table public.entitlements (
  user_id uuid primary key references auth.users (id) on delete cascade,
  plan text not null default 'free' check (plan in ('free', 'premium')),
  -- null = bez omezení (u premium), u free nemá význam
  valid_until timestamptz,
  source text check (source is null or source in ('play', 'appstore', 'promo')),
  -- poslední zpracovaná událost platební služby (idempotence a pořadí)
  last_event_id text,
  last_event_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Má uživatel teď platné Premium?
create or replace function private.is_premium(p_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.entitlements e
    where e.user_id = p_user_id
      and e.plan = 'premium'
      and (e.valid_until is null or e.valid_until > now())
  );
$$;

-- ---------------------------------------------------------------------------
-- assistant_usage – počet dotazů Bódi a náklady za kalendářní měsíc
-- ---------------------------------------------------------------------------

create table public.assistant_usage (
  user_id uuid not null references auth.users (id) on delete cascade,
  period text not null check (period ~ '^[0-9]{4}-(0[1-9]|1[0-2])$'),
  count integer not null default 0 check (count >= 0),
  cost_usd numeric(12, 6) not null default 0 check (cost_usd >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, period)
);

-- ---------------------------------------------------------------------------
-- gardens a garden_members
-- ---------------------------------------------------------------------------

create table public.gardens (
  id uuid primary key,
  name text not null check (char_length(name) between 1 and 200),
  owner_id uuid not null default auth.uid() references auth.users (id) on delete restrict,
  -- numeric(5,2) zaokrouhlí na 2 desetinná místa (~1 km, spec kap. 9)
  location_lat numeric(5, 2) check (location_lat between -90 and 90),
  location_lng numeric(5, 2) check (location_lng between -180 and 180),
  altitude_m numeric check (altitude_m between -500 and 9000),
  bounds jsonb,
  scale_meters_per_unit numeric check (scale_meters_per_unit > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_updated_at timestamptz not null default clock_timestamp()
);

create index gardens_server_updated_at_idx on public.gardens (server_updated_at);
create index gardens_owner_id_idx on public.gardens (owner_id);

create table public.garden_members (
  garden_id uuid not null references public.gardens (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  role text not null check (role in ('owner', 'editor', 'viewer')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  server_updated_at timestamptz not null default clock_timestamp(),
  primary key (garden_id, user_id)
);

create index garden_members_user_id_idx on public.garden_members (user_id, garden_id);
create index garden_members_garden_sync_idx on public.garden_members (garden_id, server_updated_at);

create trigger a_touch_server_updated_at
  before insert or update on public.garden_members
  for each row execute function private.touch_server_updated_at();

-- Je přihlášený uživatel členem zahrady (s některou z rolí)?
-- security definer: čte garden_members bez RLS, jinak by se pravidla
-- zacyklila.
create or replace function private.is_garden_member(
  p_garden_id uuid,
  p_roles text[] default array['owner', 'editor', 'viewer']
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.garden_members m
    where m.garden_id = p_garden_id
      and m.user_id = auth.uid()
      and m.role = any (p_roles)
  );
$$;

-- Zahrada podle první složky cesty v úložišti: '<gardenId>/<photoId>.jpg'.
create or replace function private.path_garden_id(p_name text)
returns uuid
language sql
immutable
set search_path = ''
as $$
  select private.try_uuid(split_part(p_name, '/', 1));
$$;

-- Limit zahrad: Free max. 1 vlastní (nesmazaná) zahrada, Premium neomezeně
-- (spec 11.2). Při upsertu existujícího řádku (INSERT … ON CONFLICT) se
-- limit nekontroluje, jde o aktualizaci. Obnovení smazané zahrady
-- (deleted_at -> null) se počítá jako nová zahrada.
create or replace function private.gardens_enforce_limit()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    if exists (select 1 from public.gardens g where g.id = new.id) then
      return new;
    end if;
  elsif not (old.deleted_at is not null and new.deleted_at is null) then
    return new;
  end if;

  if new.deleted_at is not null then
    return new;
  end if;

  perform pg_advisory_xact_lock(hashtextextended('gardens_limit:' || new.owner_id::text, 0));

  if not private.is_premium(new.owner_id)
     and exists (
       select 1 from public.gardens g
       where g.owner_id = new.owner_id
         and g.deleted_at is null
         and g.id <> new.id
     ) then
    raise exception 'garden_limit_reached'
      using errcode = 'P0001',
            hint = 'Free plan allows 1 garden; Premium is unlimited.';
  end if;
  return new;
end;
$$;

-- Vlastníka zahrady smí měnit jen backend (service role, předání
-- vlastnictví při smazání účtu). U běžného uživatele se změna tiše
-- zahodí, aby zastaralé zařízení nezablokovalo frontu změn.
create or replace function private.gardens_protect_owner()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.owner_id is distinct from old.owner_id
     and current_user in ('authenticated', 'anon') then
    new.owner_id := old.owner_id;
  end if;
  return new;
end;
$$;

-- Po založení zahrady se vlastník automaticky stane členem s rolí owner.
create or replace function private.gardens_add_owner_member()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.garden_members (garden_id, user_id, role)
  values (new.id, new.owner_id, 'owner')
  on conflict (garden_id, user_id) do update set role = 'owner', updated_at = now();
  return new;
end;
$$;

-- Pořadí BEFORE triggerů je abecední: nejdřív LWW (starší zápis se
-- zahodí), pak ochrana vlastníka, pak limit.
create trigger a_sync_row
  before insert or update on public.gardens
  for each row execute function private.sync_row();

create trigger b_protect_owner
  before update on public.gardens
  for each row execute function private.gardens_protect_owner();

create trigger c_enforce_limit
  before insert or update on public.gardens
  for each row execute function private.gardens_enforce_limit();

create trigger gardens_add_owner_member
  after insert on public.gardens
  for each row execute function private.gardens_add_owner_member();

-- ---------------------------------------------------------------------------
-- Nový uživatel => profil a nárok Free
-- ---------------------------------------------------------------------------

create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id) values (new.id)
  on conflict (id) do nothing;
  insert into public.entitlements (user_id, plan) values (new.id, 'free')
  on conflict (user_id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function private.handle_new_user();
