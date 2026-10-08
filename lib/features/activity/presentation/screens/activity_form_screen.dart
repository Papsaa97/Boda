import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/formatting/dates.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/presentation/settings_controller.dart';
import '../../../zones/domain/zone_entity.dart';
import '../../../zones/presentation/zones_controller.dart';
import '../../domain/activity_entity.dart';
import '../../domain/activity_type.dart';
import '../../../../core/text/numbers.dart';
import '../activity_type_ui.dart';
import '../controllers/activity_controller.dart';
import '../widgets/activity_photo.dart';

/// Předvyplnění nového záznamu (např. z dokončeného úkolu, FR-U4).
class ActivityDraft {
  const ActivityDraft({this.title, this.type, this.zoneId, this.notes});

  final String? title;
  final ActivityType? type;
  final String? zoneId;
  final String? notes;
}

/// Formulář pro nový záznam, nebo úpravu existujícího ([initial]).
///
/// Rychlý zápis (FR-D6): tlačítko + → typ činnosti → Uložit v horní liště
/// jsou tři klepnutí; zóna je předvyplněná naposledy použitou. Po uložení
/// se obrazovka zavře s uloženým záznamem jako výsledkem.
class ActivityFormScreen extends ConsumerStatefulWidget {
  const ActivityFormScreen({
    super.key,
    this.initial,
    this.initialZoneId,
    this.draft,
  });

  /// Záznam k úpravě. Když je null, vytváří se nový.
  final ActivityEntity? initial;

  /// Předvybraná zóna pro nový záznam (např. z dashboardu).
  final String? initialZoneId;

  final ActivityDraft? draft;

  @override
  ConsumerState<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

/// Fotka ve formuláři: už uložená, nebo nově vybraná (do složky aplikace
/// se zkopíruje až při uložení).
class _PhotoItem {
  const _PhotoItem.saved(PhotoRef this.saved) : picked = null;
  const _PhotoItem.picked(XFile this.picked) : saved = null;

  final PhotoRef? saved;
  final XFile? picked;
}

class _ActivityFormScreenState extends ConsumerState<ActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late final TextEditingController _dateController;
  late final TextEditingController _harvestController;
  late final TextEditingController _costController;
  late String _harvestUnit;

  late DateTime _date;
  late ActivityType _type;
  String? _zoneId;
  late List<_PhotoItem> _photos;

  /// Název, který formulář sám doplnil podle typu; když ho uživatel
  /// nepřepsal, změna typu ho zase přepíše.
  String? _autoTitle;

  bool _saving = false;

  /// Po úspěšném uložení se obrazovka zavírá bez dotazu na neuložené změny.
  bool _saved = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    final draft = widget.draft;
    _titleController = TextEditingController(
      text: initial?.title ?? draft?.title ?? '',
    );
    _notesController = TextEditingController(
      text: initial?.notes ?? draft?.notes ?? '',
    );
    _date = initial?.date ?? ref.read(clockProvider)();
    final draftTitle = draft?.title;
    _type =
        initial?.type ??
        draft?.type ??
        (draftTitle == null
            ? ActivityType.other
            : ActivityType.guessFromTitle(draftTitle));
    _zoneId =
        initial?.zoneId ??
        draft?.zoneId ??
        widget.initialZoneId ??
        ref.read(settingsControllerProvider).lastZoneId;
    _photos = [
      for (final photo in initial?.photos ?? const <PhotoRef>[])
        _PhotoItem.saved(photo),
    ];
    _dateController = TextEditingController(text: formatDateTime(_date));
    String num(double? v) => v == null ? '' : formatDecimal(v);
    _harvestController = TextEditingController(text: num(initial?.harvestQty));
    _harvestUnit = initial?.harvestUnit ?? harvestUnits.first;
    _costController = TextEditingController(text: num(initial?.costCzk));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    _harvestController.dispose();
    _costController.dispose();
    super.dispose();
  }

  /// Zóny k výběru: aktivní, a k tomu zóna upravovaného záznamu, i když
  /// je mezitím archivovaná.
  List<ZoneEntity> _selectableZones(List<ZoneEntity> all) => [
    for (final z in all)
      if (!z.archived || z.id == widget.initial?.zoneId) z,
  ];

  /// Zóna, která se opravdu uloží: vybraná, pokud ještě jde vybrat,
  /// jinak první ze seznamu.
  String? _effectiveZoneId(List<ZoneEntity> zones) {
    if (zones.any((z) => z.id == _zoneId)) return _zoneId;
    return zones.isEmpty ? null : zones.first.id;
  }

  /// Sklizeň se ukládá jen u typu Sklizeň.
  double? _harvestQty() => _type == ActivityType.harvest
      ? parseDecimal(_harvestController.text)
      : null;

  String? _numberError(AppLocalizations l, String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final n = parseDecimal(v);
    return n == null || n < 0 ? l.inventoryNumberInvalid : null;
  }

  bool _hasChanges() {
    final initial = widget.initial;
    final notes = _notesController.text.trim();
    final title = _titleController.text.trim();
    if (initial == null) {
      return (title.isNotEmpty && title != _autoTitle) ||
          notes.isNotEmpty ||
          _photos.isNotEmpty ||
          _harvestController.text.trim().isNotEmpty ||
          _costController.text.trim().isNotEmpty;
    }
    return title != initial.title ||
        _harvestQty() != initial.harvestQty ||
        parseDecimal(_costController.text) != initial.costCzk ||
        notes != (initial.notes ?? '') ||
        _type != initial.type ||
        _date != initial.date ||
        _zoneId != initial.zoneId ||
        !listEquals([for (final p in _photos) p.saved], [...initial.photos]);
  }

  Future<void> _confirmLeave() async {
    final l = AppLocalizations.of(context);
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.activityDiscardTitle),
        content: Text(l.activityDiscardBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.activityDiscardKeepEditing),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.activityDiscardConfirm),
          ),
        ],
      ),
    );
    if (leave == true && mounted) {
      _saved = true;
      Navigator.of(context).pop();
    }
  }

  void _pickType(AppLocalizations l, ActivityType type) {
    setState(() {
      _type = type;
      final current = _titleController.text.trim();
      if (current.isEmpty || current == _autoTitle) {
        final label = activityTypeLabel(l, type);
        _titleController.text = label;
        _autoTitle = label;
      }
    });
  }

  Future<void> _pickDateTime() async {
    FocusScope.of(context).unfocus();

    // Deník zapisuje, co už se stalo, takže budoucí dny nenabízíme.
    final now = ref.read(clockProvider)();
    final datePicked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: _date.isAfter(now) ? _date : now,
    );
    if (datePicked == null || !mounted) return;

    final timePicked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (timePicked == null || !mounted) return;

    setState(() {
      _date = DateTime(
        datePicked.year,
        datePicked.month,
        datePicked.day,
        timePicked.hour,
        timePicked.minute,
      );
      _dateController.text = formatDateTime(_date);
    });
  }

  Future<void> _addPhotos(AppLocalizations l) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l.photoTake),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l.photoFromGallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    // FR-D8: delší strana nejvýš 1 920 px, JPEG ~80 %.
    final picker = ImagePicker();
    final remaining = maxPhotosPerActivity - _photos.length;
    final List<XFile> picked;
    if (source == ImageSource.gallery && remaining > 1) {
      picked = await picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
        limit: remaining,
      );
    } else {
      final one = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
      );
      picked = one == null ? const [] : [one];
    }
    if (picked.isEmpty || !mounted) return;
    setState(() {
      _photos = [..._photos, ...picked.take(remaining).map(_PhotoItem.picked)];
    });
  }

  Future<void> _submit() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;
    final zoneId = _effectiveZoneId(
      _selectableZones(ref.read(zonesControllerProvider).value ?? const []),
    );
    if (zoneId == null) return;
    final l = AppLocalizations.of(context);

    setState(() => _saving = true);

    final storage = ref.read(photoStorageProvider);
    final newId = ref.read(newIdProvider);
    final controller = ref.read(activityControllerProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);

    // Nové fotky se do složky aplikace kopírují až teď.
    final photos = <PhotoRef>[];
    final newlyStored = <String>[];
    try {
      for (final item in _photos) {
        final picked = item.picked;
        if (picked == null) {
          photos.add(item.saved!);
          continue;
        }
        final id = newId();
        final path = await storage.persist(picked, baseName: id);
        newlyStored.add(path);
        photos.add(PhotoRef(id: id, path: path));
      }
    } catch (_) {
      for (final path in newlyStored) {
        await storage.delete(path);
      }
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(l.photoSaveFailed)));
      return;
    }

    final title = _titleController.text.trim();
    final notesText = _notesController.text.trim();
    final notes = notesText.isEmpty ? null : notesText;

    final harvestQty = _harvestQty();
    final harvestUnit = harvestQty == null ? null : _harvestUnit;
    final cost = parseDecimal(_costController.text);

    final initial = widget.initial;
    ActivityEntity? saved;
    if (initial == null) {
      saved = await controller.addActivity(
        type: _type,
        title: title,
        date: _date,
        zoneId: zoneId,
        notes: notes,
        photos: photos,
        harvestQty: harvestQty,
        harvestUnit: harvestUnit,
        costCzk: cost,
      );
    } else {
      final updated = initial.copyWith(
        type: _type,
        title: title,
        date: _date,
        zoneId: zoneId,
        notes: notes,
        clearNotes: notes == null,
        photos: photos,
        harvestQty: () => harvestQty,
        harvestUnit: () => harvestUnit,
        costCzk: () => cost,
      );
      await controller.updateActivity(updated);
      if (!ref.read(activityControllerProvider).hasError) saved = updated;
    }

    if (!mounted) return;
    if (saved == null) {
      // Kopie nových fotek by po neúspěšném uložení zůstaly viset.
      for (final path in newlyStored) {
        await storage.delete(path);
      }
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(l.activitySaveFailed)));
      return;
    }

    final kept = {for (final p in photos) p.id};
    for (final old in initial?.photos ?? const <PhotoRef>[]) {
      if (!kept.contains(old.id)) await storage.delete(old.path);
    }
    await ref.read(settingsControllerProvider.notifier).rememberZone(zoneId);
    if (!mounted) return;
    _saved = true;
    Navigator.of(context).pop(saved);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final zones = _selectableZones(
      ref.watch(zonesControllerProvider).value ?? const <ZoneEntity>[],
    );
    final zoneId = _effectiveZoneId(zones);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_saved || !_hasChanges()) {
          _saved = true;
          Navigator.of(context).pop();
        } else {
          _confirmLeave();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEdit ? l.activityEditTitle : l.activityNewTitle),
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
              Text(
                l.activityTypeLabel,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final type in quickPickTypes)
                    ChoiceChip(
                      avatar: Icon(activityTypeIcon(type), size: 18),
                      label: Text(activityTypeLabel(l, type)),
                      selected: _type == type,
                      showCheckmark: false,
                      onSelected: (_) => _pickType(l, type),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l.activityTitleLabel,
                  hintText: l.activityTitleHint,
                ),
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                validator: (value) => value == null || value.trim().isEmpty
                    ? l.activityTitleRequired
                    : null,
              ),
              if (!_isEdit) ...[
                const SizedBox(height: 8),
                _RecentTitles(
                  onPick: (activity) => setState(() {
                    _titleController.text = activity.title;
                    _autoTitle = null;
                    _type = activity.type;
                  }),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: l.activityDateLabel,
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _pickDateTime,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: ValueKey(zoneId),
                decoration: InputDecoration(labelText: l.activityZoneLabel),
                initialValue: zoneId,
                // Dlouhé názvy a velké písmo se zalomí do šířky pole.
                isExpanded: true,
                items: [
                  for (final zone in zones)
                    DropdownMenuItem(
                      value: zone.id,
                      child: Text(zone.name, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (value) => setState(() => _zoneId = value),
                validator: (value) =>
                    value == null ? l.activityZoneRequired : null,
              ),
              if (_type == ActivityType.harvest) ...[
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _harvestController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l.activityHarvestLabel,
                        ),
                        validator: (v) => _numberError(l, v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: _harvestUnit,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l.inventoryUnitLabel,
                        ),
                        items: [
                          for (final u in harvestUnits)
                            DropdownMenuItem(
                              value: u,
                              child: Text(harvestUnitLabel(l, u)),
                            ),
                        ],
                        onChanged: (u) =>
                            setState(() => _harvestUnit = u ?? _harvestUnit),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(labelText: l.activityNotesLabel),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _costController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: l.activityCostLabel),
                validator: (v) => _numberError(l, v),
              ),
              // Na webu fotky nejsou (prohlížeč nemá trvalou složku).
              if (!kIsWeb) ...[const SizedBox(height: 16), ..._photoSection(l)],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: const Icon(Icons.check),
                label: Text(
                  _isEdit ? l.activitySaveChanges : l.activitySaveNew,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _photoSection(AppLocalizations l) {
    final canAdd = _photos.length < maxPhotosPerActivity;
    return [
      if (_photos.isNotEmpty) ...[
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _photos.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final item = _photos[i];
              final picked = item.picked;
              return Stack(
                children: [
                  if (picked != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(picked.path),
                        width: 112,
                        height: 112,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    ActivityPhoto(
                      path: item.saved!.path,
                      width: 112,
                      height: 112,
                    ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton.filledTonal(
                      tooltip: l.photoRemove,
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () =>
                          setState(() => _photos = [..._photos]..removeAt(i)),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
      OutlinedButton.icon(
        onPressed: canAdd ? () => _addPhotos(l) : null,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text(
          canAdd
              ? l.photoAdd(_photos.length, maxPhotosPerActivity)
              : l.photoLimitReached(maxPhotosPerActivity),
        ),
      ),
    ];
  }
}

/// Naposledy použité názvy pro zápis jedním klepnutím (s jejich typem).
class _RecentTitles extends ConsumerWidget {
  const _RecentTitles({required this.onPick});

  final ValueChanged<ActivityEntity> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activityControllerProvider).value ?? const [];
    final seen = <String>{};
    final recent = <ActivityEntity>[];
    for (final a in activities.take(30)) {
      if (seen.add(a.title.toLowerCase())) recent.add(a);
      if (recent.length == 6) break;
    }
    if (recent.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final a in recent)
          ActionChip(
            avatar: const Icon(Icons.history, size: 16),
            label: Text(a.title),
            onPressed: () => onPick(a),
          ),
      ],
    );
  }
}
