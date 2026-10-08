import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/formatting/dates.dart';
import '../../../core/text/numbers.dart';
import '../../../core/time/calendar.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/zone_entity.dart';
import '../domain/zone_rules.dart';
import 'zone_icons.dart';
import 'zones_controller.dart';

/// Úprava zóny včetně vlastností (spec 4.2, MVP 1.0 bod 2): výměra
/// zadaná číslem, půda, pH s datem měření, oslunění, závlaha, krytí.
class ZoneFormScreen extends ConsumerStatefulWidget {
  const ZoneFormScreen({super.key, required this.zone});

  final ZoneEntity zone;

  @override
  ConsumerState<ZoneFormScreen> createState() => _ZoneFormScreenState();
}

class _ZoneFormScreenState extends ConsumerState<ZoneFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _area;
  late final TextEditingController _ph;
  late ZoneType _type;
  SoilTexture? _soil;
  SunExposure? _sun;
  Irrigation? _irrigation;
  DateTime? _phMeasuredAt;
  late bool _covered;
  ZoneNameError? _nameError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final z = widget.zone;
    _name = TextEditingController(text: z.name);
    _area = TextEditingController(
      text: z.areaM2 == null ? '' : formatDecimal(z.areaM2!),
    );
    _ph = TextEditingController(
      text: z.ph == null ? '' : formatDecimal(z.ph!, maxFractionDigits: 1),
    );
    _type = z.type;
    _soil = z.soilTexture;
    _sun = z.sunExposure;
    _irrigation = z.irrigation;
    _phMeasuredAt = z.phMeasuredAt;
    _covered = z.covered;
  }

  @override
  void dispose() {
    _name.dispose();
    _area.dispose();
    _ph.dispose();
    super.dispose();
  }

  String? _numberError(
    AppLocalizations l,
    ZonePropertyError? e,
    String range,
  ) => switch (e) {
    ZonePropertyError.notANumber => l.zoneNumberInvalid,
    ZonePropertyError.outOfRange => range,
    null => null,
  };

  Future<void> _pickPhDate() async {
    final now = ref.read(clockProvider)();
    final picked = await showDatePicker(
      context: context,
      initialDate: _phMeasuredAt ?? now,
      firstDate: DateTime(now.year - 20),
      lastDate: now,
    );
    if (picked != null) setState(() => _phMeasuredAt = dayOnly(picked));
  }

  Future<void> _submit() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    final ph = parseDecimal(_ph.text);
    final zone = widget.zone.copyWith(
      name: _name.text,
      type: _type,
      areaM2: () => parseDecimal(_area.text),
      soilTexture: () => _soil,
      ph: () => ph,
      phMeasuredAt: () => ph == null ? null : _phMeasuredAt,
      sunExposure: () => _sun,
      irrigation: () => _irrigation,
      covered: _covered,
    );
    final controller = ref.read(zonesControllerProvider.notifier);
    final error = await controller.saveZone(zone);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _nameError = error;
        _saving = false;
      });
      return;
    }
    if (ref.read(zonesControllerProvider).hasError) {
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(l.zoneSaveFailed)));
      return;
    }
    Navigator.of(context).pop();
  }

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<T> values,
    required String Function(T) labelOf,
    required ValueChanged<T?> onChanged,
  }) {
    final l = AppLocalizations.of(context);
    return DropdownButtonFormField<T?>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        DropdownMenuItem<T?>(value: null, child: Text(l.zoneNotSet)),
        for (final v in values)
          DropdownMenuItem<T?>(value: v, child: Text(labelOf(v))),
      ],
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    const gap = SizedBox(height: 16);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.zoneEditTitle),
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
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l.zoneNameLabel,
                errorText: switch (_nameError) {
                  ZoneNameError.empty => l.zoneNameEmpty,
                  ZoneNameError.duplicate => l.zoneNameDuplicate,
                  null => null,
                },
              ),
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
            ),
            gap,
            DropdownButtonFormField<ZoneType>(
              initialValue: _type,
              isExpanded: true,
              decoration: InputDecoration(labelText: l.zoneTypeLabel),
              items: [
                for (final type in ZoneType.values)
                  DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(zoneIcon(type), size: 20),
                        const SizedBox(width: 12),
                        Flexible(child: Text(zoneTypeLabel(l, type))),
                      ],
                    ),
                  ),
              ],
              onChanged: (type) => setState(() => _type = type ?? _type),
            ),
            gap,
            TextFormField(
              controller: _area,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l.zoneAreaLabel,
                hintText: l.zoneAreaHint,
                helperText: l.zoneAreaHelper,
              ),
              validator: (v) => _numberError(
                l,
                validateZoneArea(v ?? '', parseDecimal(v)),
                l.zoneAreaOutOfRange,
              ),
            ),
            gap,
            _dropdown<SoilTexture>(
              label: l.zoneSoilLabel,
              value: _soil,
              values: SoilTexture.values,
              labelOf: (v) => soilTextureLabel(l, v),
              onChanged: (v) => setState(() => _soil = v),
            ),
            gap,
            TextFormField(
              controller: _ph,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l.zonePhLabel,
                hintText: l.zonePhHint,
              ),
              validator: (v) => _numberError(
                l,
                validateZonePh(v ?? '', parseDecimal(v)),
                l.zonePhOutOfRange,
              ),
              onChanged: (_) => setState(() {}),
            ),
            if (_ph.text.trim().isNotEmpty)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: Text(l.zonePhMeasuredLabel),
                subtitle: Text(
                  _phMeasuredAt == null
                      ? l.zonePhMeasuredNone
                      : formatDate(_phMeasuredAt!),
                ),
                onTap: _pickPhDate,
              ),
            gap,
            _dropdown<SunExposure>(
              label: l.zoneSunLabel,
              value: _sun,
              values: SunExposure.values,
              labelOf: (v) => sunExposureLabel(l, v),
              onChanged: (v) => setState(() => _sun = v),
            ),
            gap,
            _dropdown<Irrigation>(
              label: l.zoneIrrigationLabel,
              value: _irrigation,
              values: Irrigation.values,
              labelOf: (v) => irrigationLabel(l, v),
              onChanged: (v) => setState(() => _irrigation = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.zoneCoveredLabel),
              subtitle: Text(l.zoneCoveredHelp),
              value: _covered,
              onChanged: (v) => setState(() => _covered = v),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _submit,
              icon: const Icon(Icons.check),
              label: Text(l.commonSave),
            ),
          ],
        ),
      ),
    );
  }
}
