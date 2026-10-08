import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/sync/sync_engine.dart';
import '../../../core/sync/sync_remote.dart';
import '../../activity/presentation/controllers/activity_controller.dart';
import '../../assistant/presentation/assistant_controller.dart';
import '../../inventory/presentation/inventory_controller.dart';
import '../../tasks/presentation/tasks_controller.dart';
import '../../zones/presentation/zones_controller.dart';
import '../domain/auth_service.dart';

/// Proč poslední synchronizace neprošla.
enum SyncProblem { offline, failed }

/// Stav synchronizace pro obrazovku Účet.
class SyncStatus extends Equatable {
  const SyncStatus({
    this.running = false,
    this.lastSyncAt,
    this.problem,
    this.conflictGardenId,
  });

  final bool running;
  final DateTime? lastSyncAt;
  final SyncProblem? problem;

  /// Účet už má jinou zahradu; čeká se na volbu uživatele (DECLOG D70).
  final String? conflictGardenId;

  @override
  List<Object?> get props => [running, lastSyncAt, problem, conflictGardenId];
}

/// Spouští synchronizaci: po přihlášení, při startu a návratu do
/// aplikace a ručně z obrazovky Účet.
class SyncController extends Notifier<SyncStatus> {
  @override
  SyncStatus build() {
    ref.listen<AsyncValue<AccountUser?>>(currentUserProvider, (prev, next) {
      final before = prev?.value;
      final now = next.value;
      if (now != null && before?.id != now.id) {
        syncNow();
      } else if (now == null && before != null) {
        _engine()?.forget();
        state = const SyncStatus();
      }
    });
    return const SyncStatus();
  }

  SyncEngine? _engine() {
    final remote = ref.read(syncRemoteProvider);
    if (remote == null) return null;
    final photos = ref.read(photoStorageProvider);
    return SyncEngine(
      db: ref.read(databaseProvider),
      remote: remote,
      gardenId: ref.read(gardenIdProvider),
      clock: ref.read(clockProvider),
      photos: photos.rootPath.isEmpty ? null : photos,
    );
  }

  /// Jedno kolo synchronizace, když je uživatel přihlášený.
  Future<void> syncNow() async {
    if (state.running || ref.read(currentUserProvider).value == null) return;
    final engine = _engine();
    if (engine == null) return;
    state = SyncStatus(running: true, lastSyncAt: state.lastSyncAt);
    try {
      final report = await engine.sync();
      final pairing = report.pairing;
      state = SyncStatus(
        lastSyncAt: pairing is Paired
            ? ref.read(clockProvider)()
            : state.lastSyncAt,
        conflictGardenId: pairing is PairingConflict
            ? pairing.remoteGardenId
            : null,
      );
      if (report.pulled > 0) _reload();
    } on SyncException catch (e) {
      state = SyncStatus(
        lastSyncAt: state.lastSyncAt,
        problem: e.offline ? SyncProblem.offline : SyncProblem.failed,
      );
    } on Exception catch (e) {
      debugPrint('Synchronizace selhala: $e');
      state = SyncStatus(
        lastSyncAt: state.lastSyncAt,
        problem: SyncProblem.failed,
      );
    }
  }

  /// Nahradí data v telefonu zahradou z účtu a aplikaci znovu načte.
  Future<void> adoptAccountGarden() async {
    final remoteId = state.conflictGardenId;
    final engine = _engine();
    if (remoteId == null || engine == null) return;
    state = SyncStatus(running: true, conflictGardenId: remoteId);
    try {
      await engine.adoptRemoteGarden(remoteId);
    } on Exception catch (e) {
      debugPrint('Převzetí zahrady selhalo: $e');
      state = SyncStatus(
        problem: SyncProblem.failed,
        conflictGardenId: remoteId,
      );
      return;
    }
    ref.read(restartAppProvider)();
  }

  /// Obrazovky načtou data znovu (stažené změny).
  void _reload() {
    ref
      ..invalidate(zonesControllerProvider)
      ..invalidate(activityControllerProvider)
      ..invalidate(tasksControllerProvider)
      ..invalidate(inventoryControllerProvider)
      ..invalidate(shoppingControllerProvider)
      ..invalidate(assistantControllerProvider);
  }
}

final syncControllerProvider = NotifierProvider<SyncController, SyncStatus>(
  SyncController.new,
);
