-- Profil a nárok Free vznikají s účtem; profiles jen vlastní řádek;
-- entitlements a assistant_usage zapisuje jen service role.
begin;
create extension if not exists pgtap with schema extensions;
select plan(28);

insert into auth.users (id, email) values
  ('a0000000-0000-4000-8000-000000000001', 'alice@example.test'),
  ('a0000000-0000-4000-8000-000000000004', 'mallory@example.test');

-- ---------------------------------------------------------------- auto-create
select is(
  (select count(*)::int from public.profiles where id = 'a0000000-0000-4000-8000-000000000001'),
  1, 'new auth user gets a profile row');
select is(
  (select plan from public.entitlements where user_id = 'a0000000-0000-4000-8000-000000000001'),
  'free', 'new auth user gets a free entitlement');
select is(
  (select source from public.entitlements where user_id = 'a0000000-0000-4000-8000-000000000001'),
  null::text, 'free entitlement has no source');

-- ---------------------------------------------------------------- as alice
set local role authenticated;
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}';

select is((select count(*)::int from public.profiles), 1, 'user sees only own profile');
select lives_ok(
  $$update public.profiles set display_name = 'Alice', settings = '{"theme":"light"}', updated_at = now() + interval '1 minute' where id = auth.uid()$$,
  'user updates own profile');
select is((select display_name from public.profiles where id = auth.uid()), 'Alice', 'profile update applied');
select lives_ok(
  $$update public.profiles set display_name = 'hacked' where id = 'a0000000-0000-4000-8000-000000000004'$$,
  'update of another profile runs but must not touch it (checked below)');

select is((select count(*)::int from public.entitlements), 1, 'user sees only own entitlement');
select throws_ok(
  $$update public.entitlements set plan = 'premium' where user_id = auth.uid()$$,
  '42501', null, 'user cannot update own entitlement');
select throws_ok(
  $$insert into public.entitlements (user_id, plan) values (auth.uid(), 'premium')$$,
  '42501', null, 'user cannot insert entitlement');
select throws_ok(
  $$delete from public.entitlements where user_id = auth.uid()$$,
  '42501', null, 'user cannot delete entitlement');
select throws_ok(
  $$insert into public.assistant_usage (user_id, period, count) values (auth.uid(), '2026-10', 0)$$,
  '42501', null, 'user cannot insert assistant_usage');
select throws_ok(
  $$update public.assistant_usage set count = 0 where user_id = auth.uid()$$,
  '42501', null, 'user cannot update assistant_usage');
select throws_ok(
  $$select public.assistant_usage_reserve(auth.uid(), '2026-10', 1000)$$,
  '42501', null, 'user cannot call assistant_usage_reserve');
select throws_ok(
  $$select public.apply_entitlement_event(auth.uid(), 'premium', null, 'promo', 'x', now())$$,
  '42501', null, 'user cannot call apply_entitlement_event');
select throws_ok(
  $$select public.transfer_garden_ownership(gen_random_uuid(), auth.uid(), auth.uid())$$,
  '42501', null, 'user cannot call transfer_garden_ownership');

-- ---------------------------------------------------------------- anon
reset role;
set local role anon;
set local request.jwt.claims to '{"role":"anon"}';
select throws_ok($$select * from public.profiles$$, '42501', null, 'anon cannot read profiles');
select throws_ok($$select * from public.entitlements$$, '42501', null, 'anon cannot read entitlements');

-- ---------------------------------------------------------------- service role
reset role;
set local role service_role;
set local request.jwt.claims to '{"role":"service_role"}';

select is(
  public.apply_entitlement_event('a0000000-0000-4000-8000-000000000001', 'premium',
    '2030-01-01T00:00:00Z', 'play', 'evt-1', '2026-10-01T00:00:00Z'),
  'applied', 'service role applies a purchase event');
select is(
  public.apply_entitlement_event('a0000000-0000-4000-8000-000000000001', 'premium',
    '2030-01-01T00:00:00Z', 'play', 'evt-1', '2026-10-01T00:00:00Z'),
  'duplicate', 'same event id is idempotent');
select is(
  public.apply_entitlement_event('a0000000-0000-4000-8000-000000000001', 'free',
    null, 'play', 'evt-0', '2026-09-01T00:00:00Z'),
  'stale', 'older event does not override newer state');
select is(
  public.apply_entitlement_event('a0000000-0000-4000-8000-00000000ffff', 'premium',
    null, 'promo', 'evt-2', now()),
  'unknown_user', 'event for unknown user is ignored');
select is(
  (select plan || ':' || source from public.entitlements where user_id = 'a0000000-0000-4000-8000-000000000001'),
  'premium:play', 'entitlement is premium from play');

select is(
  (select allowed::text || '/' || used from public.assistant_usage_reserve('a0000000-0000-4000-8000-000000000001', '2026-10', 2)),
  'true/1', 'first question within limit');
select is(
  (select allowed::text || '/' || used from public.assistant_usage_reserve('a0000000-0000-4000-8000-000000000001', '2026-10', 2)),
  'true/2', 'second question within limit');
select is(
  (select allowed::text || '/' || used from public.assistant_usage_reserve('a0000000-0000-4000-8000-000000000001', '2026-10', 2)),
  'false/2', 'third question over limit is refused');
select is(
  public.assistant_usage_settle('a0000000-0000-4000-8000-000000000001', '2026-10', 0.0123, true),
  1, 'settle with refund returns the reserved question');

select is(
  (select display_name from public.profiles where id = 'a0000000-0000-4000-8000-000000000004'),
  null::text, 'another user''s profile was not changed');

select * from finish();
rollback;
