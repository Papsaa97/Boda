import 'package:equatable/equatable.dart';

import '../../activity/domain/activity_entity.dart';

enum IncidentStatus {
  open,
  resolved;

  static IncidentStatus fromKey(String? key) =>
      key == resolved.name ? resolved : open;
}

/// Kdo incident založil: uživatel ručně (FR-V4), nebo diagnostika z fotky.
enum IncidentSource {
  user,
  model;

  static IncidentSource fromKey(String? key) =>
      key == model.name ? model : user;
}

/// Možná příčina z diagnostiky (FR-V2): vždy „možná“, bez čísla jistoty.
class IncidentCandidate extends Equatable {
  const IncidentCandidate({
    required this.label,
    this.reason,
    this.check,
    this.care,
  });

  final String label;

  /// Proč to model tipuje (co na fotce viděl).
  final String? reason;

  /// Čím tip ověřit.
  final String? check;

  /// Šetrný postup bez chemie (FR-B3).
  final String? care;

  Map<String, Object?> toJson() => {
    'label': label,
    'reason': ?reason,
    'check': ?check,
    'care': ?care,
  };

  static IncidentCandidate? fromJson(Object? json) {
    if (json is! Map) return null;
    final label = json['label'];
    if (label is! String || label.trim().isEmpty) return null;
    String? text(Object? v) => v is String && v.trim().isNotEmpty ? v : null;
    return IncidentCandidate(
      label: label,
      reason: text(json['reason']),
      check: text(json['check']),
      care: text(json['care']),
    );
  }

  @override
  List<Object?> get props => [label, reason, check, care];
}

/// Karta incidentu (FR-V3): problém v zóně, fotky, plán řešení
/// a kontroly D+3 a D+7 (úkoly s `incidentId`).
class Incident extends Equatable {
  const Incident({
    required this.id,
    required this.zoneId,
    required this.label,
    this.source = IncidentSource.user,
    this.candidates = const [],
    this.planBio,
    this.planChem,
    this.status = IncidentStatus.open,
    this.photos = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String zoneId;
  final String label;
  final IncidentSource source;
  final List<IncidentCandidate> candidates;

  /// Biologický a mechanický postup (FR-B3: eko na prvním místě).
  final String? planBio;

  /// Chemický postup; dávka a ochranná lhůta jen z etikety (FR-B4).
  final String? planChem;
  final IncidentStatus status;

  /// Fotky v pořadí pořízení (první = „před“, poslední = „po“).
  final List<PhotoRef> photos;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isOpen => status == IncidentStatus.open;

  Incident copyWith({
    String? zoneId,
    String? label,
    IncidentSource? source,
    List<IncidentCandidate>? candidates,
    String? Function()? planBio,
    String? Function()? planChem,
    IncidentStatus? status,
    List<PhotoRef>? photos,
    DateTime? updatedAt,
  }) => Incident(
    id: id,
    zoneId: zoneId ?? this.zoneId,
    label: label ?? this.label,
    source: source ?? this.source,
    candidates: candidates ?? this.candidates,
    planBio: planBio == null ? this.planBio : planBio(),
    planChem: planChem == null ? this.planChem : planChem(),
    status: status ?? this.status,
    photos: photos ?? this.photos,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    zoneId,
    label,
    source,
    candidates,
    planBio,
    planChem,
    status,
    photos,
    createdAt,
    updatedAt,
  ];
}

/// Dny kontrol po založení incidentu (FR-V3).
const incidentCheckDays = [3, 7];

abstract interface class IncidentRepository {
  Future<List<Incident>> getAll();
  Future<void> save(Incident incident);
  Future<void> delete(String id);
}
