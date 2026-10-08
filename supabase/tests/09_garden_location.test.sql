-- Poloha zahrady v synchronizaci (V2, DECLOG D85): souřadnice se na
-- serveru uloží zaokrouhlené na ~1 km a nadmořská výška projde.
begin;
create extension if not exists pgtap with schema extensions;
select plan(5);

insert into auth.users (id, email) values
  ('a0000000-0000-4000-8000-000000000001', 'owner@example.test');

set local role authenticated;
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}';

select lives_ok(
  $$select public.sync_push('{
    "gardens": [{"id": "b0000000-0000-4000-8000-000000000001", "name": "Moje zahrada",
                 "location_lat": 49.1951, "location_lng": 16.6068, "altitude_m": 237,
                 "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-01T10:00:00Z"}]
  }'::jsonb)$$,
  'garden location is pushed');

select is(
  (select location_lat::text || '|' || location_lng::text from public.gardens
   where id = 'b0000000-0000-4000-8000-000000000001'),
  '49.20|16.61', 'coordinates are stored rounded to ~1 km');
select is(
  (select altitude_m::int from public.gardens
   where id = 'b0000000-0000-4000-8000-000000000001'),
  237, 'altitude is stored');

-- Smazání polohy: novější zápis s null.
select lives_ok(
  $$select public.sync_push('{"gardens": [
    {"id": "b0000000-0000-4000-8000-000000000001", "name": "Moje zahrada",
     "location_lat": null, "location_lng": null, "altitude_m": null,
     "created_at": "2026-10-01T10:00:00Z", "updated_at": "2026-10-02T10:00:00Z"}]}'::jsonb)$$,
  'cleared location is pushed');
select ok(
  (select location_lat is null and altitude_m is null from public.gardens
   where id = 'b0000000-0000-4000-8000-000000000001'),
  'the newer write clears the location');

select * from finish();
rollback;
