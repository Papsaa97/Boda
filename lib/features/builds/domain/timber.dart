import 'dart:math' as math;

/// Průřez řeziva v milimetrech („100x200“ = šířka 100, výška 200).
class TimberSection {
  const TimberSection(this.b, this.h);

  final int b;
  final int h;

  static TimberSection parse(String key) {
    final parts = key.split('x');
    return TimberSection(int.parse(parts[0]), int.parse(parts[1]));
  }

  String get key => '${b}x$h';

  /// Průřezový modul v mm³.
  double get w => b * h * h / 6;

  /// Moment setrvačnosti v mm⁴.
  double get i => b * math.pow(h, 3) / 12;

  /// Vlastní tíha v kN/m (rostlé dřevo 4,2 kN/m³).
  double get selfWeight => _density * b * h / 1e6;
}

/// Kde dřevo je: venku nekryté (mostek, záhon), nebo pod střechou.
enum Exposure { outdoor, covered }

/// Výsledek posouzení prostého nosníku. Využití 1,0 = na mezi.
class BeamCheck {
  const BeamCheck({
    required this.bending,
    required this.shear,
    required this.deflection,
  });

  final double bending;
  final double shear;
  final double deflection;

  double get utilization => math.max(bending, math.max(shear, deflection));
  bool get ok => utilization <= 1;
}

// Orientační hodnoty pro konstrukční řezivo C24 (ČSN EN 338) a zjednodušený
// postup podle ČSN EN 1995-1-1. Záměrně opatrné: kmod pro střednědobé
// zatížení ve třídě provozu 3 i pod střechou, bez příznivých součinitelů.
const _fmk = 24.0; // MPa
const _fvk = 4.0; // MPa
const _e = 11000.0; // MPa
const _density = 4.2; // kN/m³
const _kmod = 0.65;
const _gammaM = 1.3;
const _kcr = 0.67;
const _gammaG = 1.35;
const _gammaQ = 1.5;

/// Prostý nosník o rozpětí [spanM] s rovnoměrným stálým zatížením [gK]
/// (bez vlastní tíhy, ta se přičte) a proměnným [qK] v kN/m. Průhyb se
/// porovnává s L/[deflectionRatio] včetně dotvarování.
BeamCheck checkBeam({
  required TimberSection section,
  required double spanM,
  required double gK,
  required double qK,
  required Exposure exposure,
  int deflectionRatio = 300,
}) {
  final g = gK + section.selfWeight;
  final qd = _gammaG * g + _gammaQ * qK; // kN/m = N/mm
  final l = spanM * 1000; // mm
  final m = qd * l * l / 8; // Nmm
  final v = qd * l / 2; // N
  final fmd = _fmk * _kmod / _gammaM;
  final fvd = _fvk * _kmod / _gammaM;
  final sigma = m / section.w;
  final tau = 1.5 * v / (_kcr * section.b * section.h);
  final kdef = exposure == Exposure.outdoor ? 2.0 : 0.8;
  double sag(double load) => 5 * load * math.pow(l, 4) / (384 * _e * section.i);
  final wFin = sag(g) * (1 + kdef) + sag(qK);
  final wLim = l / deflectionRatio;
  return BeamCheck(
    bending: sigma / fmd,
    shear: tau / fvd,
    deflection: wFin / wLim,
  );
}
