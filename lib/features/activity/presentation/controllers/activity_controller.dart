import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/activity_entity.dart';
import '../../domain/activity_type.dart';
import '../../../../core/di/providers.dart';

/// Controller spravující seznam aktivit.
///
/// Stav je `AsyncValue<List<ActivityEntity>>`, seřazený od nejnovějšího
/// záznamu. Zápisy jdou přes `AsyncValue.guard()`, takže chyba úložiště
/// skončí jako `AsyncError` místo pádu aplikace.
class ActivityController extends AsyncNotifier<List<ActivityEntity>> {
  @override
  Future<List<ActivityEntity>> build() async {
    final activities = await ref
        .watch(activityRepositoryProvider)
        .getAllActivities();
    return _sorted(activities);
  }

  /// Uloží nový záznam. Vrací ho, nebo null, když se uložení nepovedlo.
  Future<ActivityEntity?> addActivity({
    required String title,
    required DateTime date,
    required String zoneId,
    ActivityType type = ActivityType.other,
    String? notes,
    List<PhotoRef> photos = const [],
  }) async {
    final now = ref.read(clockProvider)();
    final newActivity = ActivityEntity(
      id: ref.read(newIdProvider)(),
      type: type,
      title: title,
      date: date,
      zoneId: zoneId,
      notes: notes,
      photos: photos,
      createdAt: now,
      updatedAt: now,
    );

    final previous = state.value ?? const <ActivityEntity>[];
    await _mutate(() async {
      await ref.read(activityRepositoryProvider).addActivity(newActivity);
      return _sorted([...previous, newActivity]);
    });
    return state.hasError ? null : newActivity;
  }

  Future<void> updateActivity(ActivityEntity activity) async {
    final previous = state.value ?? const <ActivityEntity>[];
    await _mutate(() async {
      final updated = activity.copyWith(updatedAt: ref.read(clockProvider)());
      await ref.read(activityRepositoryProvider).updateActivity(updated);
      return _sorted([
        for (final a in previous)
          if (a.id == activity.id) updated else a,
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
  /// ale Riverpod v něm zachová poslední známý seznam, takže obrazovky
  /// nezmizí a volající pozná neúspěch přes `hasError`.
  Future<void> _mutate(Future<List<ActivityEntity>> Function() op) async {
    state = await AsyncValue.guard(op);
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
