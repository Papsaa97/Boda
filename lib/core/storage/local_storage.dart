import 'package:hive_ce/hive.dart';

import '../../features/activity/data/activity_hive_model.dart';
import '../../features/zones/data/zone_repository_impl.dart';
import '../../hive_registrar.g.dart';
import '../photos/photo_storage.dart';

/// Otevřené lokální úložiště aplikace.
class LocalBoxes {
  const LocalBoxes({required this.activities, required this.zones});

  final Box<ActivityHiveModel> activities;

  /// Zóny: klíč je id, hodnota název.
  final Box<String> zones;
}

/// Otevře boxy a provede jednorázové úpravy dat ze starších verzí.
///
/// Hive musí být předem inicializovaný (`Hive.initFlutter()` v aplikaci,
/// `Hive.init(cesta)` v testech).
Future<LocalBoxes> openLocalBoxes({PhotoStorage? photos}) async {
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapters();
  }

  final activities = await Hive.openBox<ActivityHiveModel>('activities');
  final zones = await Hive.openBox<String>('zones');

  // Kdo má záznamy z verze bez seznamu zón, dostane výchozí zóny
  // a onboarding přeskočí. Nový uživatel si zóny vybere sám.
  if (activities.isNotEmpty) {
    await ZoneRepositoryImpl(zones).seedDefaultsIfEmpty();
  }

  if (photos != null) {
    await adoptLegacyPhotos(activities, photos);
  }

  return LocalBoxes(activities: activities, zones: zones);
}

/// Převede absolutní cesty k fotkám na relativní a fotky mimo složku
/// aplikace do ní zkopíruje (verze 0.1 ukládala cestu do cache).
Future<void> adoptLegacyPhotos(
  Box<ActivityHiveModel> activities,
  PhotoStorage photos,
) async {
  for (final model in activities.values.toList()) {
    final stored = model.imagePath;
    if (stored == null || stored.isEmpty) continue;
    final adopted = await photos.adopt(stored);
    if (adopted != null && adopted != stored) {
      model.imagePath = adopted;
      await activities.put(model.id, model);
    }
  }
}
