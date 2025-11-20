// lib/features/activity/presentation/controllers/activity_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/activity_entity.dart';
import '../../domain/activity_repository.dart';
import '../../../../core/di/providers.dart';

/// Controller spravující seznam aktivit.
///
/// Stav: AsyncValue<List<ActivityEntity>> – přesně jak doporučuje blueprint. :contentReference[oaicite:1]{index=1}
class ActivityController
    extends StateNotifier<AsyncValue<List<ActivityEntity>>> {
  ActivityController(this._repository) : super(const AsyncLoading()) {
    _loadInitial();
  }

  final ActivityRepository _repository;

  Future<void> _loadInitial() async {
    try {
      final activities = await _repository.getAllActivities();
      state = AsyncData(activities);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> addActivity({
    required String title,
    required DateTime date,
    required String zoneId,
    String? notes,
    String? imagePath,
  }) async {
    final newActivity = ActivityEntity(
      id: const Uuid().v4(),
      title: title,
      date: date,
      zoneId: zoneId,
      notes: notes,
      imagePath: imagePath,
    );

    // předchozí data (pokud jsou)
    final previousList = state.value ?? <ActivityEntity>[];

    // Loading stav pro UI
    state = const AsyncLoading();

    try {
      await _repository.addActivity(newActivity);

      // Optimistická aktualizace – bez dalšího čtení z DB,
      // tak jak blueprint doporučuje. :contentReference[oaicite:2]{index=2}
      final updated = [...previousList, newActivity];
      state = AsyncData(updated);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

/// Provider pro ActivityController.
///
/// Presentation vrstva používá ref.watch/read(activityControllerProvider),
/// DI (ActivityRepository) bere z core/di/providers.dart.
final activityControllerProvider =
    StateNotifierProvider<ActivityController, AsyncValue<List<ActivityEntity>>>(
  (ref) {
    final repo = ref.watch(activityRepositoryProvider);
    return ActivityController(repo);
  },
);
