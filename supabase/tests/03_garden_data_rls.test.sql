-- Data zahrady a fotky v úložišti: cizí uživatel nic nepřečte ani
-- nezapíše, viewer jen čte, editor zapisuje (ale nemaže fyzicky).
begin;
create extension if not exists pgtap with schema extensions;
select plan(55);

insert into auth.users (id, email) values
  ('a0000000-0000-4000-8000-000000000001', 'owner@example.test'),
  ('a0000000-0000-4000-8000-000000000002', 'editor@example.test'),
  ('a0000000-0000-4000-8000-000000000003', 'viewer@example.test'),
  ('a0000000-0000-4000-8000-000000000004', 'stranger@example.test');

-- Fixture: zahrada vlastníka se dvěma členy a jedním řádkem v každé tabulce.
insert into public.gardens (id, name, owner_id) values
  ('b0000000-0000-4000-8000-000000000001', 'Zahrada', 'a0000000-0000-4000-8000-000000000001'),
  ('b0000000-0000-4000-8000-000000000002', 'Cizí zahrada', 'a0000000-0000-4000-8000-000000000004');
insert into public.garden_members (garden_id, user_id, role) values
  ('b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000002', 'editor'),
  ('b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000003', 'viewer');

insert into public.zones (id, garden_id, name, type, area_m2, soil_texture, ph, sun_exposure, irrigation)
values ('c0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001',
        'Zelenina JV', 'vegetable', 20, 'loamy', 6.6, 'fullSun', 'drip');
insert into public.zones (id, garden_id, name)
values ('c0000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000002', 'Cizí zóna');
insert into public.inventory_items (id, garden_id, category, name, unit, stock_qty, details)
values ('d0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001',
        'fertilizer', 'Kompost', 'kg', 50, '{"form":"solid"}');
insert into public.tasks (id, garden_id, title, zone_id, due, remind_at, tools)
values ('e0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001',
        'Zalít', 'c0000000-0000-4000-8000-000000000001', '2026-10-10', 480, array['konev']);
insert into public.activities (id, garden_id, zone_id, type, title, occurred_at, occurred_tz, task_id)
values ('f0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001',
        'c0000000-0000-4000-8000-000000000001', 'watering', 'Zálivka', now(), '+02:00',
        'e0000000-0000-4000-8000-000000000001');
insert into public.activity_materials (activity_id, item_id, garden_id, qty, unit)
values ('f0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000001',
        'b0000000-0000-4000-8000-000000000001', 2, 'kg');
insert into public.task_materials (task_id, item_id, garden_id, qty, unit)
values ('e0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000001',
        'b0000000-0000-4000-8000-000000000001', 1, 'kg');
insert into public.photos (id, garden_id, activity_id, storage_path, thumb_path, width, height)
values ('70000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001',
        'f0000000-0000-4000-8000-000000000001',
        'b0000000-0000-4000-8000-000000000001/70000000-0000-4000-8000-000000000001.jpg',
        'b0000000-0000-4000-8000-000000000001/70000000-0000-4000-8000-000000000001_thumb.jpg',
        1600, 1200);
insert into public.inventory_movements (id, garden_id, item_id, qty_delta, reason)
values ('71000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001',
        'd0000000-0000-4000-8000-000000000001', 50, 'purchase');
insert into public.shopping_items (id, garden_id, name, qty, unit, item_id, source)
values ('72000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001',
        'Kompost', 20, 'kg', 'd0000000-0000-4000-8000-000000000001', 'boda');
insert into public.assistant_threads (id, user_id, garden_id, title)
values ('73000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001',
        'b0000000-0000-4000-8000-000000000001', 'Rajčata');
insert into public.assistant_messages (id, thread_id, user_id, role, text)
values ('74000000-0000-4000-8000-000000000001', '73000000-0000-4000-8000-000000000001',
        'a0000000-0000-4000-8000-000000000001', 'user', 'Jak na rajčata?');
insert into public.assistant_usage (user_id, period, count, cost_usd)
values ('a0000000-0000-4000-8000-000000000001', '2026-10', 3, 0.01);
insert into storage.objects (bucket_id, name) values
  ('photos', 'b0000000-0000-4000-8000-000000000001/70000000-0000-4000-8000-000000000001.jpg'),
  ('photos', 'b0000000-0000-4000-8000-000000000001/70000000-0000-4000-8000-000000000001_thumb.jpg');

-- ================================================================ stranger
set local role authenticated;
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000004","role":"authenticated"}';

select is((select count(*)::int from public.gardens), 1, 'stranger sees only own garden');
select is((select count(*)::int from public.garden_members where garden_id = 'b0000000-0000-4000-8000-000000000001'), 0, 'stranger: garden_members');
select is((select count(*)::int from public.zones where garden_id = 'b0000000-0000-4000-8000-000000000001'), 0, 'stranger: zones');
select is((select count(*)::int from public.activities), 0, 'stranger: activities');
select is((select count(*)::int from public.activity_materials), 0, 'stranger: activity_materials');
select is((select count(*)::int from public.photos), 0, 'stranger: photos');
select is((select count(*)::int from public.tasks), 0, 'stranger: tasks');
select is((select count(*)::int from public.task_materials), 0, 'stranger: task_materials');
select is((select count(*)::int from public.inventory_items), 0, 'stranger: inventory_items');
select is((select count(*)::int from public.inventory_movements), 0, 'stranger: inventory_movements');
select is((select count(*)::int from public.shopping_items), 0, 'stranger: shopping_items');
select is((select count(*)::int from public.assistant_threads), 0, 'stranger: assistant_threads');
select is((select count(*)::int from public.assistant_messages), 0, 'stranger: assistant_messages');
select is((select count(*)::int from public.assistant_usage), 0, 'stranger: assistant_usage');
select is((select count(*)::int from public.profiles where id <> auth.uid()), 0, 'stranger: other profiles');
select is((select count(*)::int from public.entitlements where user_id <> auth.uid()), 0, 'stranger: other entitlements');
select is((select count(*)::int from storage.objects where bucket_id = 'photos'), 0, 'stranger: storage objects');
select throws_ok(
  $$insert into public.zones (id, garden_id, name)
    values (gen_random_uuid(), 'b0000000-0000-4000-8000-000000000001', 'X')$$,
  '42501', null, 'stranger cannot insert into another garden');
select throws_ok(
  $$insert into storage.objects (bucket_id, name)
    values ('photos', 'b0000000-0000-4000-8000-000000000001/75000000-0000-4000-8000-000000000001.jpg')$$,
  '42501', null, 'stranger cannot upload into another garden');
select lives_ok(
  $$update public.zones set name = 'hacked', updated_at = now() + interval '1 hour'
    where id = 'c0000000-0000-4000-8000-000000000001'$$,
  'stranger update statement runs (must affect nothing)');
select lives_ok(
  $$update storage.objects set name = name || '.bak' where bucket_id = 'photos'$$,
  'stranger storage rename statement runs (must affect nothing)');

-- ================================================================ viewer
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000003","role":"authenticated"}';

select is((select count(*)::int from public.zones), 1, 'viewer reads zones');
select is((select count(*)::int from public.activities), 1, 'viewer reads activities');
select is((select count(*)::int from public.activity_materials), 1, 'viewer reads activity_materials');
select is((select count(*)::int from public.photos), 1, 'viewer reads photos');
select is((select count(*)::int from public.tasks), 1, 'viewer reads tasks');
select is((select count(*)::int from public.task_materials), 1, 'viewer reads task_materials');
select is((select count(*)::int from public.inventory_items), 1, 'viewer reads inventory_items');
select is((select count(*)::int from public.inventory_movements), 1, 'viewer reads inventory_movements');
select is((select count(*)::int from public.shopping_items), 1, 'viewer reads shopping_items');
select is((select count(*)::int from storage.objects where bucket_id = 'photos'), 2, 'viewer reads photo files');
select is((select count(*)::int from public.assistant_threads), 0, 'viewer does not see the owner''s Bóďa threads');
select throws_ok(
  $$insert into public.zones (id, garden_id, name)
    values (gen_random_uuid(), 'b0000000-0000-4000-8000-000000000001', 'Viewer')$$,
  '42501', null, 'viewer cannot insert zones');
select throws_ok(
  $$insert into public.shopping_items (id, garden_id, name)
    values (gen_random_uuid(), 'b0000000-0000-4000-8000-000000000001', 'Viewer')$$,
  '42501', null, 'viewer cannot insert shopping items');
select lives_ok(
  $$update public.tasks set status = 'done', updated_at = now() + interval '1 hour'
    where id = 'e0000000-0000-4000-8000-000000000001'$$,
  'viewer task update statement runs (must affect nothing)');
select is((select status from public.tasks where id = 'e0000000-0000-4000-8000-000000000001'), 'open', 'viewer task update had no effect');
select throws_ok(
  $$insert into public.zones (id, garden_id, name)
    values ('c0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'Upsert')
    on conflict (id) do update set name = excluded.name$$,
  '42501', null, 'viewer upsert of an existing row is rejected');
select throws_ok(
  $$insert into storage.objects (bucket_id, name)
    values ('photos', 'b0000000-0000-4000-8000-000000000001/75000000-0000-4000-8000-000000000002.jpg')$$,
  '42501', null, 'viewer cannot upload photos');

-- ================================================================ editor
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}';

select lives_ok(
  $$insert into public.zones (id, garden_id, name, type, covered, layer)
    values ('c0000000-0000-4000-8000-000000000003', 'b0000000-0000-4000-8000-000000000001',
            'Skleník', 'greenhouse', true, 'reality')$$,
  'editor inserts a zone');
select lives_ok(
  $$insert into public.activities (id, garden_id, zone_id, type, title, occurred_at, occurred_tz)
    values ('f0000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000001',
            'c0000000-0000-4000-8000-000000000003', 'sowing', 'Výsev', now(), '+01:00')$$,
  'editor inserts an activity');
select lives_ok(
  $$insert into public.shopping_items (id, garden_id, name, source)
    values ('72000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000001', 'Provázek', 'user')$$,
  'editor inserts a shopping item');
select lives_ok(
  $$update public.tasks set status = 'done', completed_at = now(),
      completed_activity_id = 'f0000000-0000-4000-8000-000000000002',
      updated_at = now() + interval '1 hour'
    where id = 'e0000000-0000-4000-8000-000000000001'$$,
  'editor completes a task');
select is((select status from public.tasks where id = 'e0000000-0000-4000-8000-000000000001'), 'done', 'task update applied');
select lives_ok(
  $$insert into storage.objects (bucket_id, name)
    values ('photos', 'b0000000-0000-4000-8000-000000000001/75000000-0000-4000-8000-000000000003_thumb.jpg')$$,
  'editor uploads a photo');
select throws_ok(
  $$insert into storage.objects (bucket_id, name)
    values ('photos', 'b0000000-0000-4000-8000-000000000001/evil.png')$$,
  '42501', null, 'upload with a non-conforming path is rejected');
select throws_ok(
  $$delete from public.zones where id = 'c0000000-0000-4000-8000-000000000003'$$,
  '42501', null, 'editor cannot hard-delete rows (soft delete only)');
select lives_ok(
  $$update public.zones set deleted_at = now(), updated_at = now() + interval '1 hour'
    where id = 'c0000000-0000-4000-8000-000000000003'$$,
  'editor soft-deletes a zone');
select throws_ok(
  $$insert into public.inventory_items (id, garden_id, category, name, unit)
    values (gen_random_uuid(), 'b0000000-0000-4000-8000-000000000001', 'plantProtection', 'Postřik', 'ml')$$,
  '23514', null, 'plant protection item without label details is rejected');
select lives_ok(
  $$insert into public.inventory_items (id, garden_id, category, name, unit, details)
    values (gen_random_uuid(), 'b0000000-0000-4000-8000-000000000001', 'plantProtection', 'Postřik', 'ml',
      '{"activeSubstance":"x","authorizationNo":"1234-5","phiDays":7,"nonProfessional":true}')$$,
  'plant protection item with label details is accepted');
select throws_ok(
  $$insert into public.zones (id, garden_id, name, soil_texture)
    values (gen_random_uuid(), 'b0000000-0000-4000-8000-000000000001', 'Z', 'loam')$$,
  '23514', null, 'unknown soil_texture value is rejected');

set constraints all immediate;
select throws_ok(
  $$insert into public.activities (id, garden_id, zone_id, type, title, occurred_at, occurred_tz)
    values (gen_random_uuid(), 'b0000000-0000-4000-8000-000000000001',
            'c0000000-0000-4000-8000-000000000002', 'other', 'Cizí zóna', now(), '+02:00')$$,
  '23503', null, 'activity cannot reference a zone of another garden');
select throws_ok(
  $$insert into public.photos (id, garden_id, storage_path, thumb_path)
    values ('70000000-0000-4000-8000-000000000009', 'b0000000-0000-4000-8000-000000000001',
            'b0000000-0000-4000-8000-000000000002/70000000-0000-4000-8000-000000000009.jpg',
            'b0000000-0000-4000-8000-000000000002/70000000-0000-4000-8000-000000000009_thumb.jpg')$$,
  '23514', null, 'photo storage path must be inside its garden');
select throws_ok(
  $$update public.zones set garden_id = 'b0000000-0000-4000-8000-000000000002',
      updated_at = now() + interval '2 hours'
    where id = 'c0000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'a row cannot be moved to another garden');

-- ================================================================ checks as superuser
reset role;
select is(
  (select name from public.zones where id = 'c0000000-0000-4000-8000-000000000001'),
  'Zelenina JV', 'stranger and viewer updates did not change data');
select is(
  (select count(*)::int from storage.objects where bucket_id = 'photos' and name not like '%.bak'),
  3, 'stranger could not rename photo files');

select * from finish();
rollback;
