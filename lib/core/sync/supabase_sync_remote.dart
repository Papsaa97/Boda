import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../backend/network_errors.dart';
import 'sync_remote.dart';

/// Synchronizace přes Supabase: RPC `sync_push`, čtení tabulek pod RLS
/// a soukromý bucket `photos`.
class SupabaseSyncRemote implements SyncRemote {
  SupabaseSyncRemote(this._client);

  final SupabaseClient _client;

  Future<T> _guard<T>(Future<T> Function() op) async {
    try {
      return await op();
    } on PostgrestException catch (e) {
      throw SyncException(e.message);
    } on StorageException catch (e) {
      throw SyncException(e.message);
    } catch (e) {
      if (isNetworkError(e)) throw SyncException('$e', offline: true);
      rethrow;
    }
  }

  @override
  Future<List<String>> gardenIds() => _guard(() async {
    final rows = await _client
        .from('gardens')
        .select('id')
        .isFilter('deleted_at', null)
        .order('created_at');
    return [for (final r in rows) r['id'] as String];
  });

  @override
  Future<void> push(Map<String, Object?> changes) => _guard(
    () => _client.rpc<void>('sync_push', params: {'p_changes': changes}),
  );

  @override
  Future<List<Map<String, Object?>>> pull(
    String table, {
    required DateTime? since,
    String? gardenColumn,
    String? gardenId,
    int limit = 500,
  }) => _guard(() async {
    var query = _client.from(table).select();
    if (gardenColumn != null && gardenId != null) {
      query = query.eq(gardenColumn, gardenId);
    }
    if (since != null) {
      query = query.gt('server_updated_at', since.toUtc().toIso8601String());
    }
    final rows = await query
        .order('server_updated_at', ascending: true)
        .limit(limit);
    return [for (final r in rows) Map<String, Object?>.from(r)];
  });

  @override
  Future<void> uploadPhoto(String path, List<int> bytes) => _guard(
    () => _client.storage
        .from('photos')
        .uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        ),
  );

  @override
  Future<List<int>?> downloadPhoto(String path) async {
    try {
      return await _client.storage.from('photos').download(path);
    } on StorageException catch (e) {
      if (e.statusCode == '404' || e.statusCode == '400') return null;
      throw SyncException(e.message);
    } catch (e) {
      if (isNetworkError(e)) throw SyncException('$e', offline: true);
      rethrow;
    }
  }
}
