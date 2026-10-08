-- Plán zahrady v synchronizaci (MVP 1.1, DECLOG D77): obrys zahrady
-- a tvar a vrstva zóny projdou přes sync_push a platí pro ně „poslední
-- zápis vyhrává“ jako pro ostatní sloupce.
begin;
create extension if not exists pgtap with schema extensions;
select plan(6);

insert into auth.users (id, email) values
  ('a0000000-0000-4000-8000-000000000001', 'owner@example.test');

set local role authenticated;
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}';

select lives_ok(
  $$select public.sync_push('{
    "gardens": [{"id": "b0000000-0000-4000-8000-000000000001", "name": "Moje zahrada",
                 "bounds": {"outline": [[0, 0], [20, 0], [20, 15], [0, 15]]},
                 "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-01T10:00:00Z"}],
    "zones": [{"id": "c0000000-0000-4000-8000-000000000001",
               "garden_id": "b0000000-0000-4000-8000-000000000001", "name": "Jezírko",
               "type": "pond", "covered": false, "archived": false,
               "polygon": [[2, 2], [6, 2], [6, 5], [2, 5]], "layer": "plan",
               "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-01T10:00:00Z"}]
  }'::jsonb)$$,
  'garden outline and a planned zone shape are pushed');

select is(
  (select jsonb_array_length(bounds -> 'outline') from public.gardens
   where id = 'b0000000-0000-4000-8000-000000000001'),
  4, 'the outline is stored in gardens.bounds');
select is(
  (select layer || '|' || jsonb_array_length(polygon)::text from public.zones
   where id = 'c0000000-0000-4000-8000-000000000001'),
  'plan|4', 'zone shape and layer are stored');

-- Zrealizování zóny: novější zápis přesune zónu do reality.
select lives_ok(
  $$select public.sync_push('{"zones": [
    {"id": "c0000000-0000-4000-8000-000000000001",
     "garden_id": "b0000000-0000-4000-8000-000000000001", "name": "Jezírko",
     "type": "pond", "covered": false, "archived": false,
     "polygon": [[2, 2], [7, 2], [7, 5], [2, 5]], "layer": "reality",
     "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-02T10:00:00Z"}]}'::jsonb)$$,
  'realized zone is pushed');
select is(
  (select layer || '|' || (polygon -> 1 ->> 0) from public.zones
   where id = 'c0000000-0000-4000-8000-000000000001'),
  'reality|7', 'the newer shape and layer win');

select throws_ok(
  $$select public.sync_push('{"zones": [
    {"id": "c0000000-0000-4000-8000-000000000001",
     "garden_id": "b0000000-0000-4000-8000-000000000001", "name": "Jezírko",
     "type": "pond", "covered": false, "archived": false, "layer": "dream",
     "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-03T10:00:00Z"}]}'::jsonb)$$,
  '23514', null, 'an unknown layer is rejected');

select * from finish();
rollback;
