import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/di/providers.dart';
import '../../../core/formatting/dates.dart';
import '../../../l10n/app_localizations.dart';
import '../../activity/domain/activity_entity.dart';
import '../../activity/presentation/widgets/activity_photo.dart';
import '../../tasks/domain/task_entity.dart';
import '../../tasks/presentation/task_ui.dart';
import '../../tasks/presentation/tasks_controller.dart';
import '../../zones/presentation/zones_controller.dart';
import '../domain/diagnosis.dart';
import '../domain/incident.dart';
import 'diagnosis_controller.dart';
import 'incidents_controller.dart';

/// Nejvýš fotek u jednoho incidentu (stejně jako u záznamu).
const maxIncidentPhotos = 5;

/// Problémy na zahradě (FR-V3, FR-V4): otevřené nahoře, vyřešené pod nimi.
class IncidentsScreen extends ConsumerWidget {
  const IncidentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(incidentsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.incidentsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-incident',
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const IncidentFormScreen())),
        icon: const Icon(Icons.add),
        label: Text(l.incidentNew),
      ),
      body: async.when(
        skipError: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.commonErrorWithDetail('$e'))),
        data: (incidents) {
          if (incidents.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(l.incidentsEmpty, textAlign: TextAlign.center),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [for (final i in incidents) _IncidentTile(incident: i)],
          );
        },
      ),
    );
  }
}

class _IncidentTile extends ConsumerWidget {
  const _IncidentTile({required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final zone = ref.watch(zoneNameProvider(incident.zoneId)) ?? '';
    final created = incident.createdAt;
    return ListTile(
      leading: incident.photos.isEmpty
          ? Icon(
              incident.isOpen
                  ? Icons.report_problem_outlined
                  : Icons.check_circle_outline,
            )
          : ActivityPhoto(
              path: incident.photos.first.path,
              width: 48,
              height: 48,
              borderRadius: 8,
              iconSize: 20,
            ),
      title: Text(incident.label),
      subtitle: Text(
        [
          zone,
          if (created != null) formatDate(created),
          if (!incident.isOpen) l.incidentResolved,
        ].join(' · '),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => IncidentDetailScreen(incidentId: incident.id),
        ),
      ),
    );
  }
}

/// Fotka v rozpracovaném formuláři: uložená, nebo právě vybraná.
class _PhotoItem {
  _PhotoItem.saved(PhotoRef this.saved) : picked = null;
  _PhotoItem.picked(XFile this.picked) : saved = null;

  final PhotoRef? saved;
  final XFile? picked;
}

/// Nový incident, nebo úprava ([initial]). Ručně, bez AI (FR-V4).
class IncidentFormScreen extends ConsumerStatefulWidget {
  const IncidentFormScreen({super.key, this.initial, this.zoneId});

  final Incident? initial;

  /// Předvybraná zóna (z detailu zóny).
  final String? zoneId;

  @override
  ConsumerState<IncidentFormScreen> createState() => _IncidentFormState();
}

class _IncidentFormState extends ConsumerState<IncidentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _label = TextEditingController(text: widget.initial?.label);
  late final _bio = TextEditingController(text: widget.initial?.planBio);
  late final _chem = TextEditingController(text: widget.initial?.planChem);
  late String? _zoneId = widget.initial?.zoneId ?? widget.zoneId;
  late List<_PhotoItem> _photos = [
    for (final p in widget.initial?.photos ?? const <PhotoRef>[])
      _PhotoItem.saved(p),
  ];
  late IncidentSource _source = widget.initial?.source ?? IncidentSource.user;
  late List<IncidentCandidate> _candidates =
      widget.initial?.candidates ?? const [];
  bool _saving = false;

  @override
  void dispose() {
    _label.dispose();
    _bio.dispose();
    _chem.dispose();
    super.dispose();
  }

  Future<void> _addPhoto(AppLocalizations l) async {
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
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 80,
    );
    if (picked == null || !mounted) return;
    setState(() => _photos = [..._photos, _PhotoItem.picked(picked)]);
  }

  Future<Uint8List?> _photoBytes(_PhotoItem item) async {
    final picked = item.picked;
    if (picked != null) return picked.readAsBytes();
    final path = ref.read(photoStorageProvider).resolve(item.saved!.path);
    if (path == null || !File(path).existsSync()) return null;
    // Fotka má po zmenšení stovky kB, synchronní čtení nevadí.
    return File(path).readAsBytesSync();
  }

  /// Diagnostika z první fotky (FR-V1, FR-V2): souhlas, tip, volba.
  Future<void> _diagnose(AppLocalizations l) async {
    final controller = ref.read(diagnosisControllerProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    if (!controller.hasConsent) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l.diagnosisConsentTitle),
          content: Text(l.diagnosisConsentBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l.diagnosisConsentAgree),
            ),
          ],
        ),
      );
      if (ok != true) return;
      await controller.grantConsent();
    }
    final bytes = await _photoBytes(_photos.first);
    if (!mounted) return;
    final zoneType = ref
        .read(activeZonesProvider)
        .where((z) => z.id == _zoneId)
        .firstOrNull
        ?.type
        .name;
    DiagnosisResult result;
    try {
      if (bytes == null) {
        throw const DiagnosisException(DiagnosisFailure.badImage);
      }
      result = await controller.diagnose(
        bytes,
        zoneType: zoneType,
        note: _label.text,
      );
    } on DiagnosisException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(diagnosisFailureText(l, e.failure))),
      );
      return;
    }
    if (!mounted) return;
    if (result.unclear) {
      messenger.showSnackBar(SnackBar(content: Text(l.diagnosisUnclear)));
      return;
    }
    setState(() {
      _source = IncidentSource.model;
      _candidates = result.candidates;
    });
    final chosen = await showModalBottomSheet<IncidentCandidate>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _DiagnosisSheet(candidates: result.candidates),
    );
    if (chosen == null || !mounted) return;
    setState(() {
      _label.text = chosen.label;
      if (_bio.text.trim().isEmpty && chosen.care != null) {
        _bio.text = chosen.care!;
      }
    });
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    final zoneId = _zoneId;
    if (form == null || !form.validate() || zoneId == null) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);
    final storage = ref.read(photoStorageProvider);
    final newId = ref.read(newIdProvider);
    final photos = <PhotoRef>[];
    for (final item in _photos) {
      final picked = item.picked;
      if (picked == null) {
        photos.add(item.saved!);
        continue;
      }
      final id = newId();
      photos.add(
        PhotoRef(
          id: id,
          path: await storage.persist(picked, baseName: id),
        ),
      );
    }
    final controller = ref.read(incidentsControllerProvider.notifier);
    final label = _label.text.trim();
    final initial = widget.initial;
    if (initial == null) {
      await controller.create(
        zoneId: zoneId,
        label: label,
        planBio: _bio.text,
        planChem: _chem.text,
        photos: photos,
        source: _source,
        candidates: _candidates,
        checkTitle: (day) => l.incidentCheckTask(day, label),
      );
    } else {
      await controller.save(
        initial.copyWith(
          zoneId: zoneId,
          label: label,
          source: _source,
          candidates: _candidates,
          planBio: () => _bio.text,
          planChem: () => _chem.text,
          photos: photos,
        ),
      );
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (ref.read(incidentsControllerProvider).hasError) {
      messenger.showSnackBar(SnackBar(content: Text(l.incidentSaveFailed)));
      return;
    }
    if (initial == null) {
      messenger.showSnackBar(SnackBar(content: Text(l.incidentCreated)));
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final zones = ref.watch(activeZonesProvider);
    final zoneIds = {for (final z in zones) z.id};
    final diagnosisAvailable = ref.watch(diagnosisBackendProvider).available;
    final diagnosing = ref.watch(diagnosisControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initial == null ? l.incidentNew : l.incidentEditTitle,
        ),
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
              controller: _label,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l.incidentLabel,
                hintText: l.incidentLabelHint,
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? l.incidentLabelRequired
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: zoneIds.contains(_zoneId) ? _zoneId : null,
              isExpanded: true,
              decoration: InputDecoration(labelText: l.activityZoneLabel),
              items: [
                for (final z in zones)
                  DropdownMenuItem(value: z.id, child: Text(z.name)),
              ],
              validator: (v) => v == null ? l.incidentZoneRequired : null,
              onChanged: (v) => setState(() => _zoneId = v),
            ),
            const SizedBox(height: 16),
            Text(
              l.incidentPhotos,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (i, item) in _photos.indexed)
                  Stack(
                    children: [
                      item.picked != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(item.picked!.path),
                                width: 80,
                                height: 80,
                                cacheWidth: 240,
                                fit: BoxFit.cover,
                              ),
                            )
                          : ActivityPhoto(
                              path: item.saved!.path,
                              width: 80,
                              height: 80,
                              borderRadius: 8,
                            ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          tooltip: l.photoRemove,
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(
                            () => _photos = [..._photos]..removeAt(i),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (!kIsWeb && _photos.length < maxIncidentPhotos)
                  OutlinedButton.icon(
                    onPressed: () => _addPhoto(l),
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: Text(l.photoAdd(_photos.length, maxIncidentPhotos)),
                  ),
              ],
            ),
            if (!kIsWeb && diagnosisAvailable && _photos.isNotEmpty) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: diagnosing ? null : () => _diagnose(l),
                icon: diagnosing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome_outlined),
                label: Text(
                  diagnosing ? l.diagnosisRunning : l.diagnosisButton,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l.diagnosisButtonHelper,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _bio,
              minLines: 2,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l.incidentPlanBio,
                helperText: l.incidentPlanBioHelper,
                helperMaxLines: 3,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _chem,
              minLines: 2,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l.incidentPlanChem,
                helperText: l.incidentPlanChemHelper,
                helperMaxLines: 4,
              ),
            ),
            if (widget.initial == null) ...[
              const SizedBox(height: 16),
              Text(l.incidentChecksNote),
            ],
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

String diagnosisFailureText(AppLocalizations l, DiagnosisFailure f) =>
    switch (f) {
      DiagnosisFailure.unavailable => l.diagnosisUnavailable,
      DiagnosisFailure.notSignedIn => l.diagnosisNotSignedIn,
      DiagnosisFailure.notPremium => l.diagnosisNotPremium,
      DiagnosisFailure.noConsent => l.diagnosisNoConsent,
      DiagnosisFailure.limitReached => l.diagnosisLimitReached,
      DiagnosisFailure.badImage => l.diagnosisBadImage,
      DiagnosisFailure.offline => l.diagnosisOffline,
      DiagnosisFailure.failed => l.diagnosisFailed,
    };

/// Možné příčiny z diagnostiky (FR-V2): vždy „možná“, bez čísel jistoty.
class _DiagnosisSheet extends StatelessWidget {
  const _DiagnosisSheet({required this.candidates});

  final List<IncidentCandidate> candidates;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Text(l.diagnosisResultTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(l.diagnosisDisclaimer, style: theme.textTheme.bodySmall),
            for (final c in candidates)
              Card(
                margin: const EdgeInsets.only(top: 12),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.label, style: theme.textTheme.titleMedium),
                      if (c.reason != null) ...[
                        const SizedBox(height: 4),
                        Text(c.reason!),
                      ],
                      if (c.check != null) ...[
                        const SizedBox(height: 4),
                        Text(l.diagnosisCheck(c.check!)),
                      ],
                      if (c.care != null) ...[
                        const SizedBox(height: 4),
                        Text(l.diagnosisCare(c.care!)),
                      ],
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(c),
                          child: Text(l.diagnosisUse),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Karta incidentu (FR-V3).
class IncidentDetailScreen extends ConsumerWidget {
  const IncidentDetailScreen({super.key, required this.incidentId});

  final String incidentId;

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Incident incident,
  ) async {
    final l = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.incidentDeleteTitle),
        content: Text(l.incidentDeleteBody(incident.label)),
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
    await ref.read(incidentsControllerProvider.notifier).delete(incident.id);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final incident = ref.watch(incidentByIdProvider(incidentId));
    if (incident == null) {
      return Scaffold(appBar: AppBar());
    }
    final zone = ref.watch(zoneNameProvider(incident.zoneId)) ?? '';
    final checks = ref.watch(incidentChecksProvider(incidentId));
    final now = ref.watch(clockProvider)();
    final theme = Theme.of(context);
    final controller = ref.read(incidentsControllerProvider.notifier);
    final paths = [for (final p in incident.photos) p.path];

    Widget section(String title, String? body) => body == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(body),
              ],
            ),
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(incident.label),
        actions: [
          IconButton(
            tooltip: l.commonEdit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => IncidentFormScreen(initial: incident),
              ),
            ),
          ),
          IconButton(
            tooltip: l.commonDelete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, ref, incident),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            [
              zone,
              if (incident.createdAt case final at?) formatDate(at),
            ].join(' · '),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Chip(
            avatar: Icon(
              incident.isOpen
                  ? Icons.report_problem_outlined
                  : Icons.check_circle_outline,
              size: 18,
            ),
            label: Text(incident.isOpen ? l.incidentOpen : l.incidentResolved),
          ),
          if (paths.length >= 2) ...[
            const SizedBox(height: 8),
            Text(l.incidentBeforeAfter, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final (i, path) in [paths.first, paths.last].indexed) ...[
                  if (i == 1) const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PhotoViewerScreen(
                            paths: paths,
                            title: incident.label,
                            initialIndex: i == 0 ? 0 : paths.length - 1,
                          ),
                        ),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ActivityPhoto(path: path),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ] else if (paths.length == 1) ...[
            const SizedBox(height: 8),
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ActivityPhoto(path: paths.single),
            ),
          ],
          if (incident.candidates.isNotEmpty)
            section(
              l.incidentCandidates,
              [
                for (final c in incident.candidates)
                  '• ${c.label}${c.reason == null ? '' : ' (${c.reason})'}',
              ].join('\n'),
            ),
          section(l.incidentPlanBio, incident.planBio),
          section(l.incidentPlanChem, incident.planChem),
          if (incident.planChem != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l.incidentPlanChemHelper,
                style: theme.textTheme.bodySmall,
              ),
            ),
          if (checks.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(l.incidentChecks, style: theme.textTheme.titleSmall),
            for (final t in checks)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: t.status == TaskStatus.done,
                title: Text(t.title),
                subtitle: Text(
                  t.isOpen
                      ? taskWhenLabel(l, t, now)
                      : t.status == TaskStatus.done
                      ? l.incidentCheckDone
                      : l.incidentCheckSkipped,
                ),
                onChanged: (done) => done == true
                    ? ref
                          .read(tasksControllerProvider.notifier)
                          .close(t.id, TaskStatus.done)
                    : ref.read(tasksControllerProvider.notifier).reopen(t.id),
              ),
          ],
          const SizedBox(height: 24),
          incident.isOpen
              ? FilledButton.icon(
                  onPressed: () => controller.setStatus(
                    incident.id,
                    IncidentStatus.resolved,
                  ),
                  icon: const Icon(Icons.check),
                  label: Text(l.incidentResolve),
                )
              : OutlinedButton.icon(
                  onPressed: () =>
                      controller.setStatus(incident.id, IncidentStatus.open),
                  icon: const Icon(Icons.undo),
                  label: Text(l.incidentReopen),
                ),
        ],
      ),
    );
  }
}
