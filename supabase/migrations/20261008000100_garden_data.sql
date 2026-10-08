-- Data zahrady (spec 8.1): zóny, deník, fotky, úkoly, sklad, nákupní
-- seznam a asistent Bóďa. Sloupce odpovídají lokální Drift databázi.
--
-- Cizí klíče mezi daty zahrady jsou složené (garden_id, <id>), takže řádek
-- nemůže odkazovat na zónu, úkol nebo položku skladu z jiné zahrady.
-- Odkazy, které mohou vzniknout v libovolném pořadí na různých
-- zařízeních, jsou DEFERRABLE. Fyzické mazání dělá jen backend (kaskádou
-- při smazání zahrady); aplikace maže měkce přes deleted_at.

-- ---------------------------------------------------------------------------
-- zones
-- ---------------------------------------------------------------------------

create table public.zones (
  id uuid primary key,
  garden_id uuid not null references public.gardens (id) on delete cascade,
  name text not null check (char_length(name) between 1 and 200),
  type text not null default 'other' check (type in (
    'vegetable', 'herbs', 'fruit', 'ornamental', 'lawn', 'greenhouse',
    'pond', 'structure', 'other')),
  area_m2 numeric check (area_m2 > 0),
  soil_texture text check (soil_texture in ('sandy', 'loamy', 'clay', 'unknown')),
  ph numeric check (ph between 0 and 14),
  ph_measured_at date,
  sun_exposure text check (sun_exposure in ('fullSun', 'partShade', 'shade')),
  irrigation text check (irrigation in ('none', 'manual', 'drip', 'sprinkler')),
  covered boolean not null default false,
  archived boolean not null default false,
  sort_order integer,
  polygon jsonb,
  layer text check (layer in ('reality', 'plan')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_updated_at timestamptz not null default clock_timestamp(),
  unique (garden_id, id)
);

-- ---------------------------------------------------------------------------
-- inventory_items (sklad)
-- ---------------------------------------------------------------------------

create table public.inventory_items (
  id uuid primary key,
  garden_id uuid not null references public.gardens (id) on delete cascade,
  category text not null check (category in (
    'seed', 'fertilizer', 'plantProtection', 'tool', 'other')),
  name text not null check (char_length(name) between 1 and 200),
  unit text not null check (unit in ('g', 'kg', 'ml', 'l', 'ks', 'pack')),
  stock_qty numeric not null default 0,
  low_stock_threshold numeric check (low_stock_threshold >= 0),
  -- seed { species, variety, lot, bestBefore }
  -- fertilizer { n, p, k, form }
  -- plantProtection { activeSubstance, authorizationNo, phiDays, nonProfessional }
  -- tool { condition, serviceIntervalDays, lastServiceAt }
  details jsonb not null default '{}'::jsonb check (jsonb_typeof(details) = 'object'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_updated_at timestamptz not null default clock_timestamp(),
  unique (garden_id, id),
  -- Přípravky na ochranu rostlin musí mít údaje z etikety (spec 8.1, D14).
  constraint inventory_items_plant_protection_details check (
    category <> 'plantProtection'
    or details ?& array['activeSubstance', 'authorizationNo', 'phiDays', 'nonProfessional']
  )
);

-- ---------------------------------------------------------------------------
-- tasks
-- ---------------------------------------------------------------------------

create table public.tasks (
  id uuid primary key,
  garden_id uuid not null references public.gardens (id) on delete cascade,
  title text not null check (char_length(title) between 1 and 500),
  zone_id uuid,
  due date not null,
  -- čas připomínky v den termínu, minuty od půlnoci (místní čas)
  remind_at integer check (remind_at between 0 and 1439),
  rrule text,
  snoozed_until date,
  status text not null default 'open' check (status in ('open', 'done', 'skipped')),
  notes text,
  duration_est_min integer check (duration_est_min > 0),
  tools text[],
  completed_at timestamptz,
  completed_activity_id uuid,
  -- incidents jsou až ve V2, cizí klíč přibude s tabulkou
  incident_id uuid,
  source text not null default 'user' check (source in ('user', 'boda', 'weather')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_updated_at timestamptz not null default clock_timestamp(),
  unique (garden_id, id),
  foreign key (garden_id, zone_id) references public.zones (garden_id, id)
    deferrable initially deferred
);

-- ---------------------------------------------------------------------------
-- activities (deník)
-- ---------------------------------------------------------------------------

create table public.activities (
  id uuid primary key,
  garden_id uuid not null references public.gardens (id) on delete cascade,
  zone_id uuid not null,
  type text not null check (type in (
    'sowing', 'planting', 'watering', 'fertilizing', 'spraying', 'pruning',
    'harvest', 'weeding', 'mowing', 'other')),
  title text not null check (char_length(title) between 1 and 500),
  occurred_at timestamptz not null,
  -- posun časové zóny v době činnosti, např. '+02:00' (spec 7.3)
  occurred_tz text not null check (occurred_tz ~ '^[+-][0-9]{2}:[0-9]{2}$'),
  notes text,
  harvest_qty numeric check (harvest_qty >= 0),
  harvest_unit text,
  cost_czk numeric check (cost_czk >= 0),
  task_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_updated_at timestamptz not null default clock_timestamp(),
  unique (garden_id, id),
  foreign key (garden_id, zone_id) references public.zones (garden_id, id)
    deferrable initially deferred,
  foreign key (garden_id, task_id) references public.tasks (garden_id, id)
    deferrable initially deferred
);

alter table public.tasks
  add constraint tasks_completed_activity_fkey
  foreign key (garden_id, completed_activity_id) references public.activities (garden_id, id)
  deferrable initially deferred;

-- ---------------------------------------------------------------------------
-- activity_materials, task_materials (vazby na sklad)
-- ---------------------------------------------------------------------------

create table public.activity_materials (
  activity_id uuid not null,
  item_id uuid not null,
  garden_id uuid not null references public.gardens (id) on delete cascade,
  qty numeric not null check (qty >= 0),
  unit text not null check (unit in ('g', 'kg', 'ml', 'l', 'ks', 'pack')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_updated_at timestamptz not null default clock_timestamp(),
  primary key (activity_id, item_id),
  foreign key (garden_id, activity_id) references public.activities (garden_id, id)
    deferrable initially deferred,
  foreign key (garden_id, item_id) references public.inventory_items (garden_id, id)
    deferrable initially deferred
);

create table public.task_materials (
  task_id uuid not null,
  item_id uuid not null,
  garden_id uuid not null references public.gardens (id) on delete cascade,
  qty numeric not null check (qty >= 0),
  unit text not null check (unit in ('g', 'kg', 'ml', 'l', 'ks', 'pack')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_updated_at timestamptz not null default clock_timestamp(),
  primary key (task_id, item_id),
  foreign key (garden_id, task_id) references public.tasks (garden_id, id)
    deferrable initially deferred,
  foreign key (garden_id, item_id) references public.inventory_items (garden_id, id)
    deferrable initially deferred
);

-- ---------------------------------------------------------------------------
-- photos (metadata; soubory jsou v bucketu photos)
-- ---------------------------------------------------------------------------

create table public.photos (
  id uuid primary key,
  garden_id uuid not null references public.gardens (id) on delete cascade,
  activity_id uuid,
  -- incidents jsou až ve V2, cizí klíč přibude s tabulkou
  incident_id uuid,
  -- '<gardenId>/<photoId>.jpg' a '<gardenId>/<photoId>_thumb.jpg'
  storage_path text not null,
  thumb_path text not null,
  width integer check (width > 0),
  height integer check (height > 0),
  taken_at timestamptz,
  position integer not null default 0 check (position >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_updated_at timestamptz not null default clock_timestamp(),
  unique (garden_id, id),
  foreign key (garden_id, activity_id) references public.activities (garden_id, id)
    deferrable initially deferred,
  constraint photos_storage_path_in_garden
    check (storage_path = garden_id::text || '/' || id::text || '.jpg'),
  constraint photos_thumb_path_in_garden
    check (thumb_path = garden_id::text || '/' || id::text || '_thumb.jpg')
);

-- ---------------------------------------------------------------------------
-- inventory_movements (V2: odpis ze skladu)
-- ---------------------------------------------------------------------------

create table public.inventory_movements (
  id uuid primary key,
  garden_id uuid not null references public.gardens (id) on delete cascade,
  item_id uuid not null,
  qty_delta numeric not null,
  reason text not null check (reason in ('purchase', 'task', 'manual', 'reversal')),
  task_id uuid,
  at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_updated_at timestamptz not null default clock_timestamp(),
  foreign key (garden_id, item_id) references public.inventory_items (garden_id, id)
    deferrable initially deferred,
  foreign key (garden_id, task_id) references public.tasks (garden_id, id)
    deferrable initially deferred
);

-- ---------------------------------------------------------------------------
-- shopping_items (nákupní seznam; plní ho uživatel, Bóďa a hlídač zásob)
-- ---------------------------------------------------------------------------

create table public.shopping_items (
  id uuid primary key,
  garden_id uuid not null references public.gardens (id) on delete cascade,
  name text not null check (char_length(name) between 1 and 200),
  qty numeric check (qty >= 0),
  unit text check (unit in ('g', 'kg', 'ml', 'l', 'ks', 'pack')),
  item_id uuid,
  done boolean not null default false,
  source text not null default 'user' check (source in ('user', 'boda', 'lowStock')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_updated_at timestamptz not null default clock_timestamp(),
  foreign key (garden_id, item_id) references public.inventory_items (garden_id, id)
    deferrable initially deferred
);

-- ---------------------------------------------------------------------------
-- assistant_threads, assistant_messages (Bóďa; patří uživateli, ne zahradě)
-- ---------------------------------------------------------------------------

create table public.assistant_threads (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  garden_id uuid references public.gardens (id) on delete set null,
  title text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_updated_at timestamptz not null default clock_timestamp(),
  unique (user_id, id)
);

create table public.assistant_messages (
  id uuid primary key,
  thread_id uuid not null,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  role text not null check (role in ('user', 'assistant')),
  text text not null,
  context_summary jsonb,
  feedback text check (feedback in ('up', 'down')),
  feedback_comment text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_updated_at timestamptz not null default clock_timestamp(),
  foreign key (user_id, thread_id) references public.assistant_threads (user_id, id)
    on delete cascade deferrable initially deferred
);

-- ---------------------------------------------------------------------------
-- Triggery synchronizace a indexy pro stahování změn
-- ---------------------------------------------------------------------------

do $$
declare
  t text;
begin
  foreach t in array array[
    'zones', 'inventory_items', 'tasks', 'activities', 'activity_materials',
    'task_materials', 'photos', 'inventory_movements', 'shopping_items'
  ] loop
    execute format(
      'create trigger a_sync_row before insert or update on public.%I
         for each row execute function private.sync_row(''garden_id'')', t);
  end loop;

  foreach t in array array['assistant_threads', 'assistant_messages'] loop
    execute format(
      'create trigger a_sync_row before insert or update on public.%I
         for each row execute function private.sync_row(''user_id'')', t);
  end loop;

  -- Stahování: garden_id = … and server_updated_at > … order by server_updated_at
  foreach t in array array[
    'zones', 'inventory_items', 'tasks', 'activities', 'activity_materials',
    'task_materials', 'photos', 'inventory_movements', 'shopping_items'
  ] loop
    execute format(
      'create index %I on public.%I (garden_id, server_updated_at)',
      t || '_garden_sync_idx', t);
  end loop;
end;
$$;

create index assistant_threads_user_sync_idx on public.assistant_threads (user_id, server_updated_at);
create index assistant_messages_user_sync_idx on public.assistant_messages (user_id, server_updated_at);
create index assistant_messages_thread_idx on public.assistant_messages (thread_id);
create index assistant_threads_garden_idx on public.assistant_threads (garden_id);
create index profiles_server_updated_at_idx on public.profiles (server_updated_at);

-- Indexy pro cizí klíče (rychlé kaskády a dotazy podle vazby)
create index activities_zone_idx on public.activities (garden_id, zone_id);
create index activities_task_idx on public.activities (garden_id, task_id) where task_id is not null;
create index tasks_zone_idx on public.tasks (garden_id, zone_id) where zone_id is not null;
create index tasks_completed_activity_idx on public.tasks (garden_id, completed_activity_id) where completed_activity_id is not null;
create index photos_activity_idx on public.photos (garden_id, activity_id) where activity_id is not null;
create index activity_materials_item_idx on public.activity_materials (garden_id, item_id);
create index task_materials_item_idx on public.task_materials (garden_id, item_id);
create index inventory_movements_item_idx on public.inventory_movements (garden_id, item_id);
create index shopping_items_item_idx on public.shopping_items (garden_id, item_id) where item_id is not null;
