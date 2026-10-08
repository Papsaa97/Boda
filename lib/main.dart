import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/di/providers.dart';
import 'core/formatting/dates.dart';
import 'features/activity/data/activity_hive_model.dart';
import 'features/zones/data/zone_repository_impl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting(appLocale);
  await Hive.initFlutter();

  // Registrace Hive adapteru pro ActivityHiveModel.
  Hive.registerAdapter(ActivityHiveModelAdapter());

  // Otevření boxů. 'activities' drží deník, 'zones' seznam zón.
  final activityBox = await Hive.openBox<ActivityHiveModel>('activities');
  final zoneBox = await Hive.openBox<String>('zones');
  // Kdo už má záznamy z verze před onboardingem, dostane výchozí zóny
  // a onboarding přeskočí. Nový uživatel si zóny vybere sám.
  if (activityBox.isNotEmpty) {
    await ZoneRepositoryImpl(zoneBox).seedDefaultsIfEmpty();
  }

  runApp(
    ProviderScope(
      overrides: [
        activityBoxProvider.overrideWithValue(activityBox),
        zoneBoxProvider.overrideWithValue(zoneBox),
      ],
      child: const ZahradnikBodaApp(),
    ),
  );
}
