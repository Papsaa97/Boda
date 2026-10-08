import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/formatting/dates.dart';
import '../../../../core/time/calendar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../zones/presentation/zones_controller.dart';
import '../../domain/recurrence.dart';
import '../../domain/task_entity.dart';
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
  bool _saving = false;

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
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDue() async {
    final now = ref.read(clockProvider)();
    final picked = await showDatePicker(
      context: context,
      initialDate: _due,
      firstDate: DateTime(now.year - 1),
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

    return Scaffold(
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
                capitalize(DateFormat('EEEE d. M. y', appLocale).format(_due)),
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
    );
  }
}
