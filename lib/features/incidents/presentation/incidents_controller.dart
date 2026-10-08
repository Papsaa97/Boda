import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/time/calendar.dart';
import '../../activity/domain/activity_entity.dart';
import '../../tasks/domain/task_entity.dart';
import '../../tasks/presentation/tasks_controller.dart';
import '../domain/incident.dart';

/// Incidenty zahrady, otevřené první a nejnovější nahoře (FR-V3, FR-V4).
class IncidentsController extends AsyncNotifier<List<Incident>> {
  @override
  Future<List<Incident>> build() async =>
      _sorted(await ref.watch(incidentRepositoryProvider).getAll());

  DateTime get _now => ref.read(clockProvider)();

  /// Založí incident a naplánuje kontroly D+3 a D+7 v jeho zóně.
  /// [checkTitle] je text úkolu kontroly (lokalizovaný v UI).
  Future<Incident?> create({
    required String zoneId,
    required String label,
    required String Function(int day) checkTitle,
    String? planBio,
    String? planChem,
    List<PhotoRef> photos = const [],
    IncidentSource source = IncidentSource.user,
    List<IncidentCandidate> candidates = const [],
  }) async {
    final now = _now;
    final incident = Incident(
      id: ref.read(newIdProvider)(),
      zoneId: zoneId,
      label: label.trim(),
      source: source,
      candidates: candidates,
      planBio: _blank(planBio),
      planChem: _blank(planChem),
      photos: photos,
      createdAt: now,
      updatedAt: now,
    );
    await _mutate((list) async {
      await ref.read(incidentRepositoryProvider).save(incident);
      return [...list, incident];
    });
    if (state.hasError) return null;
    final tasks = ref.read(tasksControllerProvider.notifier);
    final today = dayOnly(now);
    for (final day in incidentCheckDays) {
      await tasks.create(
        TaskEntity(
          id: '',
          title: checkTitle(day),
          zoneId: zoneId,
          due: DateTime(today.year, today.month, today.day + day),
          incidentId: incident.id,
        ),
      );
    }
    return incident;
  }

  Future<void> save(Incident incident) async {
    final stored = incident.copyWith(
      label: incident.label.trim(),
      planBio: () => _blank(incident.planBio),
      planChem: () => _blank(incident.planChem),
      updatedAt: _now,
    );
    await _mutate((list) async {
      await ref.read(incidentRepositoryProvider).save(stored);
      return [...list.where((i) => i.id != stored.id), stored];
    });
  }

  /// Vyřešeno / znovu otevřít. Vyřešený incident přeskočí otevřené
  /// kontroly, ať zbytečně nepřipomínají.
  Future<void> setStatus(String id, IncidentStatus status) async {
    final incident = _find(id);
    if (incident == null || incident.status == status) return;
    await save(incident.copyWith(status: status));
    if (state.hasError || status != IncidentStatus.resolved) return;
    final tasks = ref.read(tasksControllerProvider.notifier);
    final open = (ref.read(tasksControllerProvider).value ?? const [])
        .where((t) => t.incidentId == id && t.isOpen)
        .toList();
    for (final t in open) {
      await tasks.close(t.id, TaskStatus.skipped);
    }
  }

  /// Smaže kartu; otevřené kontroly (D+3, D+7) k ní se přeskočí, aby
  /// nepřipomínaly něco, co už neexistuje.
  Future<void> delete(String id) async {
    await _mutate((list) async {
      await ref.read(incidentRepositoryProvider).delete(id);
      return list.where((i) => i.id != id).toList();
    });
    if (state.hasError) return;
    final tasks = ref.read(tasksControllerProvider.notifier);
    final open = (ref.read(tasksControllerProvider).value ?? const [])
        .where((t) => t.incidentId == id && t.isOpen)
        .toList();
    for (final t in open) {
      await tasks.close(t.id, TaskStatus.skipped);
    }
  }

  Incident? _find(String id) =>
      (state.value ?? const <Incident>[]).where((i) => i.id == id).firstOrNull;

  Future<void> _mutate(
    Future<List<Incident>> Function(List<Incident> current) op,
  ) async {
    final current = state.value ?? const <Incident>[];
    state = await AsyncValue.guard(() async => _sorted(await op(current)));
  }

  static String? _blank(String? v) =>
      v == null || v.trim().isEmpty ? null : v.trim();

  static List<Incident> _sorted(List<Incident> list) => [...list]
    ..sort((a, b) {
      if (a.isOpen != b.isOpen) return a.isOpen ? -1 : 1;
      final at = a.createdAt ?? DateTime(0);
      final bt = b.createdAt ?? DateTime(0);
      return bt.compareTo(at);
    });
}

final incidentsControllerProvider =
    AsyncNotifierProvider<IncidentsController, List<Incident>>(
      IncidentsController.new,
    );

final incidentByIdProvider = Provider.family<Incident?, String>(
  (ref, id) => ref
      .watch(incidentsControllerProvider)
      .value
      ?.where((i) => i.id == id)
      .firstOrNull,
);

/// Kontroly incidentu (úkoly s `incidentId`) podle termínu.
final incidentChecksProvider = Provider.family<List<TaskEntity>, String>(
  (ref, id) =>
      (ref.watch(tasksControllerProvider).value ?? const <TaskEntity>[])
          .where((t) => t.incidentId == id)
          .toList()
        ..sort((a, b) => a.due.compareTo(b.due)),
);

/// Počet otevřených incidentů (pro kartu v Zónách).
final openIncidentCountProvider = Provider<int>(
  (ref) => (ref.watch(incidentsControllerProvider).value ?? const <Incident>[])
      .where((i) => i.isOpen)
      .length,
);
