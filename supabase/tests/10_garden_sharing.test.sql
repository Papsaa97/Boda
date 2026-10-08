-- Sdílení zahrady (V2, DECLOG D89): pozvánka od vlastníka s Premium,
-- přijetí kódem, seznam členů jen pro členy, odebrání a odchod.
begin;
create extension if not exists pgtap with schema extensions;
select plan(17);

insert into auth.users (id, email) values
  ('a0000000-0000-4000-8000-000000000001', 'owner@example.test'),
  ('a0000000-0000-4000-8000-000000000002', 'partner@example.test'),
  ('a0000000-0000-4000-8000-000000000003', 'stranger@example.test'),
  ('a0000000-0000-4000-8000-000000000004', 'free@example.test');

update public.entitlements set plan = 'premium', valid_until = null, source = 'promo'
where user_id = 'a0000000-0000-4000-8000-000000000001';
update public.profiles set display_name = 'Papi'
where id = 'a0000000-0000-4000-8000-000000000001';

set local role authenticated;

-- ----------------------------------------------------------- vlastník Free
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000004","role":"authenticated"}';
insert into public.gardens (id, name) values ('b0000000-0000-4000-8000-000000000004', 'Free');
select throws_ok(
  $$select * from public.create_garden_invite('b0000000-0000-4000-8000-000000000004')$$,
  '42501', 'premium_required', 'a free owner cannot invite');

-- ------------------------------------------------------- vlastník Premium
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}';
insert into public.gardens (id, name) values ('b0000000-0000-4000-8000-000000000001', 'Rodinná');
create temporary table invite on commit drop as
  select * from public.create_garden_invite('b0000000-0000-4000-8000-000000000001');
grant select on invite to authenticated;
select ok((select code ~ '^[A-HJ-NP-Z2-9]{8}$' from invite), 'invite code has 8 unambiguous characters');
select ok(
  (select expires_at > now() + interval '6 days' from invite),
  'invite is valid for 7 days');
select throws_ok(
  $$select count(*) from public.garden_invites$$,
  '42501', null, 'invites are not readable directly');

-- ------------------------------------------------------- cizí uživatel
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000003","role":"authenticated"}';
select throws_ok(
  $$select * from public.create_garden_invite('b0000000-0000-4000-8000-000000000001')$$,
  '42501', 'not_owner', 'a stranger cannot invite');
select throws_ok(
  $$select * from public.garden_member_list('b0000000-0000-4000-8000-000000000001')$$,
  '42501', 'not_member', 'a stranger cannot list members');
select throws_ok(
  $$select public.accept_garden_invite('ABCDEFGH')$$,
  'P0002', 'invalid_invite', 'a wrong code is rejected');

-- ------------------------------------------------------- partner přijímá
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}';
select is(
  public.accept_garden_invite((select lower(substr(code, 1, 4)) || '-' || substr(code, 5) from invite)),
  'b0000000-0000-4000-8000-000000000001'::uuid,
  'the code works in lower case with a dash');
select is(
  (select role from public.garden_members
   where garden_id = 'b0000000-0000-4000-8000-000000000001' and user_id = auth.uid()),
  'editor', 'partner is an editor');
select is(
  (select array_agg(role || ':' || coalesce(display_name, '-') || ':' || email order by joined_at)
   from public.garden_member_list('b0000000-0000-4000-8000-000000000001')),
  array['owner:Papi:owner@example.test', 'editor:-:partner@example.test'],
  'members see each other');
select lives_ok(
  $$select public.sync_push('{"zones": [{"id": "c0000000-0000-4000-8000-000000000001",
    "garden_id": "b0000000-0000-4000-8000-000000000001", "name": "Záhon", "type": "vegetable",
    "covered": false, "archived": false,
    "created_at": "2026-10-08T10:00:00Z", "updated_at": "2026-10-08T10:00:00Z"}]}'::jsonb)$$,
  'partner writes into the shared garden');

-- ------------------------------------------------------- kód je použitý
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000003","role":"authenticated"}';
select throws_ok(
  $$select public.accept_garden_invite((select code from invite))$$,
  'P0002', 'invalid_invite', 'a used code cannot be reused');

-- ------------------------------------------------------- prošlá pozvánka
reset role;
insert into public.garden_invites (garden_id, code, created_by, expires_at)
values ('b0000000-0000-4000-8000-000000000001', 'EXPRDCDE', 'a0000000-0000-4000-8000-000000000001',
        now() - interval '1 minute');
set local role authenticated;
select throws_ok(
  $$select public.accept_garden_invite('EXPRDCDE')$$,
  'P0002', 'invalid_invite', 'an expired code is rejected');

-- ------------------------------------------------------- odebrání a odchod
set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}';
select lives_ok(
  $$delete from public.garden_members
    where garden_id = 'b0000000-0000-4000-8000-000000000001'
      and user_id = 'a0000000-0000-4000-8000-000000000002'$$,
  'owner removes the partner');
select is(
  (select count(*)::int from public.garden_members
   where garden_id = 'b0000000-0000-4000-8000-000000000001'),
  1, 'only the owner is left');

set local request.jwt.claims to '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}';
select is(
  (select count(*)::int from public.zones where garden_id = 'b0000000-0000-4000-8000-000000000001'),
  0, 'a removed member no longer sees the garden data');
select throws_ok(
  $$select public.sync_push('{"zones": [{"id": "c0000000-0000-4000-8000-000000000002",
    "garden_id": "b0000000-0000-4000-8000-000000000001", "name": "Cizí", "type": "vegetable",
    "covered": false, "archived": false,
    "created_at": "2026-10-08T10:00:00Z", "updated_at": "2026-10-08T10:00:00Z"}]}'::jsonb)$$,
  '42501', null, 'a removed member cannot write');

select * from finish();
rollback;
