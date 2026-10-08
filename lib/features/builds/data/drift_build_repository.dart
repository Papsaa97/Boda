import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/build_design.dart';
import '../domain/build_params.dart';

/// Návrhy staveb v lokální databázi. Mazání je měkké.
class DriftBuildRepository implements BuildRepository {
  DriftBuildRepository(this._db, this._gardenId, this._clock);

  final AppDatabase _db;
  final String _gardenId;
  final DateTime Function() _clock;

  @override
  Future<List<BuildDesign>> getAll() async {
    final rows =
        await (_db.select(_db.builds)
              ..where((b) => b.deletedAt.isNull())
              ..orderBy([
                (b) => OrderingTerm(
                  expression: b.updatedAt,
                  mode: OrderingMode.desc,
                ),
              ]))
            .get();
    return [for (final r in rows) ?buildFromRow(r)];
  }

  @override
  Future<void> save(BuildDesign design) async {
    final now = _clock().toUtc();
    final existing = await (_db.select(
      _db.builds,
    )..where((b) => b.id.equals(design.id))).getSingleOrNull();
    await _db
        .into(_db.builds)
        .insertOnConflictUpdate(
          BuildsCompanion.insert(
            id: design.id,
            gardenId: _gardenId,
            zoneId: Value(design.zoneId),
            template: design.template.key,
            name: design.name,
            params: jsonEncode(design.values.toJson()),
            prices: Value(
              design.prices.isEmpty ? null : jsonEncode(design.prices),
            ),
            createdAt: existing?.createdAt ?? design.createdAt ?? now,
            updatedAt: now,
            deletedAt: const Value(null),
          ),
        );
  }

  @override
  Future<void> delete(String id) async {
    final now = _clock().toUtc();
    await (_db.update(_db.builds)..where((b) => b.id.equals(id))).write(
      BuildsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }
}

/// Návrh z řádku; neznámá šablona (z novější verze) = null.
BuildDesign? buildFromRow(BuildRow r) {
  final template = BuildTemplate.fromKey(r.template);
  if (template == null) return null;
  return BuildDesign(
    id: r.id,
    name: r.name,
    values: BuildValues(template, _object(r.params)),
    zoneId: r.zoneId,
    prices: BuildDesign.pricesFromJson(_decode(r.prices)),
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
  );
}

Object? _decode(String? text) {
  if (text == null) return null;
  try {
    return jsonDecode(text);
  } on FormatException {
    return null;
  }
}

Map<String, Object?> _object(String text) => switch (_decode(text)) {
  final Map<String, Object?> map => map,
  _ => const {},
};
