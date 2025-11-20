import 'activity_entity.dart';

abstract class ActivityRepository {
  Future<List<ActivityEntity>> getAllActivities();
  Future<ActivityEntity?> getActivityById(String id);
  Future<void> addActivity(ActivityEntity activity);
  Future<void> updateActivity(ActivityEntity activity);
  Future<void> deleteActivity(String id);
}
