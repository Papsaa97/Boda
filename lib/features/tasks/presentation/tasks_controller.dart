import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/time/calendar.dart';
import '../../../core/telemetry/telemetry.dart';
import '../../inventory/domain/stock_movement.dart';
import '../../inventory/presentation/inventory_controller.dart';
import '../domain/task_actions.dart';
import '../domain/task_entity.dart';

/// Všechny úkoly, seřazené podle dne, kdy jsou na řadě.
class TasksController extends AsyncNotifier<List<TaskEntity>> {
  @override
  Future<List<TaskEntity>> build() async {
    return _sorted(await ref.watch(taskRepositoryProvider).getAllTasks());
  }

  DateTime get _now => ref.read(clockProvider)();

  Future<void> save(TaskEntity task) async {
    final now = _now;
    final stored = task.copyWith(
      createdAt: task.createdAt ?? now,
      updatedAt: now,
    );
    await _mutate((list) async {
      await ref.read(taskRepositoryProvider).saveTask(stored);
      return [...list.where((t) => t.id != stored.id), stored];
    });
  }

  /// Nový úkol s vygenerovaným id.
  Future<TaskEntity> create(TaskEntity draft) async {
    final task = TaskEntity(
      id: ref.read(newIdProvider)(),
      title: draft.title,
      zoneId: draft.zoneId,
      due: draft.due,
      remindAt: draft.remindAt,
      rrule: draft.rrule,
      notes: draft.notes,
      durationEstMin: draft.durationEstMin,
      tools: draft.tools,
      materials: draft.materials,
      source: draft.source,
      incidentId: draft.incidentId,
    );
    await save(task);
    return task;
  }

  /// Uzavře úkol (hotovo / přeskočeno); u opakovaného založí další výskyt.
  Future<TaskClosure?> close(String id, TaskStatus status) async {
    final task = _find(id);
    if (task == null) return null;
    final closure = closeTask(
      task,
      status: status,
      now: _now,
      nextId: ref.read(newIdProvider)(),
    );
    await _mutate((list) async {
      final repo = ref.read(taskRepositoryProvider);
      await repo.saveTask(closure.closed);
      final next = closure.next;
      if (next != null) await repo.saveTask(next);
      return [...list.where((t) => t.id != id), closure.closed, ?next];
    });
    if (state.hasError) return null;
    if (status != TaskStatus.done) return closure;
    ref.read(analyticsProvider).track(AnalyticsEvent.taskCompleted, {
      'source': task.source.name,
    });
    // Odpis materiálu (FR-S4). Selhání nevadí: úkol už je hotový.
    final consumption = await ref
        .read(inventoryControllerProvider.notifier)
        .consumeForTask(closure.closed);
    return TaskClosure(
      closure.closed,
      closure.next,
      consumption: consumption ?? const Consumption(),
    );
  }

  /// Vrátí uzavřený úkol mezi otevřené.
  Future<void> reopen(String id) async {
    final task = _find(id);
    if (task == null) return;
    await save(task.copyWith(status: TaskStatus.open, completedAt: () => null));
    if (state.hasError || task.status != TaskStatus.done) return;
    try {
      await ref.read(inventoryControllerProvider.notifier).reverseTask(id);
    } on Exception catch (e) {
      debugPrint('Odpis ze skladu se nepodařilo stornovat: $e');
    }
  }

  Future<void> snooze(String id, SnoozeOption option) async {
    final task = _find(id);
    if (task == null) return;
    await save(task.copyWith(snoozedUntil: () => snoozeTarget(option, _now)));
  }

  /// Odloží úkol na den [day] (zálivka po dešti, FR-W3).
  Future<void> postponeTo(String id, DateTime day) async {
    final task = _find(id);
    if (task == null) return;
    await save(task.copyWith(snoozedUntil: () => dayOnly(day)));
  }

  /// Propojí hotový úkol se záznamem v deníku (FR-U4).
  Future<void> linkActivity(String id, String activityId) async {
    final task = _find(id);
    if (task == null) return;
    await save(task.copyWith(completedActivityId: () => activityId));
    if (task.materials.isNotEmpty && !state.hasError) {
      // Spotřebovaný materiál se zapíše i k záznamu (odpis ze skladu
      // proběhl při dokončení). Selhání nevadí: záznam i úkol už jsou
      // uložené.
      try {
        await ref
            .read(taskRepositoryProvider)
            .recordMaterialsUsed(task, activityId);
      } on Exception catch (e) {
        debugPrint('Materiál k záznamu se nepodařilo zapsat: $e');
      }
    }
  }

  Future<void> delete(String id) async {
    await _mutate((list) async {
      await ref.read(taskRepositoryProvider).deleteTask(id);
      return list.where((t) => t.id != id).toList();
    });
  }

  TaskEntity? _find(String id) => (state.value ?? const <TaskEntity>[])
      .where((t) => t.id == id)
      .firstOrNull;

  Future<void> _mutate(
    Future<List<TaskEntity>> Function(List<TaskEntity> current) op,
  ) async {
    // Při chybě Riverpod ve stavu zachová poslední seznam (viz
    // ActivityController._mutate).
    final current = state.value ?? const <TaskEntity>[];
    state = await AsyncValue.guard(() async => _sorted(await op(current)));
  }

  static List<TaskEntity> _sorted(List<TaskEntity> tasks) =>
      [...tasks]..sort((a, b) {
        final byDate = a.effectiveDate.compareTo(b.effectiveDate);
        if (byDate != 0) return byDate;
        return (a.remindAt ?? 24 * 60).compareTo(b.remindAt ?? 24 * 60);
      });
}

final tasksControllerProvider =
    AsyncNotifierProvider<TasksController, List<TaskEntity>>(
      TasksController.new,
    );
