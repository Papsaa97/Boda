import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/dates.dart';
import '../../../core/text/numbers.dart';
import '../../../l10n/app_localizations.dart';
import '../../activity/presentation/controllers/activity_controller.dart';
import '../../activity/presentation/widgets/activity_tile.dart';
import '../domain/zone_entity.dart';
import 'zone_form_screen.dart';
import 'zone_icons.dart';
import 'zones_controller.dart';

/// Detail zóny: vlastnosti a poslední záznamy.
class ZoneDetailScreen extends ConsumerWidget {
  const ZoneDetailScreen({super.key, required this.zoneId});

  final String zoneId;

  static const _recentCount = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final zone = ref.watch(zoneByIdProvider(zoneId));
    if (zone == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l.commonUnknownZone)),
      );
    }
    final activities = (ref.watch(activityControllerProvider).value ?? [])
        .where((a) => a.zoneId == zoneId)
        .toList();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(zone.name),
        actions: [
          IconButton(
            tooltip: l.zoneEdit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ZoneFormScreen(zone: zone)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            leading: Icon(zoneIcon(zone.type)),
            title: Text(zoneTypeLabel(l, zone.type)),
            subtitle: Text(l.zoneActivityCount(activities.length)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(l.zonePropertiesTitle, style: textTheme.titleSmall),
          ),
          if (!zone.hasProperties)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(l.zonePropertiesEmpty),
            )
          else
            ..._properties(l, zone),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
            child: Text(l.zoneRecentActivities, style: textTheme.titleSmall),
          ),
          if (activities.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(l.zoneNoActivities),
            )
          else
            for (final a in activities.take(_recentCount))
              ActivityTile(activity: a, showDate: true),
        ],
      ),
    );
  }

  List<Widget> _properties(AppLocalizations l, ZoneEntity zone) {
    Widget row(IconData icon, String label, String value) => ListTile(
      dense: true,
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(value),
    );
    final ph = zone.ph;
    return [
      if (zone.areaM2 != null)
        row(
          Icons.square_foot,
          l.zoneAreaLabel,
          l.zoneAreaValue(formatDecimal(zone.areaM2!)),
        ),
      if (zone.soilTexture != null)
        row(
          Icons.landscape_outlined,
          l.zoneSoilLabel,
          soilTextureLabel(l, zone.soilTexture!),
        ),
      if (ph != null)
        row(
          Icons.science_outlined,
          l.zonePhLabel,
          zone.phMeasuredAt == null
              ? l.zonePhValue(formatDecimal(ph, maxFractionDigits: 1))
              : l.zonePhValueDated(
                  formatDecimal(ph, maxFractionDigits: 1),
                  formatDate(zone.phMeasuredAt!),
                ),
        ),
      if (zone.sunExposure != null)
        row(
          Icons.wb_sunny_outlined,
          l.zoneSunLabel,
          sunExposureLabel(l, zone.sunExposure!),
        ),
      if (zone.irrigation != null)
        row(
          Icons.water_drop_outlined,
          l.zoneIrrigationLabel,
          irrigationLabel(l, zone.irrigation!),
        ),
      if (zone.covered)
        row(Icons.house_siding, l.zoneCoveredLabel, l.zoneCoveredYes),
    ];
  }
}
