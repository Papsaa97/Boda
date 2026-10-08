-- Synchronizace (spec 7.4): server_updated_at nastavuje server, starší
-- zápis (podle updated_at ze zařízení) se zahodí, stahování podle
-- server_updated_at funguje pod RLS.
begin;
create extension if not exists pgtap with schema extensions;
select plan(18);

insert into auth.users (id, email) values
  ('a0000000-0000-4000-8000-000000000001', 'owner@example.test');
insert into public.gardens (id, name, owner_id) values
  ('b0000000-0000-4000-8000-000000000001', 'Zahrada', 'a0000000-0000-4000-8000-000000000001');

create temp table t_mark (v timestamptz);
grant all on t_mark to authenticated;

set local role authenticated;
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}';

-- Klientská hodnota server_updated_at se ignoruje.
select lives_ok(
  $$insert into public.zones (id, garden_id, name, created_at, updated_at, server_updated_at)
    values ('c0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001',
            'Záhon', '2026-10-01T10:00:00Z', '2026-10-01T10:00:00Z', '2000-01-01T00:00:00Z')$$,
  'insert a zone (client sends a bogus server_updated_at)');
select ok(
  (select server_updated_at > '2001-01-01' from public.zones where id = 'c0000000-0000-4000-8000-000000000001'),
  'server_updated_at is set by the server on insert');

insert into t_mark
  select server_updated_at from public.zones where id = 'c0000000-0000-4000-8000-000000000001';

-- Starší zápis se zahodí.
select lives_ok(
  $$update public.zones set name = 'Starší', updated_at = '2026-09-30T10:00:00Z'
    where id = 'c0000000-0000-4000-8000-000000000001'$$,
  'older update statement runs');
select is(
  (select name from public.zones where id = 'c0000000-0000-4000-8000-000000000001'),
  'Záhon', 'older update is skipped (last write wins)');
select is(
  (select server_updated_at from public.zones where id = 'c0000000-0000-4000-8000-000000000001'),
  (select v from t_mark), 'skipped update does not touch server_updated_at');

-- Upsert (PostgREST on_conflict=id) se starším updated_at se taky zahodí.
select lives_ok(
  $$insert into public.zones (id, garden_id, name, updated_at)
    values ('c0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001',
            'Starší upsert', '2026-09-30T10:00:00Z')
    on conflict (id) do update set name = excluded.name, updated_at = excluded.updated_at$$,
  'older upsert statement runs');
select is(
  (select name from public.zones where id = 'c0000000-0000-4000-8000-000000000001'),
  'Záhon', 'older upsert is skipped');

-- Stejný čas = opakované odeslání téže změny, zapíše se.
select lives_ok(
  $$update public.zones set name = 'Stejný čas', updated_at = '2026-10-01T10:00:00Z'
    where id = 'c0000000-0000-4000-8000-000000000001'$$,
  'update with equal updated_at runs');
select is(
  (select name from public.zones where id = 'c0000000-0000-4000-8000-000000000001'),
  'Stejný čas', 'update with equal updated_at is applied');

-- Novější zápis projde a posune server_updated_at.
select lives_ok(
  $$insert into public.zones (id, garden_id, name, updated_at, deleted_at)
    values ('c0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001',
            'Novější', '2026-10-02T10:00:00Z', '2026-10-02T10:00:00Z')
    on conflict (id) do update
      set name = excluded.name, updated_at = excluded.updated_at, deleted_at = excluded.deleted_at$$,
  'newer upsert runs');
select is(
  (select name || '|' || (deleted_at is not null)::text from public.zones
   where id = 'c0000000-0000-4000-8000-000000000001'),
  'Novější|true', 'newer upsert is applied, including the soft delete');
select ok(
  (select server_updated_at > (select v from t_mark) from public.zones
   where id = 'c0000000-0000-4000-8000-000000000001'),
  'applied update moves server_updated_at forward');

-- Stejné chování na ostatních tabulkách (vzorek).
select lives_ok(
  $$insert into public.tasks (id, garden_id, title, due, updated_at)
    values ('e0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001',
            'Úkol', '2026-10-10', '2026-10-05T10:00:00Z')$$,
  'insert a task');
select lives_ok(
  $$update public.tasks set status = 'done', updated_at = '2026-10-04T10:00:00Z'
    where id = 'e0000000-0000-4000-8000-000000000001'$$,
  'older task update runs');
select is(
  (select status from public.tasks where id = 'e0000000-0000-4000-8000-000000000001'),
  'open', 'older task update is skipped');

-- Profil: LWW i u nastavení.
select lives_ok(
  $$update public.profiles set settings = '{"theme":"dark"}', updated_at = now() - interval '1 day'
    where id = auth.uid()$$,
  'older profile update runs');
select is(
  (select settings from public.profiles where id = auth.uid()),
  '{}'::jsonb, 'older profile update is skipped');

-- Stahování změn přes PostgREST: filtr + řazení + limit pod RLS.
select is(
  (select count(*)::int from (
     select id from public.zones
     where garden_id = 'b0000000-0000-4000-8000-000000000001'
       and server_updated_at > '2000-01-01T00:00:00Z'
     order by server_updated_at
     limit 500) q),
  1, 'pull query returns changed rows to a member');

select * from finish();
rollback;
