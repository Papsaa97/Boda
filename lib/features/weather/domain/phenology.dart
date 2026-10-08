import 'package:equatable/equatable.dart';

import '../../../core/time/calendar.dart';
import '../../activity/domain/activity_type.dart';
import '../../zones/domain/zone_entity.dart';

/// Jarní práce se s výškou posouvají později, podzimní dřív.
enum Season { spring, autumn }

/// Položka fenologického kalendáře (FR-W5): okno pro nížinu kolem
/// [referenceAltitudeM]; skutečné okno posune nadmořská výška.
class PhenologyEntry extends Equatable {
  const PhenologyEntry({
    required this.key,
    required this.title,
    required this.start,
    required this.end,
    required this.zoneTypes,
    required this.activity,
    this.season = Season.spring,
    this.note,
  });

  final String key;
  final String title;

  /// Začátek a konec okna jako (měsíc, den).
  final (int, int) start;
  final (int, int) end;
  final Set<ZoneType> zoneTypes;
  final ActivityType activity;
  final Season season;
  final String? note;

  @override
  List<Object?> get props => [key];
}

/// Nadmořská výška, ke které se vztahují okna v [phenologyTable].
const referenceAltitudeM = 250;

/// Výchozí výška, když ji uživatel nezadal (typická zahrada v ČR).
const defaultAltitudeM = 300;

/// Kolik dní posune 100 m výšky (Hopkinsův bioklimatický zákon,
/// zhruba 3 dny na 100 m).
const daysPer100m = 3.0;

/// Startovní tabulka pro ČR (DECLOG D87). Orientační termíny běžné
/// v českých zahradnických kalendářích; skutečný průběh jara je důležitější.
const phenologyTable = <PhenologyEntry>[
  PhenologyEntry(
    key: 'prune_apple',
    title: 'Zimní řez jabloní a hrušní',
    start: (2, 15),
    end: (3, 31),
    zoneTypes: {ZoneType.fruit},
    activity: ActivityType.pruning,
    note: 'Za suchého počasí a bez mrazu pod −5 °C.',
  ),
  PhenologyEntry(
    key: 'prune_currant',
    title: 'Řez rybízu a angreštu',
    start: (3, 1),
    end: (4, 10),
    zoneTypes: {ZoneType.fruit},
    activity: ActivityType.pruning,
  ),
  PhenologyEntry(
    key: 'sow_tomato_indoor',
    title: 'Předpěstování rajčat a paprik (výsev v teple)',
    start: (3, 1),
    end: (3, 31),
    zoneTypes: {ZoneType.vegetable, ZoneType.greenhouse},
    activity: ActivityType.sowing,
  ),
  PhenologyEntry(
    key: 'plant_onion',
    title: 'Sázení cibule sazečky',
    start: (3, 25),
    end: (4, 30),
    zoneTypes: {ZoneType.vegetable},
    activity: ActivityType.planting,
  ),
  PhenologyEntry(
    key: 'sow_carrot',
    title: 'Výsev mrkve a petržele',
    start: (3, 25),
    end: (4, 30),
    zoneTypes: {ZoneType.vegetable},
    activity: ActivityType.sowing,
  ),
  PhenologyEntry(
    key: 'sow_pea',
    title: 'Výsev hrachu',
    start: (3, 25),
    end: (4, 25),
    zoneTypes: {ZoneType.vegetable},
    activity: ActivityType.sowing,
  ),
  PhenologyEntry(
    key: 'sow_radish',
    title: 'Výsev ředkviček a salátu',
    start: (4, 1),
    end: (5, 15),
    zoneTypes: {ZoneType.vegetable},
    activity: ActivityType.sowing,
  ),
  PhenologyEntry(
    key: 'plant_potato',
    title: 'Sázení brambor',
    start: (4, 10),
    end: (5, 10),
    zoneTypes: {ZoneType.vegetable},
    activity: ActivityType.planting,
  ),
  PhenologyEntry(
    key: 'sow_lawn_spring',
    title: 'Výsev nebo dosev trávníku',
    start: (4, 15),
    end: (5, 31),
    zoneTypes: {ZoneType.lawn},
    activity: ActivityType.sowing,
  ),
  PhenologyEntry(
    key: 'plant_tomato_out',
    title: 'Výsadba rajčat, paprik a okurek ven',
    start: (5, 15),
    end: (6, 5),
    zoneTypes: {ZoneType.vegetable},
    activity: ActivityType.planting,
    note: 'Až po ledových mužích a bez mrazu v předpovědi.',
  ),
  PhenologyEntry(
    key: 'sow_bean',
    title: 'Výsev fazolí',
    start: (5, 15),
    end: (6, 10),
    zoneTypes: {ZoneType.vegetable},
    activity: ActivityType.sowing,
  ),
  PhenologyEntry(
    key: 'sow_basil',
    title: 'Výsev a výsadba bazalky ven',
    start: (5, 20),
    end: (6, 15),
    zoneTypes: {ZoneType.herbs},
    activity: ActivityType.sowing,
  ),
  PhenologyEntry(
    key: 'sow_lawn_autumn',
    title: 'Podzimní výsev nebo dosev trávníku',
    start: (8, 20),
    end: (9, 25),
    zoneTypes: {ZoneType.lawn},
    activity: ActivityType.sowing,
    season: Season.autumn,
  ),
  PhenologyEntry(
    key: 'plant_bulbs',
    title: 'Sázení cibulovin (tulipány, narcisy)',
    start: (9, 15),
    end: (10, 31),
    zoneTypes: {ZoneType.ornamental},
    activity: ActivityType.planting,
    season: Season.autumn,
  ),
  PhenologyEntry(
    key: 'plant_garlic',
    title: 'Sázení česneku',
    start: (9, 25),
    end: (10, 31),
    zoneTypes: {ZoneType.vegetable},
    activity: ActivityType.planting,
    season: Season.autumn,
  ),
  PhenologyEntry(
    key: 'plant_fruit_trees',
    title: 'Výsadba prostokořenných ovocných stromků',
    start: (10, 10),
    end: (11, 15),
    zoneTypes: {ZoneType.fruit},
    activity: ActivityType.planting,
    season: Season.autumn,
  ),
];

/// Okno práce v konkrétním roce a výšce.
class PhenologyWindow extends Equatable {
  const PhenologyWindow(this.entry, this.from, this.to);

  final PhenologyEntry entry;
  final DateTime from;
  final DateTime to;

  bool contains(DateTime day) {
    final d = dayOnly(day);
    return !d.isBefore(from) && !d.isAfter(to);
  }

  @override
  List<Object?> get props => [entry, from, to];
}

/// Posun okna ve dnech pro výšku [altitudeM].
int altitudeShiftDays(int altitudeM, Season season) {
  final days = ((altitudeM - referenceAltitudeM) / 100 * daysPer100m).round();
  return season == Season.spring ? days : -days;
}

PhenologyWindow windowFor(PhenologyEntry e, int year, int altitudeM) {
  final shift = altitudeShiftDays(altitudeM, e.season);
  return PhenologyWindow(
    e,
    DateTime(year, e.start.$1, e.start.$2 + shift),
    DateTime(year, e.end.$1, e.end.$2 + shift),
  );
}

/// Co je teď na řadě a co přijde v příštích [aheadDays] dnech, jen pro
/// druhy zón, které zahrada má. Seřazeno podle začátku okna.
({List<PhenologyWindow> now, List<PhenologyWindow> soon}) phenologyAgenda({
  required DateTime today,
  required int? altitudeM,
  required Set<ZoneType> zoneTypes,
  int aheadDays = 21,
}) {
  final altitude = altitudeM ?? defaultAltitudeM;
  final day = dayOnly(today);
  final horizon = DateTime(day.year, day.month, day.day + aheadDays);
  final now = <PhenologyWindow>[];
  final soon = <PhenologyWindow>[];
  for (final e in phenologyTable) {
    if (e.zoneTypes.intersection(zoneTypes).isEmpty) continue;
    final w = windowFor(e, day.year, altitude);
    if (w.contains(day)) {
      now.add(w);
    } else if (w.from.isAfter(day) && !w.from.isAfter(horizon)) {
      soon.add(w);
    }
  }
  int byStart(PhenologyWindow a, PhenologyWindow b) => a.from.compareTo(b.from);
  return (now: now..sort(byStart), soon: soon..sort(byStart));
}
