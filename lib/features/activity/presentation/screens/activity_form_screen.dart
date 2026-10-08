// lib/features/activity/presentation/screens/activity_form_screen.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/formatting/dates.dart';
import '../../../zones/domain/zone_entity.dart';
import '../../../zones/presentation/zones_controller.dart';
import '../../domain/activity_entity.dart';
import '../controllers/activity_controller.dart';
import '../widgets/activity_photo.dart';

/// Formulář pro nový záznam, nebo úpravu existujícího ([initial]).
class ActivityFormScreen extends ConsumerStatefulWidget {
  const ActivityFormScreen({super.key, this.initial, this.initialZoneId});

  /// Záznam k úpravě. Když je null, vytváří se nový.
  final ActivityEntity? initial;

  /// Předvybraná zóna pro nový záznam (např. z dashboardu).
  final String? initialZoneId;

  @override
  ConsumerState<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends ConsumerState<ActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late final TextEditingController _dateController;

  late DateTime _date;
  String? _zoneId;

  /// Cesta k fotce, která už je uložená u záznamu.
  String? _savedImagePath;

  /// Nově vybraná fotka; do složky aplikace se zkopíruje až při uložení.
  XFile? _pickedImage;

  bool _saving = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _titleController = TextEditingController(text: initial?.title ?? '');
    _notesController = TextEditingController(text: initial?.notes ?? '');
    _date = initial?.date ?? ref.read(clockProvider)();
    _zoneId = initial?.zoneId ?? widget.initialZoneId;
    _savedImagePath = initial?.imagePath;
    _dateController = TextEditingController(text: formatDateTime(_date));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
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

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Vyfotit'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Vybrat z galerie'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 2048,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    setState(() => _pickedImage = picked);
  }

  void _removePhoto() {
    setState(() {
      _pickedImage = null;
      _savedImagePath = null;
    });
  }

  Future<void> _submit() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    setState(() => _saving = true);

    final photos = ref.read(photoStorageProvider);
    final controller = ref.read(activityControllerProvider.notifier);
    final previousImage = widget.initial?.imagePath;

    var imagePath = _savedImagePath;
    final picked = _pickedImage;
    if (picked != null) {
      try {
        imagePath = await photos.persist(picked);
      } catch (_) {
        if (!mounted) return;
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fotku se nepodařilo uložit.')),
        );
        return;
      }
    }

    final title = _titleController.text.trim();
    final notesText = _notesController.text.trim();
    final notes = notesText.isEmpty ? null : notesText;

    final initial = widget.initial;
    if (initial == null) {
      await controller.addActivity(
        title: title,
        date: _date,
        zoneId: _zoneId!,
        notes: notes,
        imagePath: imagePath,
      );
    } else {
      await controller.updateActivity(ActivityEntity(
        id: initial.id,
        title: title,
        date: _date,
        zoneId: _zoneId!,
        notes: notes,
        imagePath: imagePath,
      ));
    }

    if (!mounted) return;
    if (ref.read(activityControllerProvider).hasError) {
      // Kopie nové fotky by po neúspěšném uložení zůstala viset.
      if (picked != null) await photos.delete(imagePath);
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Záznam se nepodařilo uložit.')),
      );
      return;
    }

    if (previousImage != null && previousImage != imagePath) {
      await photos.delete(previousImage);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final zones = ref.watch(zonesControllerProvider).value ?? const <ZoneEntity>[];
    final zoneIds = zones.map((z) => z.id).toSet();
    // Když předvybraná zóna neexistuje, vezmeme první ze seznamu.
    if (_zoneId == null || !zoneIds.contains(_zoneId)) {
      _zoneId = zones.isEmpty ? null : zones.first.id;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Upravit záznam' : 'Nový záznam'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Název aktivity',
                hintText: 'např. Zálivka rajčat',
              ),
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Zadej název aktivity';
                }
                return null;
              },
            ),
            if (!_isEdit) ...[
              const SizedBox(height: 8),
              _TitleSuggestions(
                onPick: (title) => setState(() => _titleController.text = title),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Datum a čas',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey(_zoneId),
              decoration: const InputDecoration(labelText: 'Zóna'),
              initialValue: _zoneId,
              items: [
                for (final zone in zones)
                  DropdownMenuItem(value: zone.id, child: Text(zone.name)),
              ],
              onChanged: (value) => setState(() => _zoneId = value),
              validator: (value) => value == null ? 'Vyber zónu' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Poznámka (volitelné)',
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            if (!kIsWeb) ..._photoSection(),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _submit,
              icon: const Icon(Icons.check),
              label: Text(_isEdit ? 'Uložit změny' : 'Uložit záznam'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _photoSection() {
    final picked = _pickedImage;
    final hasPhoto = picked != null || _savedImagePath != null;
    return [
      if (picked != null)
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(File(picked.path), height: 200, fit: BoxFit.cover),
        )
      else if (_savedImagePath != null)
        ActivityPhoto(path: _savedImagePath, height: 200, iconSize: 48),
      if (hasPhoto) const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: Text(hasPhoto ? 'Změnit fotku' : 'Přidat fotku'),
            ),
          ),
          if (hasPhoto) ...[
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Odebrat fotku',
              onPressed: _removePhoto,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ],
      ),
    ];
  }
}

/// Nejčastější práce na zahradě pro rychlý zápis jedním ťuknutím.
const commonActivityTitles = [
  'Zálivka',
  'Pletí',
  'Hnojení',
  'Výsev',
  'Výsadba',
  'Sklizeň',
  'Řez',
  'Sekání trávy',
  'Postřik',
  'Mulčování',
];

/// Návrhy názvu: nejdřív naposledy použité, pak běžné práce.
class _TitleSuggestions extends ConsumerWidget {
  const _TitleSuggestions({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activityControllerProvider).value ?? const [];
    final seen = <String>{};
    final suggestions = <String>[];
    for (final title in [
      ...activities.map((a) => a.title).take(20),
      ...commonActivityTitles,
    ]) {
      if (seen.add(title.toLowerCase())) suggestions.add(title);
      if (suggestions.length == 8) break;
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final title in suggestions)
          ActionChip(label: Text(title), onPressed: () => onPick(title)),
      ],
    );
  }
}
