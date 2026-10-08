import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/discard_guard.dart';
import '../../../core/di/providers.dart';
import '../../../core/formatting/dates.dart';
import '../../../core/text/numbers.dart';
import '../../../core/time/calendar.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/inventory_item.dart';
import '../domain/units.dart';
import 'inventory_controller.dart';
import 'inventory_ui.dart';

/// Nová položka skladu, nebo úprava existující ([initial]). Pole se mění
/// podle kategorie (FR-S1).
class InventoryFormScreen extends ConsumerStatefulWidget {
  const InventoryFormScreen({super.key, this.initial});

  final InventoryItem? initial;

  @override
  ConsumerState<InventoryFormScreen> createState() =>
      _InventoryFormScreenState();
}

class _InventoryFormScreenState extends ConsumerState<InventoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _c = <String, TextEditingController>{};
  late InventoryCategory _category;
  late InventoryUnit _unit;
  InventoryUnit _doseUnit = InventoryUnit.g;
  DateTime? _bestBefore;
  DateTime? _lastService;
  FertilizerForm? _form;
  ToolCondition? _condition;
  bool _nonProfessional = false;
  bool _saving = false;
  late final String _initialState;

  TextEditingController _ctl(String key) =>
      _c.putIfAbsent(key, TextEditingController.new);

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _category = i?.category ?? InventoryCategory.seed;
    _unit = i?.unit ?? InventoryUnit.pack;
    String num(double? v) => v == null ? '' : formatDecimal(v);
    _ctl('name').text = i?.name ?? '';
    _ctl('stock').text = i == null ? '' : num(i.stockQty);
    _ctl('threshold').text = num(i?.lowStockThreshold);
    final dose = i?.labelDose;
    if (dose != null) {
      _ctl('dose').text = num(dose.amount);
      _doseUnit = dose.unit;
    }
    switch (i?.details) {
      case final SeedDetails d:
        _ctl('species').text = d.species ?? '';
        _ctl('variety').text = d.variety ?? '';
        _ctl('lot').text = d.lot ?? '';
        _bestBefore = d.bestBefore;
      case final FertilizerDetails d:
        _ctl('n').text = num(d.n);
        _ctl('p').text = num(d.p);
        _ctl('k').text = num(d.k);
        _form = d.form;
      case final PlantProtectionDetails d:
        _ctl('substance').text = d.activeSubstance ?? '';
        _ctl('authorization').text = d.authorizationNo ?? '';
        _ctl('phi').text = d.phiDays?.toString() ?? '';
        _nonProfessional = d.nonProfessional;
      case final ToolDetails d:
        _condition = d.condition;
        _ctl('interval').text = d.serviceIntervalDays?.toString() ?? '';
        _lastService = d.lastServiceAt;
      case null:
        break;
    }
    _initialState = _snapshot();
  }

  String _snapshot() => [
    ([
      for (final e in _c.entries)
        if (e.value.text.isNotEmpty) '${e.key}=${e.value.text}',
    ]..sort()).join(','),
    _category,
    _unit,
    _doseUnit,
    _bestBefore,
    _lastService,
    _form,
    _condition,
    _nonProfessional,
  ].join('|');

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  String? _text(String key) {
    final v = _ctl(key).text.trim();
    return v.isEmpty ? null : v;
  }

  double? _number(String key) => parseDecimal(_ctl(key).text);

  /// Validátor nepovinného nezáporného čísla.
  String? _optionalNumber(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final n = parseDecimal(v);
    if (n == null || n < 0) {
      return AppLocalizations.of(context).inventoryNumberInvalid;
    }
    return null;
  }

  LabelDose? _dose() {
    final amount = _number('dose');
    return amount == null || amount <= 0 ? null : LabelDose(amount, _doseUnit);
  }

  ItemDetails? _details() => switch (_category) {
    InventoryCategory.seed => SeedDetails(
      species: _text('species'),
      variety: _text('variety'),
      lot: _text('lot'),
      bestBefore: _bestBefore,
    ),
    InventoryCategory.fertilizer => FertilizerDetails(
      n: _number('n'),
      p: _number('p'),
      k: _number('k'),
      form: _form,
      dose: _dose(),
    ),
    InventoryCategory.plantProtection => PlantProtectionDetails(
      activeSubstance: _text('substance'),
      authorizationNo: _text('authorization'),
      phiDays: _number('phi')?.round(),
      nonProfessional: _nonProfessional,
      dose: _dose(),
    ),
    InventoryCategory.tool => ToolDetails(
      condition: _condition,
      serviceIntervalDays: _number('interval')?.round(),
      lastServiceAt: _lastService,
    ),
    InventoryCategory.other => null,
  };

  Future<void> _submit() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    final item = InventoryItem(
      id: widget.initial?.id ?? '',
      category: _category,
      name: _ctl('name').text,
      unit: _unit,
      stockQty: _number('stock') ?? 0,
      lowStockThreshold: _number('threshold'),
      details: _details(),
    );
    final saved = await ref
        .read(inventoryControllerProvider.notifier)
        .save(item);
    if (!mounted) return;
    if (saved == null) {
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(l.inventorySaveFailed)));
      return;
    }
    Navigator.of(context).pop(saved);
  }

  Future<void> _delete() async {
    final item = widget.initial;
    if (item == null) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.inventoryDeleteTitle),
        content: Text(l.inventoryDeleteBody(item.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.commonDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(inventoryControllerProvider.notifier).delete(item.id);
    if (ref.read(inventoryControllerProvider).hasError) {
      messenger.showSnackBar(SnackBar(content: Text(l.inventorySaveFailed)));
      return;
    }
    messenger.showSnackBar(
      SnackBar(content: Text(l.inventoryDeleted(item.name))),
    );
    navigator.pop();
  }

  Future<DateTime?> _pickDate(DateTime? initial, {bool future = false}) {
    final now = ref.read(clockProvider)();
    return showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: future ? DateTime(now.year + 10) : now,
    );
  }

  Widget _field(
    String key,
    String label, {
    bool number = false,
    String? helper,
    String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: _ctl(key),
      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      textCapitalization: number
          ? TextCapitalization.none
          : TextCapitalization.sentences,
      decoration: InputDecoration(labelText: label, helperText: helper),
      validator: validator ?? (number ? _optionalNumber : null),
    ),
  );

  Widget _dateTile(
    String label,
    DateTime? value,
    ValueChanged<DateTime> onPicked, {
    bool future = false,
  }) {
    final l = AppLocalizations.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event),
      title: Text(label),
      subtitle: Text(value == null ? l.inventoryDateNone : formatDate(value)),
      onTap: () async {
        final picked = await _pickDate(value, future: future);
        if (picked != null) setState(() => onPicked(dayOnly(picked)));
      },
    );
  }

  Widget _doseRow(AppLocalizations l) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: _ctl('dose'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l.inventoryDoseLabel,
              helperText: l.inventoryDoseHelper,
              helperMaxLines: 3,
            ),
            validator: _optionalNumber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<InventoryUnit>(
            initialValue: _doseUnit,
            isExpanded: true,
            decoration: InputDecoration(labelText: l.inventoryUnitLabel),
            items: [
              for (final u in const [InventoryUnit.g, InventoryUnit.ml])
                DropdownMenuItem(value: u, child: Text(unitLabel(l, u))),
            ],
            onChanged: (u) => setState(() => _doseUnit = u ?? _doseUnit),
          ),
        ),
      ],
    ),
  );

  List<Widget> _categoryFields(AppLocalizations l) => switch (_category) {
    InventoryCategory.seed => [
      _field('species', l.inventorySpeciesLabel),
      _field('variety', l.inventoryVarietyLabel),
      _field('lot', l.inventoryLotLabel),
      _dateTile(
        l.inventoryBestBeforeLabel,
        _bestBefore,
        (d) => _bestBefore = d,
        future: true,
      ),
    ],
    InventoryCategory.fertilizer => [
      Text(l.inventoryNpkLabel, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(child: _field('n', l.inventoryNLabel, number: true)),
          const SizedBox(width: 8),
          Expanded(child: _field('p', l.inventoryPLabel, number: true)),
          const SizedBox(width: 8),
          Expanded(child: _field('k', l.inventoryKLabel, number: true)),
        ],
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: DropdownButtonFormField<FertilizerForm?>(
          initialValue: _form,
          isExpanded: true,
          decoration: InputDecoration(labelText: l.inventoryFormLabel),
          items: [
            DropdownMenuItem(value: null, child: Text(l.zoneNotSet)),
            for (final f in FertilizerForm.values)
              DropdownMenuItem(
                value: f,
                child: Text(fertilizerFormLabel(l, f)),
              ),
          ],
          onChanged: (f) => setState(() => _form = f),
        ),
      ),
      _doseRow(l),
    ],
    InventoryCategory.plantProtection => [
      Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(l.inventoryLabelWarning),
        ),
      ),
      _field('substance', l.inventoryActiveSubstanceLabel),
      _field('authorization', l.inventoryAuthorizationLabel),
      _field('phi', l.inventoryPhiLabel, number: true),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(l.inventoryNonProfessionalLabel),
        value: _nonProfessional,
        onChanged: (v) => setState(() => _nonProfessional = v),
      ),
      const SizedBox(height: 8),
      _doseRow(l),
    ],
    InventoryCategory.tool => [
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: DropdownButtonFormField<ToolCondition?>(
          initialValue: _condition,
          isExpanded: true,
          decoration: InputDecoration(labelText: l.inventoryConditionLabel),
          items: [
            DropdownMenuItem(value: null, child: Text(l.zoneNotSet)),
            for (final c in ToolCondition.values)
              DropdownMenuItem(value: c, child: Text(toolConditionLabel(l, c))),
          ],
          onChanged: (c) => setState(() => _condition = c),
        ),
      ),
      _field('interval', l.inventoryServiceIntervalLabel, number: true),
      _dateTile(
        l.inventoryLastServiceLabel,
        _lastService,
        (d) => _lastService = d,
      ),
    ],
    InventoryCategory.other => const [],
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DiscardGuard(
      hasChanges: () => _snapshot() != _initialState,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEdit ? l.inventoryEditTitle : l.inventoryNewTitle),
          actions: [
            if (_isEdit)
              IconButton(
                tooltip: l.commonDelete,
                icon: const Icon(Icons.delete_outline),
                onPressed: _delete,
              ),
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
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonFormField<InventoryCategory>(
                  initialValue: _category,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l.inventoryCategoryLabel,
                  ),
                  items: [
                    for (final c in InventoryCategory.values)
                      DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(inventoryCategoryIcon(c), size: 20),
                            const SizedBox(width: 12),
                            Flexible(child: Text(inventoryCategoryLabel(l, c))),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (c) => setState(() => _category = c ?? _category),
                ),
              ),
              _field(
                'name',
                l.inventoryNameLabel,
                validator: (v) => v == null || v.trim().isEmpty
                    ? l.inventoryNameRequired
                    : null,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _field('stock', l.inventoryStockLabel, number: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<InventoryUnit>(
                      initialValue: _unit,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l.inventoryUnitLabel,
                      ),
                      items: [
                        for (final u in InventoryUnit.values)
                          DropdownMenuItem(
                            value: u,
                            child: Text(unitLabel(l, u)),
                          ),
                      ],
                      onChanged: (u) => setState(() => _unit = u ?? _unit),
                    ),
                  ),
                ],
              ),
              _field(
                'threshold',
                l.inventoryThresholdLabel,
                number: true,
                helper: l.inventoryThresholdHelper,
              ),
              ..._categoryFields(l),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: const Icon(Icons.check),
                label: Text(l.commonSave),
              ),
              if (widget.initial case final item?) _History(item: item),
            ],
          ),
        ),
      ),
    );
  }
}

/// Posledních 20 pohybů položky (FR-S4).
class _History extends ConsumerWidget {
  const _History({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final movements = ref.watch(stockMovementsProvider(item.id)).value;
    if (movements == null || movements.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.movementHistoryTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final m in movements.take(20))
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: Icon(
                m.qtyDelta < 0 ? Icons.remove_circle_outline : Icons.add,
              ),
              title: Text(movementReasonLabel(l, m.reason)),
              subtitle: Text(formatDate(m.at)),
              trailing: Text(
                '${m.qtyDelta > 0 ? '+' : '−'}'
                '${formatQty(l, m.qtyDelta.abs(), item.unit)}',
              ),
            ),
        ],
      ),
    );
  }
}
