-- V2 (DECLOG D82, D83): incidenty s kontrolami a fotkami a pohyby na
-- skladě projdou přes sync_push; viewer incident jen čte, cizí uživatel
-- ho nevidí.
begin;
create extension if not exists pgtap with schema extensions;
select plan(14);

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
               "garden_id": "b0000000-0000-4000-8000-000000000001", "name": "Rybíz",
               "type": "fruit", "covered": false, "archived": false,
               "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-01T10:00:00Z"}],
    "incidents": [{"id": "90000000-0000-4000-8000-000000000001",
                   "garden_id": "b0000000-0000-4000-8000-000000000001",
                   "zone_id": "c0000000-0000-4000-8000-000000000001",
                   "label": "Mšice na rybízu", "source": "user", "status": "open",
                   "plan_bio": "Ostříhat napadené vrcholky", "candidates": [],
                   "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-01T10:00:00Z"}],
    "inventory_items": [{"id": "d0000000-0000-4000-8000-000000000001",
                         "garden_id": "b0000000-0000-4000-8000-000000000001",
                         "category": "fertilizer", "name": "Cererit", "unit": "kg",
                         "stock_qty": 1.3, "details": {"form": "granules"},
                         "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-02T10:00:00Z"}],
    "tasks": [{"id": "e0000000-0000-4000-8000-000000000001",
               "garden_id": "b0000000-0000-4000-8000-000000000001",
               "title": "Kontrola po 3 dnech: Mšice na rybízu", "due": "2026-10-04",
               "status": "done", "source": "user",
               "zone_id": "c0000000-0000-4000-8000-000000000001",
               "incident_id": "90000000-0000-4000-8000-000000000001",
               "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-02T10:00:00Z"}],
    "photos": [{"id": "70000000-0000-4000-8000-000000000001",
                "garden_id": "b0000000-0000-4000-8000-000000000001",
                "incident_id": "90000000-0000-4000-8000-000000000001",
                "storage_path": "b0000000-0000-4000-8000-000000000001/70000000-0000-4000-8000-000000000001.jpg",
                "thumb_path": "b0000000-0000-4000-8000-000000000001/70000000-0000-4000-8000-000000000001_thumb.jpg",
                "position": 0,
                "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-01T10:00:00Z"}],
    "inventory_movements": [{"id": "60000000-0000-4000-8000-000000000001",
                             "garden_id": "b0000000-0000-4000-8000-000000000001",
                             "item_id": "d0000000-0000-4000-8000-000000000001",
                             "qty_delta": -1.2, "reason": "task",
                             "task_id": "e0000000-0000-4000-8000-000000000001",
                             "at": "2026-10-02T10:00:00Z",
                             "created_at": "2026-10-02T10:00:00Z", "updated_at": "2026-10-02T10:00:00Z"}]
  }'::jsonb)$$,
  'incident, its check, photo and a stock movement are pushed in one call');

select is(
  (select label || '|' || status from public.incidents
   where id = '90000000-0000-4000-8000-000000000001'),
  'Mšice na rybízu|open', 'the incident is stored');
select is(
  (select incident_id::text from public.tasks where id = 'e0000000-0000-4000-8000-000000000001'),
  '90000000-0000-4000-8000-000000000001', 'the check task points to the incident');
select is(
  (select incident_id::text from public.photos where id = '70000000-0000-4000-8000-000000000001'),
  '90000000-0000-4000-8000-000000000001', 'the photo belongs to the incident');
select is(
  (select qty_delta::text || '|' || reason from public.inventory_movements
   where id = '60000000-0000-4000-8000-000000000001'),
  '-1.2|task', 'the stock movement is stored');

-- Vyřešení: novější zápis vyhraje.
select lives_ok(
  $$select public.sync_push('{"incidents": [{"id": "90000000-0000-4000-8000-000000000001",
     "garden_id": "b0000000-0000-4000-8000-000000000001",
     "zone_id": "c0000000-0000-4000-8000-000000000001",
     "label": "Mšice na rybízu", "source": "user", "status": "resolved",
     "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-08T10:00:00Z"}]}'::jsonb)$$,
  'resolving the incident is pushed');
select is(
  (select status from public.incidents where id = '90000000-0000-4000-8000-000000000001'),
  'resolved', 'the newer status wins');

select throws_ok(
  $$select public.sync_push('{"incidents": [{"id": "90000000-0000-4000-8000-000000000002",
     "garden_id": "b0000000-0000-4000-8000-000000000001",
     "zone_id": "c0000000-0000-4000-8000-000000000001",
     "label": "Plíseň", "source": "user", "status": "maybe",
     "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-01T10:00:00Z"}]}'::jsonb)$$,
  '23514', null, 'an unknown incident status is rejected');

select lives_ok(
  $$select public.sync_push('{"deleted": [{"table": "incidents",
     "key": {"id": "90000000-0000-4000-8000-000000000001"}, "at": "2026-10-09T10:00:00Z"}]}'::jsonb)$$,
  'an incident can be deleted through sync_push');
select isnt(
  (select deleted_at from public.incidents where id = '90000000-0000-4000-8000-000000000001'),
  null, 'the delete is soft');

reset role;
insert into public.garden_members (garden_id, user_id, role) values
  ('b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000003', 'viewer');
set local role authenticated;

-- ================================================================ viewer
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000003","role":"authenticated"}';
select is((select count(*)::int from public.incidents), 1, 'viewer reads incidents');
select throws_ok(
  $$insert into public.incidents (id, garden_id, zone_id, label)
    values ('90000000-0000-4000-8000-000000000003', 'b0000000-0000-4000-8000-000000000001',
            'c0000000-0000-4000-8000-000000000001', 'Slimáci')$$,
  '42501', null, 'viewer cannot insert incidents');

-- ================================================================ stranger
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000004","role":"authenticated"}';
select is((select count(*)::int from public.incidents), 0, 'stranger sees no incidents');
select throws_ok(
  $$insert into public.incidents (id, garden_id, zone_id, label)
    values ('90000000-0000-4000-8000-000000000004', 'b0000000-0000-4000-8000-000000000001',
            'c0000000-0000-4000-8000-000000000001', 'Slimáci')$$,
  '42501', null, 'stranger cannot insert incidents');

select * from finish();
rollback;
