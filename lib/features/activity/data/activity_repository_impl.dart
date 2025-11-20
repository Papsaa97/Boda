// lib/features/activity/data/activity_repository_impl.dart

import 'package:zahradnik_boda_mvp01/features/activity/domain/activity_entity.dart';
import 'package:zahradnik_boda_mvp01/features/activity/domain/activity_repository.dart';

import 'activity_hive_model.dart';
import 'hive_local_data_source.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final HiveLocalDataSource _localDataSource;

  ActivityRepositoryImpl(this._localDataSource);

  @override
  Future<List<ActivityEntity>> getAllActivities() async {
    // Data vrstva vrací synchronní list, repo ho jen wrapne do Future
    final models = _localDataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ActivityEntity?> getActivityById(String id) async {
    final model = _localDataSource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<void> addActivity(ActivityEntity activity) async {
    final model = ActivityHiveModel.fromEntity(activity);
    await _localDataSource.add(model);
  }

  @override
  Future<void> updateActivity(ActivityEntity activity) async {
    final model = ActivityHiveModel.fromEntity(activity);
    await _localDataSource.update(model);
  }

  @override
  Future<void> deleteActivity(String id) {
    return _localDataSource.delete(id);
  }
}
