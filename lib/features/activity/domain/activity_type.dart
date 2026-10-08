import '../../../core/text/normalize.dart';

/// Typ činnosti v deníku (specifikace, kap. 8.3).
///
/// Ukládá se anglický klíč ([key]); české popisky a ikony jsou
/// v prezentační vrstvě.
enum ActivityType {
  sowing,
  planting,
  watering,
  fertilizing,
  spraying,
  pruning,
  harvest,
  weeding,
  mowing,
  other;

  String get key => name;

  /// Typ podle uloženého klíče; neznámý klíč je [other].
  static ActivityType fromKey(String? key) {
    for (final type in values) {
      if (type.key == key) return type;
    }
    return other;
  }

  /// Odhad typu z volného názvu záznamu. Používá se při převodu záznamů
  /// z verze 0.1, které typ neměly.
  static ActivityType guessFromTitle(String title) {
    final t = normalizeForSearch(title);
    bool has(List<String> stems) => stems.any(t.contains);
    if (has(['zaliv', 'zalev', 'zalit', 'zalij'])) return watering;
    if (has(['plet', 'odplev', 'plevel'])) return weeding;
    if (has(['hnoj', 'kompost'])) return fertilizing;
    if (has(['vysev', 'vysit', 'vysel', 'set '])) return sowing;
    if (has(['vysad', 'sazen', 'sadit', 'presaz'])) return planting;
    if (has(['skliz', 'sber', 'sklid'])) return harvest;
    if (has(['rez ', 'prorez', 'rezat', 'strih'])) return pruning;
    if (has(['sekan', 'posek', 'sekat', 'trav'])) return mowing;
    if (has(['postrik', 'osetr', 'strik'])) return spraying;
    if (t == 'rez' || t.startsWith('rez ')) return pruning;
    return other;
  }
}
