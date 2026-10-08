import 'package:equatable/equatable.dart';

import 'recurrence.dart';

/// Stav úkolu (FR-U1).
enum TaskStatus {
  open,
  done,
  skipped;

  static TaskStatus fromKey(String? key) =>
      values.firstWhere((s) => s.name == key, orElse: () => open);
}

/// Úkol na zahradě s termínem a volitelnou připomínkou.
class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String? zoneId;

  /// Den termínu (místní půlnoc).
  final DateTime due;

  /// Čas připomínky v den termínu v minutách od půlnoci; null = bez
  /// samostatné notifikace, úkol se objeví jen v ranním přehledu.
  final int? remindAt;

  /// Opakování jako iCalendar RRULE (FR-U2), null = jednorázový úkol.
  final String? rrule;

  /// Odložení (FR-U3): úkol se ukazuje a připomíná až od tohoto dne.
  final DateTime? snoozedUntil;

  final TaskStatus status;
  final String? notes;
  final DateTime? completedAt;

  /// Záznam v deníku vzniklý při dokončení (FR-U4).
  final String? completedActivityId;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.due,
    this.zoneId,
    this.remindAt,
    this.rrule,
    this.snoozedUntil,
    this.status = TaskStatus.open,
    this.notes,
    this.completedAt,
    this.completedActivityId,
    this.createdAt,
    this.updatedAt,
  });

  /// Den, kdy je úkol na řadě: termín, nebo konec odložení.
  DateTime get effectiveDate => snoozedUntil ?? due;

  bool get isOpen => status == TaskStatus.open;

  Recurrence? get recurrence => Recurrence.parse(rrule);

  /// Okamžik připomínky v den [effectiveDate], nebo null.
  DateTime? get reminderTime {
    final minutes = remindAt;
    if (minutes == null) return null;
    final d = effectiveDate;
    return DateTime(d.year, d.month, d.day, minutes ~/ 60, minutes % 60);
  }

  TaskEntity copyWith({
    String? title,
    String? Function()? zoneId,
    DateTime? due,
    int? Function()? remindAt,
    String? Function()? rrule,
    DateTime? Function()? snoozedUntil,
    TaskStatus? status,
    String? Function()? notes,
    DateTime? Function()? completedAt,
    String? Function()? completedActivityId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskEntity(
      id: id,
      title: title ?? this.title,
      zoneId: zoneId == null ? this.zoneId : zoneId(),
      due: due ?? this.due,
      remindAt: remindAt == null ? this.remindAt : remindAt(),
      rrule: rrule == null ? this.rrule : rrule(),
      snoozedUntil: snoozedUntil == null ? this.snoozedUntil : snoozedUntil(),
      status: status ?? this.status,
      notes: notes == null ? this.notes : notes(),
      completedAt: completedAt == null ? this.completedAt : completedAt(),
      completedActivityId: completedActivityId == null
          ? this.completedActivityId
          : completedActivityId(),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    zoneId,
    due,
    remindAt,
    rrule,
    snoozedUntil,
    status,
    notes,
    completedAt,
    completedActivityId,
    createdAt,
    updatedAt,
  ];
}
