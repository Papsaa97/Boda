-- Zahrady a členství: automatické členství vlastníka, limit Free = 1
-- zahrada, správa členů jen vlastníkem, vlastníka mění jen backend.
begin;
create extension if not exists pgtap with schema extensions;
select plan(31);

insert into auth.users (id, email) values
  ('a0000000-0000-4000-8000-000000000001', 'owner@example.test'),
  ('a0000000-0000-4000-8000-000000000002', 'editor@example.test'),
  ('a0000000-0000-4000-8000-000000000003', 'viewer@example.test'),
  ('a0000000-0000-4000-8000-000000000004', 'stranger@example.test'),
  ('a0000000-0000-4000-8000-000000000005', 'premium@example.test');

update public.entitlements set plan = 'premium', valid_until = null, source = 'promo'
where user_id = 'a0000000-0000-4000-8000-000000000005';

-- ================================================================ owner
set local role authenticated;
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}';

select lives_ok(
  $$insert into public.gardens (id, name, location_lat, location_lng)
    values ('b0000000-0000-4000-8000-000000000001', 'Zahrada', 50.08812, 14.42076)$$,
  'free user creates the first garden');
select is(
  (select role from public.garden_members
   where garden_id = 'b0000000-0000-4000-8000-000000000001' and user_id = auth.uid()),
  'owner', 'owner membership is created automatically');
select is(
  (select owner_id from public.gardens where id = 'b0000000-0000-4000-8000-000000000001'),
  'a0000000-0000-4000-8000-000000000001'::uuid, 'owner_id defaults to the caller');
select is(
  (select location_lat::text || ',' || location_lng::text from public.gardens
   where id = 'b0000000-0000-4000-8000-000000000001'),
  '50.09,14.42', 'location is rounded to 2 decimals');
select throws_ok(
  $$insert into public.gardens (id, name) values ('b0000000-0000-4000-8000-000000000009', 'Druhá')$$,
  'P0001', 'garden_limit_reached', 'free user cannot own a second garden');
select lives_ok(
  $$insert into public.gardens (id, name, updated_at)
    values ('b0000000-0000-4000-8000-000000000001', 'Zahrada u chaty', now() + interval '1 minute')
    on conflict (id) do update set name = excluded.name, updated_at = excluded.updated_at$$,
  'upsert of the existing garden is not blocked by the limit');
select is(
  (select name from public.gardens where id = 'b0000000-0000-4000-8000-000000000001'),
  'Zahrada u chaty', 'upsert updated the garden');
select throws_ok(
  $$insert into public.gardens (id, name, owner_id)
    values ('b0000000-0000-4000-8000-000000000008', 'Cizí', 'a0000000-0000-4000-8000-000000000004')$$,
  '42501', null, 'cannot create a garden owned by someone else');

select lives_ok(
  $$insert into public.garden_members (garden_id, user_id, role) values
    ('b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000002', 'editor'),
    ('b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000003', 'viewer')$$,
  'owner adds an editor and a viewer');
select throws_ok(
  $$insert into public.garden_members (garden_id, user_id, role) values
    ('b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000004', 'owner')$$,
  '42501', null, 'owner cannot add a second owner');
select is((select count(*)::int from public.garden_members), 3, 'owner sees all members');

-- ================================================================ editor
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}';

select is((select count(*)::int from public.gardens), 1, 'editor sees the shared garden');
select throws_ok(
  $$insert into public.garden_members (garden_id, user_id, role) values
    ('b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000004', 'viewer')$$,
  '42501', null, 'editor cannot add members');
select lives_ok(
  $$update public.garden_members set role = 'editor'
    where garden_id = 'b0000000-0000-4000-8000-000000000001'
      and user_id = 'a0000000-0000-4000-8000-000000000003'$$,
  'editor role update statement runs (must affect nothing)');
select lives_ok(
  $$delete from public.garden_members
    where garden_id = 'b0000000-0000-4000-8000-000000000001'
      and user_id = 'a0000000-0000-4000-8000-000000000003'$$,
  'editor member delete statement runs (must affect nothing)');
select is(
  (select role from public.garden_members
   where garden_id = 'b0000000-0000-4000-8000-000000000001'
     and user_id = 'a0000000-0000-4000-8000-000000000003'),
  'viewer', 'editor could neither change nor remove the viewer');
select lives_ok(
  $$update public.gardens
    set name = 'Přejmenováno', owner_id = auth.uid(), updated_at = now() + interval '2 minutes'
    where id = 'b0000000-0000-4000-8000-000000000001'$$,
  'editor updates the garden');
select is(
  (select name || '|' || owner_id::text from public.gardens where id = 'b0000000-0000-4000-8000-000000000001'),
  'Přejmenováno|a0000000-0000-4000-8000-000000000001',
  'editor renamed the garden but owner_id change was ignored');
select throws_ok(
  $$delete from public.gardens where id = 'b0000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'nobody hard-deletes a garden through the API');

-- ================================================================ viewer
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000003","role":"authenticated"}';

select lives_ok(
  $$update public.gardens set name = 'Viewer', updated_at = now() + interval '3 minutes'
    where id = 'b0000000-0000-4000-8000-000000000001'$$,
  'viewer garden update statement runs (must affect nothing)');
select is(
  (select name from public.gardens where id = 'b0000000-0000-4000-8000-000000000001'),
  'Přejmenováno', 'viewer cannot rename the garden');

-- ================================================================ stranger
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000004","role":"authenticated"}';

select is((select count(*)::int from public.gardens), 0, 'stranger sees no gardens');
select is((select count(*)::int from public.garden_members), 0, 'stranger sees no memberships');
select throws_ok(
  $$insert into public.garden_members (garden_id, user_id, role) values
    ('b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000004', 'editor')$$,
  '42501', null, 'stranger cannot add himself to a garden');
select throws_ok(
  $$insert into public.gardens (id, name) values
    ('b0000000-0000-4000-8000-000000000041', 'S1'),
    ('b0000000-0000-4000-8000-000000000042', 'S2')$$,
  'P0001', 'garden_limit_reached', 'free user cannot create two gardens in one statement');

-- ================================================================ premium
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000005","role":"authenticated"}';

select lives_ok(
  $$insert into public.gardens (id, name) values
    ('b0000000-0000-4000-8000-000000000051', 'P1'),
    ('b0000000-0000-4000-8000-000000000052', 'P2')$$,
  'premium user creates several gardens');

reset role;
update public.entitlements set valid_until = now() - interval '1 day'
where user_id = 'a0000000-0000-4000-8000-000000000005';
set local role authenticated;
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000005","role":"authenticated"}';

select throws_ok(
  $$insert into public.gardens (id, name) values ('b0000000-0000-4000-8000-000000000053', 'P3')$$,
  'P0001', 'garden_limit_reached', 'expired premium falls back to the free limit');

-- ================================================================ viewer leaves
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000003","role":"authenticated"}';
select lives_ok(
  $$delete from public.garden_members
    where garden_id = 'b0000000-0000-4000-8000-000000000001' and user_id = auth.uid()$$,
  'a member can leave the garden');
select is((select count(*)::int from public.gardens), 0, 'after leaving the garden is invisible');

-- ================================================================ ownership transfer (backend)
reset role;
set local role service_role;
set local request.jwt.claims to '{"role":"service_role"}';

select lives_ok(
  $$select public.transfer_garden_ownership('b0000000-0000-4000-8000-000000000001',
      'a0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000002')$$,
  'service role transfers ownership to the editor');
select is(
  (select g.owner_id::text || '|' || m.role from public.gardens g
   join public.garden_members m on m.garden_id = g.id and m.user_id = g.owner_id
   where g.id = 'b0000000-0000-4000-8000-000000000001'),
  'a0000000-0000-4000-8000-000000000002|owner', 'new owner has the owner role');

select * from finish();
rollback;
