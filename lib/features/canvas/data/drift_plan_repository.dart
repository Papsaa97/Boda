import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/geometry.dart';
import '../domain/plan_document.dart';
import '../domain/plan_repository.dart';

/// Klíč nastavení s podkladem plánu (jen v tomto telefonu).
const planBackgroundSettingKey = 'canvas_background';

/// Obrys v řádku zahrady (`bounds`), podklad v nastavení telefonu.
class DriftPlanRepository implements PlanRepository {
  DriftPlanRepository(this._db, this._gardenId, this._clock);

  final AppDatabase _db;
  final String _gardenId;
  final DateTime Function() _clock;

  @override
  Future<List<Pt>> loadOutline() async {
    final row = await (_db.select(
      _db.gardens,
    )..where((g) => g.id.equals(_gardenId))).getSingleOrNull();
    final bounds = row?.bounds;
    if (bounds == null) return const [];
    try {
      return outlineFromBounds(jsonDecode(bounds));
    } on FormatException {
      return const [];
    }
  }

  @override
  Future<void> saveOutline(List<Pt> outline) async {
    await (_db.update(_db.gardens)..where((g) => g.id.equals(_gardenId))).write(
      GardensCompanion(
        bounds: Value(
          outline.isEmpty ? null : jsonEncode(outlineToBounds(outline)),
        ),
        updatedAt: Value(_clock().toUtc()),
      ),
    );
  }

  @override
  Future<PlanBackground?> loadBackground() async {
    final json = await _db.readSetting(planBackgroundSettingKey);
    if (json == null) return null;
    try {
      return PlanBackground.fromJson(jsonDecode(json));
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> saveBackground(PlanBackground? background) => _db.writeSetting(
    planBackgroundSettingKey,
    background == null ? null : jsonEncode(background.toJson()),
  );
}
