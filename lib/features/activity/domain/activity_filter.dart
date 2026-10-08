import '../../../core/text/normalize.dart';
import 'activity_entity.dart';
import 'activity_type.dart';

/// Filtr deníku: zóna, typ činnosti a fulltext v názvu a poznámce (FR-D7).
class ActivityFilter {
  const ActivityFilter({this.zoneId, this.type, this.query = ''});

  final String? zoneId;
  final ActivityType? type;
  final String query;

  bool get isActive =>
      zoneId != null || type != null || query.trim().isNotEmpty;

  List<ActivityEntity> apply(List<ActivityEntity> activities) {
    final needle = normalizeForSearch(query.trim());
    return [
      for (final a in activities)
        if ((zoneId == null || a.zoneId == zoneId) &&
            (type == null || a.type == type) &&
            (needle.isEmpty ||
                normalizeForSearch(
                  '${a.title} ${a.notes ?? ''}',
                ).contains(needle)))
          a,
    ];
  }
}
