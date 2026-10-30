import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;

import '../network/api_exception.dart';
import 'local_store.dart';
import 'sync_engine.dart';

/// Uploads a file for a record once it exists on the server.
typedef UploadHandler = Future<void> Function(int serverId, String path);

/// Files that belong to synced records (workout photos, exercise images,
/// project icons). Files don't go through sync: they are uploaded with
/// their own endpoint once the record has a `server_id`.
///
/// The queue is kept in the local store, so a photo taken offline is
/// uploaded later, after a sync succeeds. A pull then brings the new path.
class PendingUploads {
  PendingUploads(this._store, this._sync) {
    _sync.status.addListener(_onStatus);
  }

  final LocalStore _store;
  final SyncEngine _sync;
  final Map<String, UploadHandler> _handlers = {};
  bool _running = false;

  static const _key = 'pending_uploads';

  void register(String kind, UploadHandler handler) =>
      _handlers[kind] = handler;

  /// Queues [path] for [entity] [id] and tries right away.
  Future<void> add({
    required String kind,
    required String entity,
    required String id,
    required String path,
  }) async {
    final queue = await _queue();
    queue.removeWhere((u) => u['kind'] == kind && u['id'] == id);
    queue.add({'kind': kind, 'entity': entity, 'id': id, 'path': path});
    await _store.setMeta(_key, queue);
    unawaited(_sync.syncNow().whenComplete(run));
  }

  Future<List<Map<String, Object?>>> _queue() async => [
    for (final u in (await _store.meta(_key) as List?) ?? const [])
      Map<String, Object?>.from(u as Map),
  ];

  void _onStatus() {
    if (_sync.status.value.phase == SyncPhase.idle) unawaited(run());
  }

  /// Uploads what can be uploaded now.
  Future<void> run() async {
    if (_running) return;
    _running = true;
    var uploaded = false;
    try {
      final queue = await _queue();
      final remaining = <Map<String, Object?>>[];
      for (final upload in queue) {
        final handler = _handlers[upload['kind']];
        final record = await _store.get(
          upload['entity'] as String,
          upload['id'] as String,
        );
        if (handler == null || record == null) continue; // Gone: drop it.
        final serverId = record['server_id'];
        if (serverId is! int) {
          remaining.add(upload); // Not on the server yet.
          continue;
        }
        try {
          await handler(serverId, upload['path'] as String);
          uploaded = true;
        } on ApiException catch (e) {
          if (e.isNetwork) {
            remaining.add(upload);
          } else {
            debugPrint('Upload ${upload['kind']} refused: ${e.message}');
          }
        } catch (e) {
          // The file is gone or unreadable; nothing to retry.
          debugPrint('Upload ${upload['kind']} failed: $e');
        }
      }
      await _store.setMeta(_key, remaining.isEmpty ? null : remaining);
    } finally {
      _running = false;
    }
    if (uploaded) unawaited(_sync.syncNow());
  }

  void dispose() => _sync.status.removeListener(_onStatus);
}
