import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/text/numbers.dart';
import '../../../l10n/app_localizations.dart';
import '../../zones/presentation/zones_controller.dart';
import '../domain/build_design.dart';
import '../domain/build_params.dart';
import '../domain/build_plan.dart';
import '../domain/calculators.dart';
import 'build_drawing.dart';
import 'build_ui.dart';
import 'builds_controller.dart';
import 'builds_screen.dart';

/// Návrh stavby: parametry, výkres, mantinely, výkaz materiálu a rozpočet
/// (FR-G1 až FR-G3). Všechno se přepočítá hned při změně parametru.
class BuildEditorScreen extends ConsumerStatefulWidget {
  const BuildEditorScreen({
    required this.initial,
    this.isNew = false,
    super.key,
  });

  final BuildDesign initial;
  final bool isNew;

  @override
  ConsumerState<BuildEditorScreen> createState() => _BuildEditorScreenState();
}

class _BuildEditorScreenState extends ConsumerState<BuildEditorScreen> {
  late BuildDesign _design = widget.initial;
  late final _name = TextEditingController(text: widget.initial.name);
  late final Map<String, TextEditingController> _numbers = {
    for (final spec in widget.initial.template.params)
      if (spec is NumberParam)
        spec.key: TextEditingController(
          text: formatDecimal(widget.initial.values.number(spec.key)),
        ),
  };
  final Map<String, String> _errors = {};
  String? _nameError;
  bool _done = false;

  @override
  void dispose() {
    _name.dispose();
    for (final c in _numbers.values) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _dirty =>
      _design.copyWith(name: _name.text) != widget.initial ||
      (widget.isNew && _name.text != widget.initial.name);

  void _set(String key, Object value) => setState(
    () =>
        _design = _design.copyWith(values: _design.values.copyWith(key, value)),
  );

  void _number(NumberParam spec, String text) {
    final l = AppLocalizations.of(context);
    final value = parseDecimal(text);
    if (value == null || value < spec.min || value > spec.max) {
      setState(
        () => _errors[spec.key] = l.buildsRangeError(
          formatDecimal(spec.min),
          formatDecimal(spec.max),
        ),
      );
      return;
    }
    _errors.remove(spec.key);
    _set(spec.key, value);
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (_name.text.trim().isEmpty) {
      setState(() => _nameError = l.buildsNameRequired);
      return;
    }
    if (_errors.isNotEmpty) {
      // Pole s chybou drží poslední platnou hodnotu; uložit ji potichu nejde.
      messenger.showSnackBar(SnackBar(content: Text(l.buildsFixParams)));
      return;
    }
    final navigator = Navigator.of(context);
    await ref
        .read(buildsControllerProvider.notifier)
        .save(_design.copyWith(name: _name.text));
    if (!mounted) return;
    final state = ref.read(buildsControllerProvider);
    if (state.hasError) {
      messenger.showSnackBar(SnackBar(content: Text(l.commonSaveFailed)));
      return;
    }
    _done = true;
    messenger.showSnackBar(SnackBar(content: Text(l.buildsSaved)));
    navigator.pop();
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.buildsDeleteTitle),
        content: Text(l.buildsDeleteBody(widget.initial.name)),
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
    if (ok != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await ref.read(buildsControllerProvider.notifier).delete(widget.initial.id);
    _done = true;
    messenger.showSnackBar(SnackBar(content: Text(l.buildsDeleted)));
    navigator.pop();
  }

  Future<void> _confirmLeave() async {
    final l = AppLocalizations.of(context);
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.buildsDiscardTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.buildsDiscardKeep),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.buildsDiscardConfirm),
          ),
        ],
      ),
    );
    if (leave == true && mounted) {
      _done = true;
      Navigator.of(context).pop();
    }
  }

  Future<void> _editPrice(BuildMaterial material) async {
    // null = zrušit, NaN = výchozí cena.
    final result = await showDialog<double>(
      context: context,
      builder: (_) => _PriceDialog(
        material: material,
        current: BuildPlan.priceOf(material, _design.prices),
      ),
    );
    if (result == null || !mounted) return;
    final prices = {..._design.prices}..remove(material.name);
    if (!result.isNaN) prices[material.name] = result;
    setState(() => _design = _design.copyWith(prices: prices));
  }

  Future<void> _addToShopping(BuildPlan plan) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final added = await ref
        .read(buildsControllerProvider.notifier)
        .addToShopping(
          plan.bom,
          (line, {required withQuantity}) => withQuantity
              ? '${materialLabel(l, line.material)} '
                    '(${formatDecimal(line.quantity)} '
                    '${unitLabel(l, line.material.unit)})'
              : materialLabel(l, line.material),
        );
    messenger.showSnackBar(
      SnackBar(content: Text(l.buildsAddedToShopping(added))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final template = _design.template;
    final plan = planFor(_design.values);
    final zones = ref.watch(activeZonesProvider);
    final zoneId = zones.any((z) => z.id == _design.zoneId)
        ? _design.zoneId
        : null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_done || !_dirty) {
          _done = true;
          Navigator.of(context).pop();
        } else {
          _confirmLeave();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(templateLabel(l, template)),
          actions: [
            if (!widget.isNew)
              IconButton(
                tooltip: l.buildsDelete,
                icon: const Icon(Icons.delete_outline),
                onPressed: _delete,
              ),
            TextButton(onPressed: _save, child: Text(l.commonSave)),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 48),
          children: [
            const DisclaimerCard(),
            if (plan.engineerRecommended)
              Card(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                color: theme.colorScheme.errorContainer,
                child: ListTile(
                  leading: Icon(
                    Icons.engineering_outlined,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  title: Text(
                    l.buildsEngineer,
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _name,
                decoration: InputDecoration(
                  labelText: l.buildsName,
                  errorText: _nameError,
                ),
                onChanged: (_) => setState(() => _nameError = null),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: DropdownButtonFormField<String?>(
                key: ValueKey(zoneId),
                initialValue: zoneId,
                isExpanded: true,
                decoration: InputDecoration(labelText: l.buildsZone),
                items: [
                  DropdownMenuItem(value: null, child: Text(l.buildsNoZone)),
                  for (final z in zones)
                    DropdownMenuItem(value: z.id, child: Text(z.name)),
                ],
                onChanged: (id) => setState(
                  () => _design = _design.copyWith(zoneId: () => id),
                ),
              ),
            ),
            _Header(l.buildsParams),
            for (final spec in template.params) _param(l, spec),
            _Header(
              plan.drawing.view == DrawingView.top
                  ? l.buildsDrawingTop
                  : l.buildsDrawingSection,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BuildDrawingView(
                drawing: plan.drawing,
                label: plan.drawing.view == DrawingView.top
                    ? l.buildsDrawingTop
                    : l.buildsDrawingSection,
              ),
            ),
            for (final line in summaryLines(l, plan))
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Text(line, style: theme.textTheme.bodyMedium),
              ),
            _Header(l.buildsChecks),
            if (plan.findings.isEmpty)
              ListTile(
                leading: Icon(
                  Icons.check_circle_outline,
                  color: theme.colorScheme.primary,
                ),
                title: Text(l.buildsChecksOk),
              ),
            for (final f in plan.findings) _FindingTile(finding: f),
            _Header(l.buildsMaterial),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text(l.buildsPricesNote, style: theme.textTheme.bodySmall),
            ),
            for (final line in plan.bom) _bomTile(l, line),
            ListTile(
              title: Text(
                l.buildsTotal(
                  formatDecimal(plan.total(_design.prices).round()),
                ),
                style: theme.textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => _addToShopping(plan),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(l.buildsAddToShopping),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _param(AppLocalizations l, ParamSpec spec) {
    final label = paramLabel(l, _design.template, spec.key);
    final values = _design.values;
    return switch (spec) {
      NumberParam() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: TextField(
          key: ValueKey('param-${spec.key}'),
          controller: _numbers[spec.key],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: label,
            suffixText: l.buildUnitM,
            errorText: _errors[spec.key],
          ),
          onChanged: (text) => _number(spec, text),
        ),
      ),
      ChoiceParam() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: DropdownButtonFormField<String>(
          key: ValueKey('param-${spec.key}'),
          initialValue: values.choice(spec.key),
          isExpanded: true,
          decoration: InputDecoration(
            labelText: label,
            helperText: spec.key == 'snowRegion' ? l.buildsSnowHelp : null,
            helperMaxLines: 4,
          ),
          items: [
            for (final o in spec.options)
              DropdownMenuItem(
                value: o,
                child: Text(optionLabel(l, spec.key, o)),
              ),
          ],
          onChanged: (v) {
            if (v != null) _set(spec.key, v);
          },
        ),
      ),
      ToggleParam() => SwitchListTile(
        key: ValueKey('param-${spec.key}'),
        title: Text(label),
        value: values.toggle(spec.key),
        onChanged: (v) => _set(spec.key, v),
      ),
    };
  }

  Widget _bomTile(AppLocalizations l, BomLine line) {
    final price = BuildPlan.priceOf(line.material, _design.prices);
    final custom = _design.prices.containsKey(line.material.name);
    return ListTile(
      dense: true,
      title: Text(materialLabel(l, line.material)),
      subtitle: Text(
        l.buildsLineTotal(
          formatDecimal(line.quantity),
          unitLabel(l, line.material.unit),
          formatDecimal(price),
        ),
        style: custom
            ? TextStyle(color: Theme.of(context).colorScheme.primary)
            : null,
      ),
      trailing: Text(
        l.buildsLineAmount(formatDecimal((line.quantity * price).round())),
      ),
      onTap: () => _editPrice(line.material),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _FindingTile extends StatelessWidget {
  const _FindingTile({required this.finding});

  final Finding finding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (icon, color) = switch (finding.severity) {
      FindingSeverity.info => (Icons.info_outline, scheme.primary),
      FindingSeverity.warning => (Icons.warning_amber_rounded, scheme.tertiary),
      FindingSeverity.danger => (Icons.dangerous_outlined, scheme.error),
    };
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(findingText(AppLocalizations.of(context), finding)),
    );
  }
}

/// Cena materiálu; vrátí novou cenu, NaN pro výchozí, null pro zrušení.
class _PriceDialog extends StatefulWidget {
  const _PriceDialog({required this.material, required this.current});

  final BuildMaterial material;
  final double current;

  @override
  State<_PriceDialog> createState() => _PriceDialogState();
}

class _PriceDialogState extends State<_PriceDialog> {
  late final _price = TextEditingController(
    text: formatDecimal(widget.current),
  );

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.buildsPriceTitle(materialLabel(l, widget.material))),
      content: TextField(
        controller: _price,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          suffixText: l.buildsPricePerUnit(unitLabel(l, widget.material.unit)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(double.nan),
          child: Text(l.buildsPriceReset),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.commonCancel),
        ),
        FilledButton(
          onPressed: () {
            final v = parseDecimal(_price.text);
            if (v != null && v >= 0) Navigator.of(context).pop(v);
          },
          child: Text(l.commonSave),
        ),
      ],
    );
  }
}
