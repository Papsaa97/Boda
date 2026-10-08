-- Řádkové zabezpečení (RLS) – spec 8.1 „Zabezpečení“.
--
-- * RLS je zapnuté na každé tabulce; tabulka bez pravidla je nedostupná.
-- * Data zahrady: číst smí každý člen, zapisovat owner a editor.
-- * Členy zahrady spravuje jen owner.
-- * profiles: jen vlastní řádek. entitlements, assistant_usage: uživatel
--   jen čte svůj řádek, zapisuje výhradně backend (service role, která RLS
--   obchází).
-- * Fyzické mazání (DELETE) aplikace nedělá – maže měkce přes deleted_at.
-- * Role anon nemá přístup k ničemu (host pracuje jen lokálně).

-- ---------------------------------------------------------------------------
-- Zapnutí RLS a základní oprávnění
-- ---------------------------------------------------------------------------

do $$
declare
  t text;
begin
  foreach t in array array[
    'profiles', 'entitlements', 'assistant_usage', 'gardens', 'garden_members',
    'zones', 'inventory_items', 'tasks', 'activities', 'activity_materials',
    'task_materials', 'photos', 'inventory_movements', 'shopping_items',
    'assistant_threads', 'assistant_messages'
  ] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('revoke all on table public.%I from anon', t);
    execute format('grant all on table public.%I to service_role', t);
  end loop;
end;
$$;

-- Přihlášení uživatelé: číst, vkládat a měnit; mazat fyzicky jen členství.
do $$
declare
  t text;
begin
  foreach t in array array[
    'profiles', 'gardens', 'zones', 'inventory_items', 'tasks', 'activities',
    'activity_materials', 'task_materials', 'photos', 'inventory_movements',
    'shopping_items', 'assistant_threads', 'assistant_messages'
  ] loop
    execute format('revoke all on table public.%I from authenticated', t);
    execute format('grant select, insert, update on table public.%I to authenticated', t);
  end loop;
end;
$$;

revoke all on table public.garden_members from authenticated;
grant select, insert, update, delete on table public.garden_members to authenticated;

-- entitlements a assistant_usage: uživatel jen čte.
revoke all on table public.entitlements from authenticated;
grant select on table public.entitlements to authenticated;
revoke all on table public.assistant_usage from authenticated;
grant select on table public.assistant_usage to authenticated;

-- Pomocné funkce: volají je pravidla RLS jménem přihlášeného uživatele.
revoke all on all functions in schema private from public;
grant execute on function private.is_garden_member(uuid, text[]) to authenticated, service_role;
grant execute on function private.path_garden_id(text) to authenticated, service_role;
grant execute on function private.try_uuid(text) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- profiles
-- ---------------------------------------------------------------------------

create policy profiles_select_own on public.profiles
  for select to authenticated
  using (id = (select auth.uid()));

create policy profiles_insert_own on public.profiles
  for insert to authenticated
  with check (id = (select auth.uid()));

create policy profiles_update_own on public.profiles
  for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- ---------------------------------------------------------------------------
-- entitlements, assistant_usage – jen čtení vlastního řádku
-- ---------------------------------------------------------------------------

create policy entitlements_select_own on public.entitlements
  for select to authenticated
  using (user_id = (select auth.uid()));

create policy assistant_usage_select_own on public.assistant_usage
  for select to authenticated
  using (user_id = (select auth.uid()));

-- ---------------------------------------------------------------------------
-- gardens
-- ---------------------------------------------------------------------------

-- owner_id = auth.uid() je tu kvůli INSERT … RETURNING: členství vlastníka
-- vzniká až v AFTER triggeru.
create policy gardens_select_member on public.gardens
  for select to authenticated
  using (owner_id = (select auth.uid()) or private.is_garden_member(id));

create policy gardens_insert_own on public.gardens
  for insert to authenticated
  with check (owner_id = (select auth.uid()));

create policy gardens_update_editor on public.gardens
  for update to authenticated
  using (private.is_garden_member(id, array['owner', 'editor']))
  with check (private.is_garden_member(id, array['owner', 'editor']));

-- ---------------------------------------------------------------------------
-- garden_members – číst smí členové, spravovat jen owner
-- ---------------------------------------------------------------------------

create policy garden_members_select_member on public.garden_members
  for select to authenticated
  using (private.is_garden_member(garden_id));

-- Owner přidává editory a diváky; roli owner předává jen backend.
create policy garden_members_insert_owner on public.garden_members
  for insert to authenticated
  with check (
    private.is_garden_member(garden_id, array['owner'])
    and role in ('editor', 'viewer')
  );

create policy garden_members_update_owner on public.garden_members
  for update to authenticated
  using (
    private.is_garden_member(garden_id, array['owner'])
    and role in ('editor', 'viewer')
  )
  with check (
    private.is_garden_member(garden_id, array['owner'])
    and role in ('editor', 'viewer')
  );

-- Owner odebírá ostatní členy; člen (ne owner) může zahradu sám opustit.
create policy garden_members_delete_owner_or_self on public.garden_members
  for delete to authenticated
  using (
    role in ('editor', 'viewer')
    and (
      private.is_garden_member(garden_id, array['owner'])
      or user_id = (select auth.uid())
    )
  );

-- ---------------------------------------------------------------------------
-- Data zahrady – stejná pravidla pro všechny tabulky s garden_id
-- ---------------------------------------------------------------------------

do $$
declare
  t text;
begin
  foreach t in array array[
    'zones', 'inventory_items', 'tasks', 'activities', 'activity_materials',
    'task_materials', 'photos', 'inventory_movements', 'shopping_items'
  ] loop
    execute format($f$
      create policy %I on public.%I
        for select to authenticated
        using (private.is_garden_member(garden_id))
    $f$, t || '_select_member', t);

    execute format($f$
      create policy %I on public.%I
        for insert to authenticated
        with check (private.is_garden_member(garden_id, array['owner', 'editor']))
    $f$, t || '_insert_editor', t);

    execute format($f$
      create policy %I on public.%I
        for update to authenticated
        using (private.is_garden_member(garden_id, array['owner', 'editor']))
        with check (private.is_garden_member(garden_id, array['owner', 'editor']))
    $f$, t || '_update_editor', t);
  end loop;
end;
$$;

-- ---------------------------------------------------------------------------
-- assistant_threads, assistant_messages – jen vlastník konverzace
-- ---------------------------------------------------------------------------

create policy assistant_threads_select_own on public.assistant_threads
  for select to authenticated
  using (user_id = (select auth.uid()));

create policy assistant_threads_insert_own on public.assistant_threads
  for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and (garden_id is null or private.is_garden_member(garden_id))
  );

create policy assistant_threads_update_own on public.assistant_threads
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (
    user_id = (select auth.uid())
    and (garden_id is null or private.is_garden_member(garden_id))
  );

create policy assistant_messages_select_own on public.assistant_messages
  for select to authenticated
  using (user_id = (select auth.uid()));

create policy assistant_messages_insert_own on public.assistant_messages
  for insert to authenticated
  with check (user_id = (select auth.uid()));

create policy assistant_messages_update_own on public.assistant_messages
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));
