import 'task_entity.dart';

abstract class TaskRepository {
  Future<List<TaskEntity>> getAllTasks();
  Future<void> saveTask(TaskEntity task);
  Future<void> deleteTask(String id);

  /// Zapíše materiál úkolu jako spotřebovaný u záznamu [activityId].
  Future<void> recordMaterialsUsed(TaskEntity task, String activityId);
}
