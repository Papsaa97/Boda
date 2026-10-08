import 'package:flutter_riverpod/misc.dart';

import '../../activity/presentation/controllers/activity_controller.dart';
import '../../assistant/presentation/assistant_controller.dart';
import '../../builds/presentation/builds_controller.dart';
import '../../canvas/presentation/canvas_controller.dart';
import '../../incidents/presentation/incidents_controller.dart';
import '../../inventory/presentation/inventory_controller.dart';
import '../../tasks/presentation/tasks_controller.dart';
import '../../weather/presentation/weather_controller.dart';
import '../../zones/presentation/zones_controller.dart';

/// Obrazovky načtou data zahrady znovu z databáze: po stažení změn ze
/// serveru nebo po obnově zálohy. Předává se `ref.invalidate`.
void reloadGardenData(void Function(ProviderOrFamily) invalidate) {
  for (final provider in <ProviderOrFamily>[
    zonesControllerProvider,
    activityControllerProvider,
    tasksControllerProvider,
    inventoryControllerProvider,
    shoppingControllerProvider,
    assistantControllerProvider,
    incidentsControllerProvider,
    weatherControllerProvider,
    buildsControllerProvider,
    canvasControllerProvider,
  ]) {
    invalidate(provider);
  }
}
