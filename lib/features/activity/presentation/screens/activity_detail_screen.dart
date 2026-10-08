// lib/features/activity/presentation/screens/activity_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/formatting/dates.dart';
import '../../../zones/presentation/zones_controller.dart';
import '../controllers/activity_controller.dart';
import '../widgets/activity_photo.dart';
import 'activity_form_screen.dart';
import '../../../zones/presentation/zone_icons.dart';

/// Detail jednoho záznamu s úpravou a smazáním.
class ActivityDetailScreen extends ConsumerWidget {
  const ActivityDetailScreen({super.key, required this.activityId});

  final String activityId;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Smazat záznam?'),
        content: const Text('Záznam i jeho fotka zmizí z deníku.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Zrušit'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Smazat'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final activities = ref.read(activityControllerProvider).value ?? const [];
    final imagePath = activities
        .where((a) => a.id == activityId)
        .map((a) => a.imagePath)
        .firstOrNull;

    final photos = ref.read(photoStorageProvider);
    await ref.read(activityControllerProvider.notifier).deleteActivity(activityId);
    if (!context.mounted) return;
    if (ref.read(activityControllerProvider).hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Záznam se nepodařilo smazat.')),
      );
      return;
    }
    Navigator.of(context).pop();
    await photos.delete(imagePath);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activityControllerProvider).value ?? const [];
    final activity = activities.where((a) => a.id == activityId).firstOrNull;

    if (activity == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Záznam už neexistuje.')),
      );
    }

    final zoneName = ref.watch(zoneNameProvider(activity.zoneId));
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Záznam'),
        actions: [
          IconButton(
            tooltip: 'Upravit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ActivityFormScreen(initial: activity),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Smazat',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (activity.imagePath != null) ...[
            ActivityPhoto(
              path: activity.imagePath,
              height: 260,
              borderRadius: 20,
              iconSize: 64,
            ),
            const SizedBox(height: 16),
          ],
          Text(activity.title, style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.schedule, size: 18),
                label: Text(formatDateTime(activity.date)),
              ),
              Chip(
                avatar: Icon(zoneIcon(activity.zoneId), size: 18),
                label: Text(zoneName),
              ),
            ],
          ),
          if (activity.notes != null) ...[
            const SizedBox(height: 16),
            Text(activity.notes!, style: textTheme.bodyLarge),
          ],
        ],
      ),
    );
  }
}
