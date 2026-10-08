-- Odeslání fronty změn funkcí sync_push (DECLOG D69): jedna transakce
-- přes tabulky s cyklickými cizími klíči, RLS, poslední zápis vyhrává,
-- natvrdo smazané řádky se na serveru smažou měkce.
begin;
create extension if not exists pgtap with schema extensions;
select plan(13);

insert into auth.users (id, email) values
  ('a0000000-0000-4000-8000-000000000001', 'owner@example.test'),
  ('a0000000-0000-4000-8000-000000000002', 'stranger@example.test');

set local role authenticated;
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}';

-- Nová zahrada se vším najednou; úkol odkazuje na záznam a záznam na úkol.
select lives_ok(
  $$select public.sync_push('{
    "gardens": [{"id": "b0000000-0000-4000-8000-000000000001", "name": "Moje zahrada",
                 "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-01T10:00:00Z"}],
    "zones": [{"id": "c0000000-0000-4000-8000-000000000001",
               "garden_id": "b0000000-0000-4000-8000-000000000001", "name": "Zelenina",
               "type": "vegetable", "area_m2": 20, "covered": false, "archived": false,
               "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-01T10:00:00Z"}],
    "inventory_items": [{"id": "e0000000-0000-4000-8000-000000000001",
               "garden_id": "b0000000-0000-4000-8000-000000000001", "category": "fertilizer",
               "name": "Cererit", "unit": "kg", "stock_qty": 2.5,
               "details": {"n": 10, "dosePerM2": 60, "doseUnit": "g"},
               "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-01T10:00:00Z"}],
    "tasks": [{"id": "d0000000-0000-4000-8000-000000000001",
               "garden_id": "b0000000-0000-4000-8000-000000000001", "title": "Pohnojit",
               "zone_id": "c0000000-0000-4000-8000-000000000001", "due": "2026-10-02",
               "status": "done", "tools": ["Konev"], "source": "boda",
               "completed_activity_id": "f0000000-0000-4000-8000-000000000001",
               "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-01T10:00:00Z"}],
    "activities": [{"id": "f0000000-0000-4000-8000-000000000001",
               "garden_id": "b0000000-0000-4000-8000-000000000001",
               "zone_id": "c0000000-0000-4000-8000-000000000001", "type": "fertilizing",
               "title": "Pohnojeno", "occurred_at": "2026-10-02T08:00:00Z", "occurred_tz": "+02:00",
               "task_id": "d0000000-0000-4000-8000-000000000001",
               "created_at": "2026-10-02T08:00:00Z", "updated_at": "2026-10-02T08:00:00Z"}],
    "task_materials": [{"task_id": "d0000000-0000-4000-8000-000000000001",
               "item_id": "e0000000-0000-4000-8000-000000000001",
               "garden_id": "b0000000-0000-4000-8000-000000000001", "qty": 1.2, "unit": "kg",
               "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-01T10:00:00Z"}],
    "assistant_threads": [{"id": "90000000-0000-4000-8000-000000000001",
               "garden_id": "b0000000-0000-4000-8000-000000000001", "title": "Hnojení",
               "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-01T10:00:00Z"}],
    "assistant_messages": [{"id": "91000000-0000-4000-8000-000000000001",
               "thread_id": "90000000-0000-4000-8000-000000000001", "role": "user",
               "text": "Kolik hnojiva?", "created_at": "2026-10-01T10:00:00Z",
               "updated_at": "2026-10-01T10:00:00Z"}]
  }'::jsonb)$$,
  'a whole new garden is pushed in one call, cyclic keys included');

select is(
  (select owner_id from public.gardens where id = 'b0000000-0000-4000-8000-000000000001'),
  'a0000000-0000-4000-8000-000000000001'::uuid, 'garden owner is the caller');
select is(
  (select tools from public.tasks where id = 'd0000000-0000-4000-8000-000000000001'),
  array['Konev'], 'JSON arrays become text[]');
select is(
  (select details ->> 'dosePerM2' from public.inventory_items
   where id = 'e0000000-0000-4000-8000-000000000001'),
  '60', 'details stay jsonb');
select is(
  (select user_id from public.assistant_messages
   where id = '91000000-0000-4000-8000-000000000001'),
  'a0000000-0000-4000-8000-000000000001'::uuid, 'message owner is the caller');

-- Starší změna se zahodí, novější projde; sloupce, které aplikace
-- neposílá, zůstanou.
reset role;
update public.zones set polygon = '[[0,0],[1,0],[1,1]]'::jsonb
  where id = 'c0000000-0000-4000-8000-000000000001';
set local role authenticated;
select lives_ok(
  $$select public.sync_push('{"zones": [
    {"id": "c0000000-0000-4000-8000-000000000001",
     "garden_id": "b0000000-0000-4000-8000-000000000001", "name": "Starší",
     "type": "vegetable", "covered": false, "archived": false,
     "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-09-30T10:00:00Z"}]}'::jsonb)$$,
  'older change runs');
select is(
  (select name from public.zones where id = 'c0000000-0000-4000-8000-000000000001'),
  'Zelenina', 'older change is skipped');
select lives_ok(
  $$select public.sync_push('{"zones": [
    {"id": "c0000000-0000-4000-8000-000000000001",
     "garden_id": "b0000000-0000-4000-8000-000000000001", "name": "Zelenina JV",
     "type": "vegetable", "area_m2": 22, "covered": true, "archived": false,
     "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-03T10:00:00Z"}]}'::jsonb)$$,
  'newer change runs');
select is(
  (select name || '|' || area_m2::text || '|' || (polygon is not null)::text
   from public.zones where id = 'c0000000-0000-4000-8000-000000000001'),
  'Zelenina JV|22|true', 'newer change is applied and the polygon is kept');

-- Natvrdo smazaný řádek v telefonu = měkké smazání na serveru.
select lives_ok(
  $$select public.sync_push('{"deleted": [
    {"table": "task_materials",
     "key": {"task_id": "d0000000-0000-4000-8000-000000000001",
             "item_id": "e0000000-0000-4000-8000-000000000001"},
     "at": "2026-10-04T10:00:00Z"}]}'::jsonb)$$,
  'tombstone runs');
select ok(
  (select deleted_at is not null from public.task_materials
   where task_id = 'd0000000-0000-4000-8000-000000000001'),
  'tombstone soft-deletes the row');

-- Cizí uživatel do zahrady nezapíše (RLS) a neznámá tabulka neprojde.
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}';
select throws_ok(
  $$select public.sync_push('{"zones": [
    {"id": "c0000000-0000-4000-8000-000000000009",
     "garden_id": "b0000000-0000-4000-8000-000000000001", "name": "Cizí",
     "type": "other", "covered": false, "archived": false,
     "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-01T10:00:00Z"}]}'::jsonb)$$,
  '42501', null, 'a stranger cannot push into the garden');
select throws_ok(
  $$select public.sync_push('{"deleted": [{"table": "gardens", "key": {"id": "b0000000-0000-4000-8000-000000000001"}, "at": "2026-10-04T10:00:00Z"}]}'::jsonb)$$,
  '22023', null, 'tombstones only for known tables');

select * from finish();
rollback;
