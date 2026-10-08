// lib/features/activity/presentation/controllers/activity_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/activity_entity.dart';
import '../../../../core/di/providers.dart';

/// Controller spravující seznam aktivit.
///
/// Stav je `AsyncValue<List<ActivityEntity>>`, seřazený od nejnovějšího
/// záznamu. Zápisy jdou přes `AsyncValue.guard()`, takže chyba úložiště
/// skončí jako `AsyncError` místo pádu aplikace.
class ActivityController extends AsyncNotifier<List<ActivityEntity>> {
  @override
  Future<List<ActivityEntity>> build() async {
    final activities =
        await ref.watch(activityRepositoryProvider).getAllActivities();
    return _sorted(activities);
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

    final previous = state.value ?? const <ActivityEntity>[];
    await _mutate(() async {
      await ref.read(activityRepositoryProvider).addActivity(newActivity);
      return _sorted([...previous, newActivity]);
    });
  }

  Future<void> updateActivity(ActivityEntity activity) async {
    final previous = state.value ?? const <ActivityEntity>[];
    await _mutate(() async {
      await ref.read(activityRepositoryProvider).updateActivity(activity);
      return _sorted([
        for (final a in previous)
          if (a.id == activity.id) activity else a,
      ]);
    });
  }

  Future<void> deleteActivity(String id) async {
    final previous = state.value ?? const <ActivityEntity>[];
    await _mutate(() async {
      await ref.read(activityRepositoryProvider).deleteActivity(id);
      return previous.where((a) => a.id != id).toList();
    });
  }

  /// Provede zápis a nový seznam dá do stavu. Při chybě stav nese chybu,
  /// ale zachová poslední známý seznam, takže obrazovky nezmizí.
  Future<void> _mutate(Future<List<ActivityEntity>> Function() op) async {
    state = (await AsyncValue.guard(op)).copyWithPrevious(state);
  }

  static List<ActivityEntity> _sorted(List<ActivityEntity> activities) =>
      [...activities]..sort((a, b) => b.date.compareTo(a.date));
}

/// Provider pro ActivityController.
///
/// Presentation vrstva používá ref.watch/read(activityControllerProvider),
/// DI (ActivityRepository) bere z core/di/providers.dart.
final activityControllerProvider =
    AsyncNotifierProvider<ActivityController, List<ActivityEntity>>(
  ActivityController.new,
);
