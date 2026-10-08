-- V3 (DECLOG D90): návrhy staveb projdou přes sync_push; neznámá šablona
-- a parametry jiného tvaru než objekt se odmítnou; viewer jen čte, cizí
-- uživatel nic nevidí.
begin;
create extension if not exists pgtap with schema extensions;
select plan(11);

insert into auth.users (id, email) values
  ('a0000000-0000-4000-8000-000000000001', 'owner@example.test'),
  ('a0000000-0000-4000-8000-000000000003', 'viewer@example.test'),
  ('a0000000-0000-4000-8000-000000000004', 'stranger@example.test');

set local role authenticated;
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}';

select lives_ok(
  $$select public.sync_push('{
    "gardens": [{"id": "b0000000-0000-4000-8000-000000000001", "name": "Zahrada",
                 "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-01T10:00:00Z"}],
    "zones": [{"id": "c0000000-0000-4000-8000-000000000001",
               "garden_id": "b0000000-0000-4000-8000-000000000001", "name": "Jezírko",
               "type": "pond", "covered": false, "archived": false,
               "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-01T10:00:00Z"}],
    "builds": [{"id": "90000000-0000-4000-8000-000000000001",
                "garden_id": "b0000000-0000-4000-8000-000000000001",
                "zone_id": "c0000000-0000-4000-8000-000000000001",
                "template": "bridge", "name": "Mostek přes jezírko",
                "params": {"span": 2.4, "width": 0.9, "beamSection": "100x200"},
                "prices": {"beam100x200": 290},
                "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-01T10:00:00Z"}]
  }'::jsonb)$$,
  'a build is pushed with its zone');

select is(
  (select name || '|' || (params ->> 'span') || '|' || (prices ->> 'beam100x200')
   from public.builds where id = '90000000-0000-4000-8000-000000000001'),
  'Mostek přes jezírko|2.4|290', 'name, params and prices are stored');

select lives_ok(
  $$select public.sync_push('{"builds": [{"id": "90000000-0000-4000-8000-000000000001",
     "garden_id": "b0000000-0000-4000-8000-000000000001",
     "template": "bridge", "name": "Mostek", "params": {"span": 2.8},
     "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-05T10:00:00Z"}]}'::jsonb)$$,
  'an edited build is pushed');
select is(
  (select (params ->> 'span') || '|' || coalesce(zone_id::text, '-') || '|' || coalesce(prices::text, '-')
   from public.builds where id = '90000000-0000-4000-8000-000000000001'),
  '2.8|-|-', 'the newer version wins, zone and prices can be cleared');

select throws_ok(
  $$select public.sync_push('{"builds": [{"id": "90000000-0000-4000-8000-000000000002",
     "garden_id": "b0000000-0000-4000-8000-000000000001",
     "template": "castle", "name": "Hrad", "params": {},
     "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-01T10:00:00Z"}]}'::jsonb)$$,
  '23514', null, 'an unknown template is rejected');
select throws_ok(
  $$select public.sync_push('{"builds": [{"id": "90000000-0000-4000-8000-000000000003",
     "garden_id": "b0000000-0000-4000-8000-000000000001",
     "template": "path", "name": "Chodník", "params": [1, 2],
     "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-01T10:00:00Z"}]}'::jsonb)$$,
  '23514', null, 'params must be an object');

select lives_ok(
  $$select public.sync_push('{"deleted": [{"table": "builds",
     "key": {"id": "90000000-0000-4000-8000-000000000001"}, "at": "2026-10-09T10:00:00Z"}]}'::jsonb)$$,
  'a build can be deleted through sync_push');
select isnt(
  (select deleted_at from public.builds where id = '90000000-0000-4000-8000-000000000001'),
  null, 'the delete is soft');

reset role;
insert into public.garden_members (garden_id, user_id, role) values
  ('b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000003', 'viewer');
set local role authenticated;

-- ================================================================ viewer
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000003","role":"authenticated"}';
select is((select count(*)::int from public.builds), 1, 'viewer reads builds');
select throws_ok(
  $$insert into public.builds (id, garden_id, template, name)
    values ('90000000-0000-4000-8000-000000000004', 'b0000000-0000-4000-8000-000000000001',
            'path', 'Chodník')$$,
  '42501', null, 'viewer cannot insert builds');

-- ================================================================ stranger
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000004","role":"authenticated"}';
select is((select count(*)::int from public.builds), 0, 'stranger sees no builds');

select * from finish();
rollback;
