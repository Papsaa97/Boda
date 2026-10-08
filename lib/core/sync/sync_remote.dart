/// Server pro synchronizaci (Supabase; v testech paměťová náhrada).
abstract interface class SyncRemote {
  /// Zahrady, kde je přihlášený uživatel členem (bez smazaných).
  Future<List<String>> gardenIds();

  /// Odešle změny v jedné transakci (RPC `sync_push`): mapa tabulka →
  /// řádky a `deleted` → seznam natvrdo smazaných řádků.
  Future<void> push(Map<String, Object?> changes);

  /// Řádky [table] změněné na serveru po [since] (podle
  /// `server_updated_at`), vzestupně, nejvýš [limit]. S [gardenColumn]
  /// jen řádky zahrady [gardenId].
  Future<List<Map<String, Object?>>> pull(
    String table, {
    required DateTime? since,
    String? gardenColumn,
    String? gardenId,
    int limit = 500,
  });

  /// Nahraje fotku do úložiště (bucket `photos`, cesta `<zahrada>/<id>.jpg`).
  Future<void> uploadPhoto(String path, List<int> bytes);

  /// Stáhne fotku; null, když na serveru není.
  Future<List<int>?> downloadPhoto(String path);
}

/// Synchronizace se nepovedla (síť, server, oprávnění).
class SyncException implements Exception {
  const SyncException(this.message, {this.offline = false});

  final String message;

  /// Bez připojení; zkusí se příště.
  final bool offline;

  @override
  String toString() => 'SyncException($message)';
}
