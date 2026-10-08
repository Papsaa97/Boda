import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/di/providers.dart';
import 'core/formatting/dates.dart';
import 'core/photos/photo_storage.dart';
import 'core/storage/local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting(appLocale);
  await Hive.initFlutter();

  // Na webu fotky nejsou (prohlížeč nemá trvalou složku pro soubory).
  final photos = kIsWeb
      ? PhotoStorage('')
      : PhotoStorage((await getApplicationDocumentsDirectory()).path);

  final boxes = await openLocalBoxes(photos: kIsWeb ? null : photos);

  runApp(
    ProviderScope(
      overrides: [
        activityBoxProvider.overrideWithValue(boxes.activities),
        zoneBoxProvider.overrideWithValue(boxes.zones),
        photoStorageProvider.overrideWithValue(photos),
      ],
      child: const ZahradnikBodaApp(),
    ),
  );
}
