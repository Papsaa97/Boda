import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/di/providers.dart';
import 'features/activity/data/activity_hive_model.dart';
import 'features/activity/presentation/screens/activity_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Registrace Hive adapteru pro ActivityHiveModel.
  Hive.registerAdapter(ActivityHiveModelAdapter());

  // Otevření boxu pro aktivity. Název 'activities' je náš lokální "stůl".
  final activityBox = await Hive.openBox<ActivityHiveModel>('activities');

  runApp(
    ProviderScope(
      overrides: [
        // Tady dodáme konkrétní box do provideru activityBoxProvider.
        activityBoxProvider.overrideWithValue(activityBox),
      ],
      child: const ZahradnikBodaApp(),
    ),
  );
}

class ZahradnikBodaApp extends StatelessWidget {
  const ZahradnikBodaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zahradník Bóďa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const ActivityListScreen(),
    );
  }
}
