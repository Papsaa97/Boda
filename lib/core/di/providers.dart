// lib/core/di/providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../features/activity/data/activity_hive_model.dart';
import '../../features/activity/data/hive_local_data_source.dart';
import '../../features/activity/data/activity_repository_impl.dart';
import '../../features/activity/domain/activity_repository.dart';
import '../../features/zones/data/zone_repository_impl.dart';
import '../../features/zones/domain/zone_repository.dart';
import '../photos/photo_storage.dart';

/// Provider pro Hive box s aktivitami.
///
/// V těle je jen placeholder – skutečný Box předáme v main.dart
/// pomocí ProviderScope(overrides: ...).
final activityBoxProvider = Provider<Box<ActivityHiveModel>>((ref) {
  throw UnimplementedError(
    'activityBoxProvider musí být override-nut v main.dart otevřeným Hive boxem.',
  );
});

/// Provider pro Hive box se zónami (klíč = id, hodnota = název).
final zoneBoxProvider = Provider<Box<String>>((ref) {
  throw UnimplementedError(
    'zoneBoxProvider musí být override-nut v main.dart otevřeným Hive boxem.',
  );
});

/// Provider pro lokální data source (Hive).
final hiveLocalDataSourceProvider = Provider<HiveLocalDataSource>((ref) {
  final box = ref.watch(activityBoxProvider);
  return HiveLocalDataSource(box);
});

/// Provider pro ActivityRepository (Domain vrstva).
///
/// Presentation (controllery, UI) budou číst tento provider.
final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final dataSource = ref.watch(hiveLocalDataSourceProvider);
  return ActivityRepositoryImpl(dataSource);
});

/// Provider pro ZoneRepository (Domain vrstva).
final zoneRepositoryProvider = Provider<ZoneRepository>((ref) {
  return ZoneRepositoryImpl(ref.watch(zoneBoxProvider));
});

/// Ukládání fotek k záznamům do složky aplikace.
final photoStorageProvider = Provider<PhotoStorage>((ref) => PhotoStorage());

/// Aktuální čas. V testech se přepisuje pevným datem.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
