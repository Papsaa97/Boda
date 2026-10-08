import 'package:hive_ce/hive.dart';

import 'activity_hive_model.dart';

class HiveLocalDataSource {
  final Box<ActivityHiveModel> _box;

  HiveLocalDataSource(this._box);

  List<ActivityHiveModel> getAll() {
    return _box.values.toList();
  }

  ActivityHiveModel? getById(String id) {
    return _box.get(id);
  }

  Future<void> add(ActivityHiveModel model) async {
    await _box.put(model.id, model);
  }

  Future<void> update(ActivityHiveModel model) async {
    await _box.put(model.id, model);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
