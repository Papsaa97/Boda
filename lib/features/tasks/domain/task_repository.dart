import 'task_entity.dart';

abstract class TaskRepository {
  Future<List<TaskEntity>> getAllTasks();
  Future<void> saveTask(TaskEntity task);
  Future<void> deleteTask(String id);
}
