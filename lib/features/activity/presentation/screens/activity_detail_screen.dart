import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/formatting/dates.dart';
import '../../../../core/text/numbers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../zones/domain/zone_entity.dart';
import '../../../zones/presentation/zone_icons.dart';
import '../../../zones/presentation/zones_controller.dart';
import '../../domain/activity_entity.dart';
import '../activity_type_ui.dart';
import '../controllers/activity_controller.dart';
import '../widgets/activity_photo.dart';
import 'activity_form_screen.dart';

/// Detail jednoho záznamu s úpravou a smazáním.
class ActivityDetailScreen extends ConsumerWidget {
  const ActivityDetailScreen({super.key, required this.activityId});

  final String activityId;

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ActivityEntity activity,
  ) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.activityDeleteTitle),
        content: Text(l.activityDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final storage = ref.read(photoStorageProvider);
    await ref
        .read(activityControllerProvider.notifier)
        .deleteActivity(activity.id);
    if (!context.mounted) return;
    if (ref.read(activityControllerProvider).hasError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.activityDeleteFailed)));
      return;
    }
    Navigator.of(context).pop();
    for (final photo in activity.photos) {
      await storage.delete(photo.path);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final activities = ref.watch(activityControllerProvider).value ?? const [];
    final activity = activities.where((a) => a.id == activityId).firstOrNull;

    if (activity == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l.activityGone)),
      );
    }

    final zone = ref.watch(zoneByIdProvider(activity.zoneId));
    final textTheme = Theme.of(context).textTheme;
    final photos = activity.photos;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.activityDetailTitle),
        actions: [
          IconButton(
            tooltip: l.commonEdit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ActivityFormScreen(initial: activity),
              ),
            ),
          ),
          IconButton(
            tooltip: l.commonDelete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref, activity),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (photos.isNotEmpty) ...[
            SizedBox(
              height: 260,
              child: PageView.builder(
                itemCount: photos.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Semantics(
                    button: true,
                    label: l.photoOpenFullscreen,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PhotoViewerScreen(
                            paths: [for (final p in photos) p.path],
                            title: activity.title,
                            initialIndex: i,
                          ),
                        ),
                      ),
                      child: ActivityPhoto(
                        path: photos[i].path,
                        height: 260,
                        borderRadius: 20,
                        iconSize: 64,
                      ),
                    ),
                  ),
                ),
              ),
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
                avatar: Icon(activityTypeIcon(activity.type), size: 18),
                label: Text(activityTypeLabel(l, activity.type)),
              ),
              Chip(
                avatar: const Icon(Icons.schedule, size: 18),
                label: Text(formatDateTime(activity.date)),
              ),
              Chip(
                avatar: Icon(zoneIcon(zone?.type ?? ZoneType.other), size: 18),
                label: Text(zone?.name ?? l.commonUnknownZone),
              ),
              if (activity.harvestQty != null)
                Chip(
                  avatar: const Icon(Icons.shopping_basket_outlined, size: 18),
                  label: Text(
                    l.activityHarvestValue(
                      '${formatDecimal(activity.harvestQty!)} '
                      '${harvestUnitLabel(l, activity.harvestUnit ?? 'kg')}',
                    ),
                  ),
                ),
              if (activity.costCzk != null)
                Chip(
                  avatar: const Icon(Icons.payments_outlined, size: 18),
                  label: Text(
                    l.activityCostValue(formatDecimal(activity.costCzk!)),
                  ),
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
