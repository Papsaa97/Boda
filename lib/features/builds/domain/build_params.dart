/// Šablony staveb (spec 5.7, FR-G1).
enum BuildTemplate {
  raisedBed('raised_bed'),
  path('path'),
  bridge('bridge'),
  shelter('shelter');

  const BuildTemplate(this.key);

  /// Hodnota ve sloupci `builds.template`.
  final String key;

  static BuildTemplate? fromKey(String? key) =>
      values.where((t) => t.key == key).firstOrNull;

  List<ParamSpec> get params => switch (this) {
    raisedBed => const [
      NumberParam('length', min: 0.5, max: 6, initial: 2),
      NumberParam('width', min: 0.4, max: 2, initial: 1),
      NumberParam('height', min: 0.2, max: 1, initial: 0.6),
      ChoiceParam('boardThickness', ['25', '32', '40'], initial: '32'),
      ToggleParam('moleMesh', initial: true),
      ToggleParam('liner', initial: true),
    ],
    path => const [
      NumberParam('length', min: 1, max: 100, initial: 10),
      NumberParam('width', min: 0.4, max: 3, initial: 1),
      ChoiceParam('surface', [
        'gravel',
        'pavers',
        'stepping',
        'mulch',
      ], initial: 'gravel'),
      ToggleParam('edging', initial: true),
    ],
    bridge => const [
      NumberParam('span', min: 0.5, max: 6, initial: 2),
      NumberParam('width', min: 0.5, max: 2, initial: 1),
      ChoiceParam('beamSection', [
        '100x100',
        '80x160',
        '100x200',
        '120x240',
        '140x280',
      ], initial: '100x200'),
      ChoiceParam('beamCount', ['2', '3', '4', '5', '6'], initial: '3'),
      ChoiceParam('deckThickness', ['28', '32', '40'], initial: '32'),
      NumberParam('heightAbove', min: 0.1, max: 3, initial: 0.4),
      ToggleParam('railing', initial: false),
    ],
    shelter => const [
      NumberParam('width', min: 1.5, max: 8, initial: 3),
      NumberParam('depth', min: 1, max: 5, initial: 2.5),
      NumberParam('height', min: 1.8, max: 3.5, initial: 2.3),
      ChoiceParam('roofing', [
        'polycarbonate',
        'metalSheet',
      ], initial: 'polycarbonate'),
      ChoiceParam('rafterSection', [
        '60x120',
        '80x160',
        '100x200',
      ], initial: '80x160'),
      ChoiceParam('postSection', ['100x100', '120x120'], initial: '120x120'),
      ChoiceParam('snowRegion', ['I', 'II', 'III', 'IV', 'V'], initial: 'II'),
    ],
  };
}

/// Parametr šablony; popisky dodává prezentační vrstva podle [key].
sealed class ParamSpec {
  const ParamSpec(this.key);

  final String key;
}

/// Délka v metrech.
class NumberParam extends ParamSpec {
  const NumberParam(
    super.key, {
    required this.min,
    required this.max,
    required this.initial,
  });

  final double min;
  final double max;
  final double initial;
}

class ChoiceParam extends ParamSpec {
  const ChoiceParam(super.key, this.options, {required this.initial});

  final List<String> options;
  final String initial;
}

class ToggleParam extends ParamSpec {
  const ToggleParam(super.key, {required this.initial});

  final bool initial;
}

/// Hodnoty parametrů návrhu. Chybějící nebo neplatná hodnota (třeba ze
/// starší verze nebo poškozená synchronizací) se nahradí výchozí, číslo
/// mimo rozsah se ořízne na mez.
class BuildValues {
  BuildValues(this.template, [Map<String, Object?> raw = const {}])
    : raw = Map.unmodifiable(raw);

  final BuildTemplate template;
  final Map<String, Object?> raw;

  ParamSpec _spec(String key) =>
      template.params.firstWhere((p) => p.key == key);

  double number(String key) {
    final spec = _spec(key) as NumberParam;
    final v = raw[key];
    if (v is! num || !v.isFinite) return spec.initial;
    return v.toDouble().clamp(spec.min, spec.max);
  }

  String choice(String key) {
    final spec = _spec(key) as ChoiceParam;
    final v = raw[key];
    return v is String && spec.options.contains(v) ? v : spec.initial;
  }

  bool toggle(String key) {
    final spec = _spec(key) as ToggleParam;
    final v = raw[key];
    return v is bool ? v : spec.initial;
  }

  /// Hodnota parametru ve tvaru pro uložení (vždy platná).
  Object valueOf(ParamSpec spec) => switch (spec) {
    NumberParam() => number(spec.key),
    ChoiceParam() => choice(spec.key),
    ToggleParam() => toggle(spec.key),
  };

  BuildValues copyWith(String key, Object value) =>
      BuildValues(template, {...raw, key: value});

  /// Všechny parametry šablony s platnými hodnotami.
  Map<String, Object> toJson() => {
    for (final spec in template.params) spec.key: valueOf(spec),
  };
}
