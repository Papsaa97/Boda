import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatting/dates.dart';
import '../../../zones/presentation/zones_controller.dart';
import '../../domain/activity_entity.dart';
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
    final zoneName = ref.watch(zoneNameProvider(activity.zoneId));
    final when = showDate
        ? formatDateTime(activity.date)
        : formatTime(activity.date);

    return ListTile(
      leading: ActivityPhoto(path: activity.imagePath, width: 56, height: 56),
      title: Text(activity.title),
      subtitle: Text('$when · $zoneName'),
      trailing: activity.notes != null
          ? const Icon(Icons.notes, size: 18)
          : null,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ActivityDetailScreen(activityId: activity.id),
        ),
      ),
    );
  }
}
