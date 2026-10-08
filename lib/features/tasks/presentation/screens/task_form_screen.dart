import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/discard_guard.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/formatting/dates.dart';
import '../../../../core/time/calendar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/text/numbers.dart';
import '../../../inventory/domain/inventory_item.dart';
import '../../../inventory/domain/units.dart';
import '../../../inventory/presentation/inventory_controller.dart';
import '../../../inventory/presentation/inventory_ui.dart';
import '../../../zones/presentation/zones_controller.dart';
import '../../domain/recurrence.dart';
import '../../domain/task_entity.dart';
import '../task_ui.dart';
import '../tasks_controller.dart';

/// Nový úkol, nebo úprava existujícího ([initial]).
class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({super.key, this.initial, this.initialDue});

  final TaskEntity? initial;
  final DateTime? initialDue;

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _notes;
  late DateTime _due;
  int? _remindAt;
  String? _zoneId;
  RepeatFrequency? _frequency;
  Set<int> _months = {};
  int? _duration;
  late List<String> _tools;
  late List<TaskMaterial> _materials;
  final _toolInput = TextEditingController();
  bool _saving = false;
  late final String _initialState;

  static const _durations = [15, 30, 45, 60, 90, 120, 180, 240, 360, 480];

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final t = widget.initial;
    _title = TextEditingController(text: t?.title ?? '');
    _notes = TextEditingController(text: t?.notes ?? '');
    _due = t?.due ?? dayOnly(widget.initialDue ?? ref.read(clockProvider)());
    _remindAt = t?.remindAt;
    _zoneId = t?.zoneId;
    final r = t?.recurrence;
    _frequency = r?.frequency;
    _months = {...?r?.months};
    _duration = t?.durationEstMin;
    _tools = [...?t?.tools];
    _materials = [...?t?.materials];
    _initialState = _snapshot();
  }

  String _snapshot() => [
    _title.text,
    _notes.text,
    _due,
    _remindAt,
    _zoneId,
    _frequency,
    (_months.toList()..sort()).join(','),
    _duration,
    _tools.join(','),
    _materials.map((m) => '${m.itemId}:${m.qty}').join(','),
  ].join('|');

  void _addTool() {
    final tool = _toolInput.text.trim();
    if (tool.isEmpty) return;
    setState(() {
      if (!_tools.any((t) => t.toLowerCase() == tool.toLowerCase())) {
        _tools.add(tool);
      }
      _toolInput.clear();
    });
  }

  Future<void> _addMaterial() async {
    final material = await showDialog<TaskMaterial>(
      context: context,
      builder: (_) => const _MaterialDialog(),
    );
    if (material == null) return;
    setState(() {
      _materials = [
        ..._materials.where((m) => m.itemId != material.itemId),
        material,
      ];
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _toolInput.dispose();
    super.dispose();
  }

  Future<void> _pickDue() async {
    final now = ref.read(clockProvider)();
    final picked = await showDatePicker(
      context: context,
      initialDate: _due,
      // Starý úkol může mít termín před touhle hranicí.
      firstDate: _due.isBefore(DateTime(now.year - 1))
          ? _due
          : DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _due = dayOnly(picked));
  }

  Future<void> _pickReminder() async {
    final current = _remindAt ?? 9 * 60;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked != null) {
      setState(() => _remindAt = picked.hour * 60 + picked.minute);
    }
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    final l = AppLocalizations.of(context);
    setState(() => _saving = true);

    final frequency = _frequency;
    final rrule = frequency == null
        ? null
        : Recurrence.forDue(frequency, _due, months: _months).toRrule();
    final notes = _notes.text.trim();
    final controller = ref.read(tasksControllerProvider.notifier);
    final initial = widget.initial;

    if (initial == null) {
      await controller.create(
        TaskEntity(
          id: '',
          title: _title.text.trim(),
          due: _due,
          zoneId: _zoneId,
          remindAt: _remindAt,
          rrule: rrule,
          notes: notes.isEmpty ? null : notes,
          durationEstMin: _duration,
          tools: _tools,
          materials: _materials,
        ),
      );
    } else {
      await controller.save(
        initial.copyWith(
          title: _title.text.trim(),
          due: _due,
          // Nový termín ruší dřívější odložení.
          snoozedUntil: initial.due == _due ? null : () => null,
          zoneId: () => _zoneId,
          remindAt: () => _remindAt,
          rrule: () => rrule,
          notes: () => notes.isEmpty ? null : notes,
          durationEstMin: () => _duration,
          tools: _tools,
          materials: _materials,
        ),
      );
    }

    if (!mounted) return;
    if (ref.read(tasksControllerProvider).hasError) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.taskSaveFailed)));
      return;
    }
    // O oprávnění k notifikacím se žádá až ve chvíli, kdy dává smysl.
    await ref.read(notificationSchedulerProvider).requestPermission();
    if (mounted) Navigator.of(context).pop();
  }

  Widget _materialTile(AppLocalizations l, TaskMaterial m) {
    final item = ref.watch(inventoryItemProvider(m.itemId));
    final unit = InventoryUnit.fromKey(m.unit);
    final name = item?.name ?? l.taskMaterialMissing;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        item == null
            ? Icons.help_outline
            : inventoryCategoryIcon(item.category),
      ),
      title: Text(name),
      subtitle: Text(
        unit == null ? formatDecimal(m.qty) : formatQty(l, m.qty, unit),
      ),
      trailing: IconButton(
        tooltip: l.taskMaterialRemove(name),
        icon: const Icon(Icons.close),
        onPressed: () => setState(
          () => _materials = [
            for (final x in _materials)
              if (x.itemId != m.itemId) x,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final zones = ref.watch(activeZonesProvider);
    final zoneIds = zones.map((z) => z.id).toSet();
    final allZones = ref.watch(zonesControllerProvider).value ?? const [];
    // Archivovaná zóna upravovaného úkolu zůstane v nabídce.
    final current = allZones.where(
      (z) => z.id == _zoneId && !zoneIds.contains(z.id),
    );

    return DiscardGuard(
      hasChanges: () => _snapshot() != _initialState,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEdit ? l.taskEditTitle : l.taskNewTitle),
          actions: [
            TextButton(
              onPressed: _saving ? null : _submit,
              child: Text(l.commonSave),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _title,
                autofocus: !_isEdit,
                decoration: InputDecoration(
                  labelText: l.taskTitleLabel,
                  hintText: l.taskTitleHint,
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? l.taskTitleRequired : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: Text(l.taskDueLabel),
                subtitle: Text(
                  capitalize(
                    DateFormat('EEEE d. M. y', appLocale).format(_due),
                  ),
                ),
                onTap: _pickDue,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.notifications_outlined),
                title: Text(l.taskReminderLabel),
                subtitle: Text(
                  _remindAt == null
                      ? l.taskReminderOff
                      : l.taskReminderAt(formatMinuteOfDay(_remindAt!)),
                ),
                value: _remindAt != null,
                onChanged: (on) {
                  if (on) {
                    _pickReminder();
                  } else {
                    setState(() => _remindAt = null);
                  }
                },
              ),
              if (_remindAt != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _pickReminder,
                    child: Text(l.taskReminderChange),
                  ),
                ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: _zoneId,
                decoration: InputDecoration(labelText: l.taskZoneLabel),
                isExpanded: true,
                items: [
                  DropdownMenuItem(value: null, child: Text(l.taskNoZone)),
                  for (final z in [...zones, ...current])
                    DropdownMenuItem(value: z.id, child: Text(z.name)),
                ],
                onChanged: (v) => setState(() => _zoneId = v),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int?>(
                initialValue: _duration,
                isExpanded: true,
                decoration: InputDecoration(labelText: l.taskDurationLabel),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(l.taskDurationNone),
                  ),
                  for (final m in {..._durations, ?_duration})
                    DropdownMenuItem(
                      value: m,
                      child: Text(formatDuration(l, m)),
                    ),
                ],
                onChanged: (v) => setState(() => _duration = v),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RepeatFrequency?>(
                initialValue: _frequency,
                decoration: InputDecoration(labelText: l.taskRepeatLabel),
                items: [
                  DropdownMenuItem(value: null, child: Text(l.repeatNone)),
                  DropdownMenuItem(
                    value: RepeatFrequency.weekly,
                    child: Text(l.repeatWeekly),
                  ),
                  DropdownMenuItem(
                    value: RepeatFrequency.monthly,
                    child: Text(l.repeatMonthly),
                  ),
                  DropdownMenuItem(
                    value: RepeatFrequency.yearly,
                    child: Text(l.repeatYearly),
                  ),
                ],
                onChanged: (v) => setState(() => _frequency = v),
              ),
              if (_frequency == RepeatFrequency.weekly ||
                  _frequency == RepeatFrequency.monthly) ...[
                const SizedBox(height: 12),
                Text(
                  l.taskRepeatMonthsLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (var m = 1; m <= 12; m++)
                      FilterChip(
                        label: Text(
                          DateFormat.MMM(appLocale).format(DateTime(2000, m)),
                        ),
                        selected: _months.contains(m),
                        onSelected: (on) => setState(() {
                          if (on) {
                            _months.add(m);
                          } else {
                            _months.remove(m);
                          }
                        }),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Text(
                l.taskToolsLabel,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (_tools.isNotEmpty)
                Wrap(
                  spacing: 6,
                  children: [
                    for (final tool in _tools)
                      InputChip(
                        label: Text(tool),
                        deleteButtonTooltipMessage: l.taskToolRemove(tool),
                        onDeleted: () => setState(() => _tools.remove(tool)),
                      ),
                  ],
                ),
              TextField(
                controller: _toolInput,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: l.taskToolsHint,
                  suffixIcon: IconButton(
                    tooltip: l.taskToolAdd,
                    icon: const Icon(Icons.add),
                    onPressed: _addTool,
                  ),
                ),
                onSubmitted: (_) => _addTool(),
              ),
              const SizedBox(height: 16),
              Text(
                l.taskMaterialsLabel,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              for (final m in _materials) _materialTile(l, m),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addMaterial,
                  icon: const Icon(Icons.add),
                  label: Text(l.taskMaterialAdd),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notes,
                decoration: InputDecoration(labelText: l.taskNotesLabel),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: const Icon(Icons.check),
                label: Text(_isEdit ? l.activitySaveChanges : l.taskSaveNew),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Výběr položky skladu a množství pro úkol.
class _MaterialDialog extends ConsumerStatefulWidget {
  const _MaterialDialog();

  @override
  ConsumerState<_MaterialDialog> createState() => _MaterialDialogState();
}

class _MaterialDialogState extends ConsumerState<_MaterialDialog> {
  final _qty = TextEditingController();
  InventoryItem? _item;
  InventoryUnit? _unit;
  String? _qtyError;

  @override
  void dispose() {
    _qty.dispose();
    super.dispose();
  }

  void _submit() {
    final item = _item;
    final unit = _unit;
    final qty = parseDecimal(_qty.text);
    if (item == null || unit == null) return;
    if (qty == null || qty <= 0) {
      setState(
        () => _qtyError = AppLocalizations.of(context).taskMaterialQtyInvalid,
      );
      return;
    }
    Navigator.of(
      context,
    ).pop(TaskMaterial(itemId: item.id, qty: qty, unit: unit.name));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = ref.watch(inventoryControllerProvider).value ?? const [];
    final item = _item;
    return AlertDialog(
      title: Text(l.taskMaterialAdd),
      content: items.isEmpty
          ? Text(l.taskMaterialNoInventory)
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<InventoryItem>(
                  initialValue: item,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l.taskMaterialItemLabel,
                  ),
                  items: [
                    for (final i in items)
                      DropdownMenuItem(value: i, child: Text(i.name)),
                  ],
                  onChanged: (i) => setState(() {
                    _item = i;
                    _unit = i?.unit;
                  }),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _qty,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l.taskMaterialQtyLabel,
                          errorText: _qtyError,
                        ),
                        onChanged: (_) {
                          if (_qtyError != null) {
                            setState(() => _qtyError = null);
                          }
                        },
                        onSubmitted: (_) => _submit(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DropdownButton<InventoryUnit>(
                        value: _unit,
                        isExpanded: true,
                        items: [
                          for (final u
                              in item?.unit.compatible ?? InventoryUnit.values)
                            DropdownMenuItem(
                              value: u,
                              child: Text(unitLabel(l, u)),
                            ),
                        ],
                        onChanged: item == null
                            ? null
                            : (u) => setState(() => _unit = u ?? _unit),
                      ),
                    ),
                  ],
                ),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.commonCancel),
        ),
        if (items.isNotEmpty)
          FilledButton(onPressed: _submit, child: Text(l.commonSave)),
      ],
    );
  }
}
