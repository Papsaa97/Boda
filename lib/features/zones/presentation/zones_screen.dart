import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../activity/presentation/controllers/activity_controller.dart';
import '../domain/zone_entity.dart';
import 'zones_controller.dart';

/// Správa seznamu zón: přidat, přejmenovat, smazat.
class ZonesScreen extends ConsumerWidget {
  const ZonesScreen({super.key});

  Future<String?> _askName(BuildContext context, {String? initial}) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(initial == null ? 'Nová zóna' : 'Přejmenovat zónu'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'např. Záhon u plotu'),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zrušit'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Uložit'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final name = await _askName(context);
    if (name == null || name.trim().isEmpty) return;
    await ref.read(zonesControllerProvider.notifier).addZone(name);
  }

  Future<void> _rename(BuildContext context, WidgetRef ref, ZoneEntity zone) async {
    final name = await _askName(context, initial: zone.name);
    if (name == null || name.trim().isEmpty) return;
    await ref.read(zonesControllerProvider.notifier).renameZone(zone.id, name);
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ZoneEntity zone,
    int usage,
    int zoneCount,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    if (usage > 0) {
      messenger.showSnackBar(SnackBar(
        content: Text('Zónu ${zone.name} nejde smazat, má v deníku záznamy: $usage.'),
      ));
      return;
    }
    if (zoneCount <= 1) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Aspoň jedna zóna musí zůstat.'),
      ));
      return;
    }
    await ref.read(zonesControllerProvider.notifier).deleteZone(zone.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zonesAsync = ref.watch(zonesControllerProvider);
    final activities = ref.watch(activityControllerProvider).value ?? const [];

    final usage = <String, int>{};
    for (final a in activities) {
      usage[a.zoneId] = (usage[a.zoneId] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Zóny')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-zone',
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nová zóna'),
      ),
      body: zonesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Chyba: $error')),
        data: (zones) => ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            for (final zone in zones)
              ListTile(
                leading: const Icon(Icons.grass),
                title: Text(zone.name),
                subtitle: Text('Záznamů: ${usage[zone.id] ?? 0}'),
                onTap: () => _rename(context, ref, zone),
                trailing: IconButton(
                  tooltip: 'Smazat zónu',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _delete(
                      context, ref, zone, usage[zone.id] ?? 0, zones.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
