import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatting/dates.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../zones/presentation/zones_controller.dart';
import '../../domain/activity_entity.dart';
import '../activity_type_ui.dart';
import '../screens/activity_detail_screen.dart';
import 'activity_photo.dart';

/// Řádek záznamu v časové ose a na dashboardu.
class ActivityTile extends ConsumerWidget {
  const ActivityTile({
    super.key,
    required this.activity,
    this.showDate = false,
  });

  final ActivityEntity activity;

  /// Zobrazit celé datum místo jen času.
  final bool showDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final zoneName =
        ref.watch(zoneNameProvider(activity.zoneId)) ?? l.commonUnknownZone;
    final when = showDate
        ? formatDateTime(activity.date)
        : formatTime(activity.date);
    final cover = activity.coverPhoto;
    final morePhotos = activity.photos.length - 1;

    return ListTile(
      leading: cover == null
          ? Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                activityTypeIcon(activity.type),
                color: scheme.primary,
              ),
            )
          : Badge(
              isLabelVisible: morePhotos > 0,
              label: Text('+$morePhotos'),
              child: ActivityPhoto(path: cover.path, width: 56, height: 56),
            ),
      title: Text(activity.title),
      subtitle: Text('$when · $zoneName'),
      trailing: activity.notes != null
          ? Icon(Icons.notes, size: 18, semanticLabel: l.activityHasNote)
          : null,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ActivityDetailScreen(activityId: activity.id),
        ),
      ),
    );
  }
}
