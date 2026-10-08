import 'package:equatable/equatable.dart';

import 'build_params.dart';

/// Uložený návrh stavby: šablona, parametry a ceny zadané uživatelem.
class BuildDesign extends Equatable {
  const BuildDesign({
    required this.id,
    required this.name,
    required this.values,
    this.zoneId,
    this.prices = const {},
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final BuildValues values;

  /// Zóna, kde má stavba stát (nepovinné).
  final String? zoneId;

  /// Kč za jednotku podle `BuildMaterial.name`; chybějící = výchozí cena.
  final Map<String, double> prices;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BuildTemplate get template => values.template;

  BuildDesign copyWith({
    String? name,
    BuildValues? values,
    String? Function()? zoneId,
    Map<String, double>? prices,
  }) => BuildDesign(
    id: id,
    name: name ?? this.name,
    values: values ?? this.values,
    zoneId: zoneId != null ? zoneId() : this.zoneId,
    prices: prices ?? this.prices,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  /// Ceny z JSONu; jen nezáporná konečná čísla.
  static Map<String, double> pricesFromJson(Object? json) {
    if (json is! Map) return const {};
    return {
      for (final e in json.entries)
        if (e.key is String && e.value is num && (e.value as num).isFinite)
          if ((e.value as num) >= 0)
            e.key as String: (e.value as num).toDouble(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    template,
    values.toJson(),
    zoneId,
    prices,
    createdAt,
    updatedAt,
  ];
}

abstract interface class BuildRepository {
  Future<List<BuildDesign>> getAll();
  Future<void> save(BuildDesign design);
  Future<void> delete(String id);
}
