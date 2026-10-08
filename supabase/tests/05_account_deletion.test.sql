-- Smazání účtu (spec kap. 9): zahrada se smaže i s daty, účet s vlastní
-- zahradou smazat nejde (nejdřív předat nebo smazat zahradu), po smazání
-- účtu zmizí profil, nárok, počty dotazů i členství.
begin;
create extension if not exists pgtap with schema extensions;
select plan(8);

insert into auth.users (id, email) values
  ('a0000000-0000-4000-8000-000000000001', 'owner@example.test'),
  ('a0000000-0000-4000-8000-000000000002', 'editor@example.test');
insert into public.gardens (id, name, owner_id) values
  ('b0000000-0000-4000-8000-000000000001', 'Zahrada', 'a0000000-0000-4000-8000-000000000001');
insert into public.garden_members (garden_id, user_id, role) values
  ('b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000002', 'editor');
insert into public.zones (id, garden_id, name) values
  ('c0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'Záhon');
insert into public.tasks (id, garden_id, title, zone_id, due) values
  ('e0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'Úkol',
   'c0000000-0000-4000-8000-000000000001', '2026-10-10');
insert into public.activities (id, garden_id, zone_id, type, title, occurred_at, occurred_tz, task_id) values
  ('f0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001',
   'c0000000-0000-4000-8000-000000000001', 'other', 'Záznam', now(), '+02:00',
   'e0000000-0000-4000-8000-000000000001');
update public.tasks set completed_activity_id = 'f0000000-0000-4000-8000-000000000001'
  where id = 'e0000000-0000-4000-8000-000000000001';
insert into public.assistant_threads (id, user_id, garden_id) values
  ('73000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000002',
   'b0000000-0000-4000-8000-000000000001');
insert into public.assistant_usage (user_id, period, count) values
  ('a0000000-0000-4000-8000-000000000001', '2026-10', 1);

set constraints all immediate;

-- auth.users maže v produkci Auth Admin API; v testu přímo (role postgres).
select throws_ok(
  $$delete from auth.users where id = 'a0000000-0000-4000-8000-000000000001'$$,
  '23503', null, 'a user who still owns a garden cannot be deleted');

set local role service_role;
set local request.jwt.claims to '{"role":"service_role"}';

select lives_ok(
  $$delete from public.gardens where id = 'b0000000-0000-4000-8000-000000000001'$$,
  'service role deletes a garden with all its data');
select is((select count(*)::int from public.zones), 0, 'zones were deleted with the garden');
select is((select count(*)::int from public.activities), 0, 'activities were deleted with the garden');
select is((select count(*)::int from public.garden_members), 0, 'memberships were deleted with the garden');
select is(
  (select garden_id from public.assistant_threads where id = '73000000-0000-4000-8000-000000000001'),
  null::uuid, 'Bóďa thread of another member survives without the garden');

reset role;
select lives_ok(
  $$delete from auth.users where id = 'a0000000-0000-4000-8000-000000000001'$$,
  'user without gardens can be deleted');
select is(
  (select count(*)::int from public.profiles where id = 'a0000000-0000-4000-8000-000000000001')
  + (select count(*)::int from public.entitlements where user_id = 'a0000000-0000-4000-8000-000000000001')
  + (select count(*)::int from public.assistant_usage where user_id = 'a0000000-0000-4000-8000-000000000001'),
  0, 'profile, entitlement and usage rows are gone');

select * from finish();
rollback;
