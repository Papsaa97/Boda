-- Poloha zahrady v synchronizaci (V2, DECLOG D85).
--
-- sync_push nově zapisuje polohu zahrady (gardens.location_lat,
-- location_lng, zaokrouhlené na ~1 km) a nadmořskou výšku (altitude_m)
-- pro počasí a fenologický kalendář. Jinak beze změny proti
-- 20261008000700.

create or replace function public.sync_push(p_changes jsonb)
returns void
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_item jsonb;
  v_table text;
  v_keys text[];
  v_where text;
  v_col text;
begin
  if p_changes is null or jsonb_typeof(p_changes) <> 'object' then
    raise exception 'invalid_changes' using errcode = '22023';
  end if;

  -- Odložené cizí klíče se ověří až na konci transakce.
  set constraints all deferred;

  insert into public.gardens as t (id, name, location_lat, location_lng, altitude_m, bounds, created_at, updated_at)
  select id, name, location_lat, location_lng, altitude_m, bounds, created_at, updated_at
  from jsonb_populate_recordset(null::public.gardens, coalesce(p_changes -> 'gardens', '[]'::jsonb))
  on conflict (id) do update set
      name = excluded.name,
      location_lat = excluded.location_lat,
      location_lng = excluded.location_lng,
      altitude_m = excluded.altitude_m,
      bounds = excluded.bounds,
      updated_at = excluded.updated_at;
  insert into public.zones as t (id, garden_id, name, type, area_m2, soil_texture, ph, ph_measured_at, sun_exposure, irrigation, covered, archived, sort_order, polygon, layer, created_at, updated_at, deleted_at)
  select id, garden_id, name, type, area_m2, soil_texture, ph, ph_measured_at, sun_exposure, irrigation, covered, archived, sort_order, polygon, layer, created_at, updated_at, deleted_at
  from jsonb_populate_recordset(null::public.zones, coalesce(p_changes -> 'zones', '[]'::jsonb))
  on conflict (id) do update set
      name = excluded.name,
      type = excluded.type,
      area_m2 = excluded.area_m2,
      soil_texture = excluded.soil_texture,
      ph = excluded.ph,
      ph_measured_at = excluded.ph_measured_at,
      sun_exposure = excluded.sun_exposure,
      irrigation = excluded.irrigation,
      covered = excluded.covered,
      archived = excluded.archived,
      sort_order = excluded.sort_order,
      polygon = excluded.polygon,
      layer = excluded.layer,
      updated_at = excluded.updated_at,
      deleted_at = excluded.deleted_at;
  insert into public.incidents as t (id, garden_id, zone_id, label, source, candidates, plan_bio, plan_chem, status, created_at, updated_at, deleted_at)
  select id, garden_id, zone_id, label, source, candidates, plan_bio, plan_chem, status, created_at, updated_at, deleted_at
  from jsonb_populate_recordset(null::public.incidents, coalesce(p_changes -> 'incidents', '[]'::jsonb))
  on conflict (id) do update set
      zone_id = excluded.zone_id,
      label = excluded.label,
      source = excluded.source,
      candidates = excluded.candidates,
      plan_bio = excluded.plan_bio,
      plan_chem = excluded.plan_chem,
      status = excluded.status,
      updated_at = excluded.updated_at,
      deleted_at = excluded.deleted_at;
  insert into public.inventory_items as t (id, garden_id, category, name, unit, stock_qty, low_stock_threshold, details, created_at, updated_at, deleted_at)
  select id, garden_id, category, name, unit, stock_qty, low_stock_threshold, details, created_at, updated_at, deleted_at
  from jsonb_populate_recordset(null::public.inventory_items, coalesce(p_changes -> 'inventory_items', '[]'::jsonb))
  on conflict (id) do update set
      category = excluded.category,
      name = excluded.name,
      unit = excluded.unit,
      stock_qty = excluded.stock_qty,
      low_stock_threshold = excluded.low_stock_threshold,
      details = excluded.details,
      updated_at = excluded.updated_at,
      deleted_at = excluded.deleted_at;
  insert into public.tasks as t (id, garden_id, title, zone_id, due, remind_at, rrule, snoozed_until, status, notes, duration_est_min, tools, completed_at, completed_activity_id, source, incident_id, created_at, updated_at, deleted_at)
  select id, garden_id, title, zone_id, due, remind_at, rrule, snoozed_until, status, notes, duration_est_min, tools, completed_at, completed_activity_id, source, incident_id, created_at, updated_at, deleted_at
  from jsonb_populate_recordset(null::public.tasks, coalesce(p_changes -> 'tasks', '[]'::jsonb))
  on conflict (id) do update set
      title = excluded.title,
      zone_id = excluded.zone_id,
      due = excluded.due,
      remind_at = excluded.remind_at,
      rrule = excluded.rrule,
      snoozed_until = excluded.snoozed_until,
      status = excluded.status,
      notes = excluded.notes,
      duration_est_min = excluded.duration_est_min,
      tools = excluded.tools,
      completed_at = excluded.completed_at,
      completed_activity_id = excluded.completed_activity_id,
      source = excluded.source,
      incident_id = excluded.incident_id,
      updated_at = excluded.updated_at,
      deleted_at = excluded.deleted_at;
  insert into public.activities as t (id, garden_id, zone_id, type, title, occurred_at, occurred_tz, notes, harvest_qty, harvest_unit, cost_czk, task_id, created_at, updated_at, deleted_at)
  select id, garden_id, zone_id, type, title, occurred_at, occurred_tz, notes, harvest_qty, harvest_unit, cost_czk, task_id, created_at, updated_at, deleted_at
  from jsonb_populate_recordset(null::public.activities, coalesce(p_changes -> 'activities', '[]'::jsonb))
  on conflict (id) do update set
      zone_id = excluded.zone_id,
      type = excluded.type,
      title = excluded.title,
      occurred_at = excluded.occurred_at,
      occurred_tz = excluded.occurred_tz,
      notes = excluded.notes,
      harvest_qty = excluded.harvest_qty,
      harvest_unit = excluded.harvest_unit,
      cost_czk = excluded.cost_czk,
      task_id = excluded.task_id,
      updated_at = excluded.updated_at,
      deleted_at = excluded.deleted_at;
  insert into public.photos as t (id, garden_id, activity_id, incident_id, storage_path, thumb_path, position, created_at, updated_at, deleted_at)
  select id, garden_id, activity_id, incident_id, storage_path, thumb_path, position, created_at, updated_at, deleted_at
  from jsonb_populate_recordset(null::public.photos, coalesce(p_changes -> 'photos', '[]'::jsonb))
  on conflict (id) do update set
      activity_id = excluded.activity_id,
      incident_id = excluded.incident_id,
      storage_path = excluded.storage_path,
      thumb_path = excluded.thumb_path,
      position = excluded.position,
      updated_at = excluded.updated_at,
      deleted_at = excluded.deleted_at;
  insert into public.inventory_movements as t (id, garden_id, item_id, qty_delta, reason, task_id, at, created_at, updated_at, deleted_at)
  select id, garden_id, item_id, qty_delta, reason, task_id, at, created_at, updated_at, deleted_at
  from jsonb_populate_recordset(null::public.inventory_movements, coalesce(p_changes -> 'inventory_movements', '[]'::jsonb))
  on conflict (id) do update set
      updated_at = excluded.updated_at,
      deleted_at = excluded.deleted_at;
  insert into public.task_materials as t (task_id, item_id, garden_id, qty, unit, created_at, updated_at, deleted_at)
  select task_id, item_id, garden_id, qty, unit, created_at, updated_at, deleted_at
  from jsonb_populate_recordset(null::public.task_materials, coalesce(p_changes -> 'task_materials', '[]'::jsonb))
  on conflict (task_id, item_id) do update set
      qty = excluded.qty,
      unit = excluded.unit,
      updated_at = excluded.updated_at,
      deleted_at = excluded.deleted_at;
  insert into public.activity_materials as t (activity_id, item_id, garden_id, qty, unit, created_at, updated_at, deleted_at)
  select activity_id, item_id, garden_id, qty, unit, created_at, updated_at, deleted_at
  from jsonb_populate_recordset(null::public.activity_materials, coalesce(p_changes -> 'activity_materials', '[]'::jsonb))
  on conflict (activity_id, item_id) do update set
      qty = excluded.qty,
      unit = excluded.unit,
      updated_at = excluded.updated_at,
      deleted_at = excluded.deleted_at;
  insert into public.shopping_items as t (id, garden_id, name, qty, unit, item_id, done, source, created_at, updated_at, deleted_at)
  select id, garden_id, name, qty, unit, item_id, done, source, created_at, updated_at, deleted_at
  from jsonb_populate_recordset(null::public.shopping_items, coalesce(p_changes -> 'shopping_items', '[]'::jsonb))
  on conflict (id) do update set
      name = excluded.name,
      qty = excluded.qty,
      unit = excluded.unit,
      item_id = excluded.item_id,
      done = excluded.done,
      source = excluded.source,
      updated_at = excluded.updated_at,
      deleted_at = excluded.deleted_at;
  insert into public.assistant_threads as t (id, garden_id, title, created_at, updated_at, deleted_at)
  select id, garden_id, title, created_at, updated_at, deleted_at
  from jsonb_populate_recordset(null::public.assistant_threads, coalesce(p_changes -> 'assistant_threads', '[]'::jsonb))
  on conflict (id) do update set
      title = excluded.title,
      updated_at = excluded.updated_at,
      deleted_at = excluded.deleted_at;
  insert into public.assistant_messages as t (id, thread_id, role, text, context_summary, feedback, feedback_comment, created_at, updated_at, deleted_at)
  select id, thread_id, role, text, context_summary, feedback, feedback_comment, created_at, updated_at, deleted_at
  from jsonb_populate_recordset(null::public.assistant_messages, coalesce(p_changes -> 'assistant_messages', '[]'::jsonb))
  on conflict (id) do update set
      thread_id = excluded.thread_id,
      role = excluded.role,
      text = excluded.text,
      context_summary = excluded.context_summary,
      feedback = excluded.feedback,
      feedback_comment = excluded.feedback_comment,
      updated_at = excluded.updated_at,
      deleted_at = excluded.deleted_at;

  for v_item in
    select value from jsonb_array_elements(coalesce(p_changes -> 'deleted', '[]'::jsonb))
  loop
    v_table := v_item ->> 'table';
    v_keys := case v_table
      when 'zones' then array['id']
      when 'incidents' then array['id']
      when 'inventory_movements' then array['id']
      when 'inventory_items' then array['id']
      when 'tasks' then array['id']
      when 'activities' then array['id']
      when 'photos' then array['id']
      when 'task_materials' then array['task_id', 'item_id']
      when 'activity_materials' then array['activity_id', 'item_id']
      when 'shopping_items' then array['id']
      when 'assistant_threads' then array['id']
      when 'assistant_messages' then array['id']
      else null
    end;
    if v_keys is null then
      raise exception 'invalid_table: %', v_table using errcode = '22023';
    end if;
    v_where := '';
    foreach v_col in array v_keys loop
      if (v_item -> 'key' ->> v_col) is null then
        raise exception 'invalid_key' using errcode = '22023';
      end if;
      v_where := v_where || format(' and %I = %L::uuid', v_col, v_item -> 'key' ->> v_col);
    end loop;
    execute format(
      'update public.%I set deleted_at = $1, updated_at = $1 where deleted_at is null%s',
      v_table, v_where
    ) using (v_item ->> 'at')::timestamptz;
  end loop;
end;
$$;

revoke all on function public.sync_push(jsonb) from public, anon;
grant execute on function public.sync_push(jsonb) to authenticated;
