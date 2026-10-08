import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/app/app_info.dart';
import '../../../core/di/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/time/calendar.dart';
import '../../account/presentation/garden_reload.dart';
import '../../activity/presentation/activity_type_ui.dart';
import '../../activity/presentation/controllers/activity_controller.dart';
import '../../zones/presentation/zones_controller.dart';
import '../domain/diary_csv.dart';
import '../../settings/presentation/settings_controller.dart';
import '../data/backup_service.dart';
import '../domain/backup_format.dart';

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(
    db: ref.watch(databaseProvider),
    gardenId: ref.watch(gardenIdProvider),
    photos: ref.watch(photoStorageProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Po kolika dnech od posledního exportu připomenout zálohu (FR-E3).
const backupReminderDays = 30;

/// Vytvoří ZIP a nabídne ho přes systémové sdílení (FR-E1).
Future<void> exportBackup(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final box = context.findRenderObject() as RenderBox?;
  try {
    final dir = await getTemporaryDirectory();
    final path = await ref
        .read(backupServiceProvider)
        .export(directory: dir.path, appVersion: appVersion);
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path, mimeType: 'application/zip')],
        subject: l.backupShareSubject,
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
    if (result.status != ShareResultStatus.dismissed) {
      final now = ref.read(clockProvider)();
      await ref
          .read(settingsControllerProvider.notifier)
          .update((s) => s.copyWith(lastExportAt: now));
      messenger.showSnackBar(SnackBar(content: Text(l.backupExportDone)));
    }
  } catch (e) {
    debugPrint('Export selhal: $e');
    messenger.showSnackBar(SnackBar(content: Text(l.backupExportFailed)));
  }
}

/// Uloží deník jako CSV a nabídne ho přes systémové sdílení (FR-E4).
Future<void> exportDiaryCsv(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final box = context.findRenderObject() as RenderBox?;
  try {
    final activities = await ref.read(activityControllerProvider.future);
    final zones = await ref.read(zonesControllerProvider.future);
    final names = {for (final z in zones) z.id: z.name};
    final csv = diaryCsv(
      activities,
      zoneName: (id) => names[id] ?? l.commonUnknownZone,
      typeLabel: (type) => activityTypeLabel(l, type),
    );
    final dir = await getTemporaryDirectory();
    final now = ref.read(clockProvider)();
    final path = p.join(
      dir.path,
      'zahradnik-boda-denik-${formatDateKey(now)}.csv',
    );
    await File(path).writeAsString(csv, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path, mimeType: 'text/csv')],
        subject: l.diaryCsvShareSubject,
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  } catch (e, stack) {
    ref.read(crashReporterProvider).recordError(e, stack);
    messenger.showSnackBar(SnackBar(content: Text(l.diaryCsvFailed)));
  }
}

/// Vybere ZIP, ukáže, co obsahuje, a po potvrzení nahradí všechna data
/// (FR-E2).
Future<void> importBackup(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final service = ref.read(backupServiceProvider);

  final picked = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: const ['zip'],
  );
  if (picked == null) return;

  final String path;
  final BackupData data;
  try {
    // Soubor může být jen URI (Android), zálohu si zkopírujeme.
    final dir = await getTemporaryDirectory();
    path = p.join(dir.path, 'boda-import.zip');
    await picked.xFile.saveTo(path);
    data = await service.read(path);
  } on BackupException catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text(backupErrorMessage(l, e.error))),
    );
    return;
  } catch (e) {
    debugPrint('Import selhal: $e');
    messenger.showSnackBar(
      SnackBar(content: Text(backupErrorMessage(l, BackupError.notABackup))),
    );
    return;
  }
  if (!context.mounted) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.backupImportConfirmTitle),
      content: Text(
        l.backupImportConfirmBody(
          data.activities.length,
          data.tasks.length,
          data.photos.length,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l.backupImportConfirm),
        ),
      ],
    ),
  );
  if (confirmed != true) return;

  try {
    await service.restore(path, data);
  } catch (e) {
    debugPrint('Obnova selhala: $e');
    messenger.showSnackBar(SnackBar(content: Text(l.backupImportFailed)));
    return;
  } finally {
    final copy = File(path);
    if (copy.existsSync()) await copy.delete();
  }
  reloadGardenData(ref.invalidate);
  messenger.showSnackBar(SnackBar(content: Text(l.backupImportDone)));
}

String backupErrorMessage(AppLocalizations l, BackupError error) =>
    switch (error) {
      BackupError.notABackup => l.backupErrorNotABackup,
      BackupError.corrupted => l.backupErrorCorrupted,
      BackupError.tooNew => l.backupErrorTooNew,
    };

/// Má se připomenout záloha? Jen když je co zálohovat a poslední export
/// je starší než [backupReminderDays] (nebo žádný nebyl).
bool backupReminderDue({
  required DateTime? lastExportAt,
  required int activityCount,
  required DateTime now,
}) {
  if (activityCount == 0) return false;
  if (lastExportAt == null) return true;
  return now.difference(lastExportAt).inDays >= backupReminderDays;
}
