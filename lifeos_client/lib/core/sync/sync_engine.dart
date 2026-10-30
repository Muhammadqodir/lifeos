import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show AppLifecycleListener;

import '../network/api_exception.dart';
import 'ids.dart';
import 'local_store.dart';
import 'sync_api.dart';

enum SyncPhase {
  /// Everything is pushed (or nothing is signed in).
  idle,
  syncing,

  /// The server could not be reached; changes stay queued.
  offline,

  /// The server answered with an error; retried later.
  error,
}

@immutable
class SyncStatus {
  const SyncStatus({
    this.phase = SyncPhase.idle,
    this.pending = 0,
    this.lastSyncedAt,
    this.message,
  });

  final SyncPhase phase;

  /// Local changes not yet accepted by the server.
  final int pending;
  final DateTime? lastSyncedAt;
  final String? message;

  SyncStatus copyWith({
    SyncPhase? phase,
    int? pending,
    DateTime? lastSyncedAt,
    String? message,
  }) => SyncStatus(
    phase: phase ?? this.phase,
    pending: pending ?? this.pending,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    message: message,
  );
}

/// A change the server refused. The local copy has already been put back to
/// the server's version; this is only for telling the user.
@immutable
class SyncIssue {
  const SyncIssue({
    required this.entity,
    required this.id,
    required this.code,
    required this.message,
  });

  final String entity;
  final String id;
  final String code;
  final String message;
}

/// Local-first sync (docs/local-first.md).
///
/// Repositories call [create], [update] and [delete]: the change is written
/// to the [LocalStore] and queued in its outbox in one transaction, so the
/// UI updates at once and nothing waits for the network. The engine then
/// pushes the outbox and pulls what changed elsewhere, shortly after a
/// change, every [interval], when the app comes back to the foreground and
/// on [syncNow].
class SyncEngine {
  SyncEngine(
    this._store,
    this._api, {
    this.debounce = const Duration(milliseconds: 400),
    this.interval = const Duration(minutes: 1),
    this.followAppLifecycle = true,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final LocalStore _store;
  final SyncApi _api;
  final Duration debounce;
  final Duration interval;

  /// Sync when the app returns to the foreground (off in unit tests, which
  /// have no Flutter binding).
  final bool followAppLifecycle;
  final DateTime Function() _clock;

  static const _cursorKey = 'cursor';
  static const _ownerKey = 'owner';
  static const _entitiesKey = 'entities';
  static const _batchSize = 100;

  final ValueNotifier<SyncStatus> status = ValueNotifier(const SyncStatus());
  final _issues = StreamController<SyncIssue>.broadcast();

  /// Changes the server refused.
  Stream<SyncIssue> get issues => _issues.stream;

  bool _running = false;
  Timer? _debounceTimer;
  Timer? _intervalTimer;
  Timer? _retryTimer;
  int _failures = 0;
  AppLifecycleListener? _lifecycle;
  StreamSubscription<Set<String>>? _outboxWatch;

  /// Outbox keys being pushed right now; they must not be merged into.
  final Set<int> _inflight = {};
  Future<void>? _cycle;
  bool _again = false;
  Completer<void> _ready = Completer<void>();

  /// Whether this device has data from the server (or tried to get it).
  bool get isReady => _ready.isCompleted;

  /// Completes once the device holds the account's data: at once when it
  /// synced before, otherwise after the first sync attempt (even a failed
  /// one, so an offline first start shows empty screens instead of hanging).
  /// Lists wait for this so a fresh sign-in shows "loading", not "empty".
  Future<void> whenReady() => _ready.future;

  String _now() => _clock().toUtc().toIso8601String();

  // ---------------------------------------------------------------------------
  // Lifecycle

  /// Starts syncing for [userId]. Local data of a different account is
  /// discarded first.
  Future<void> start(String userId) async {
    final owner = await _store.meta(_ownerKey);
    if (owner != null && owner != userId) await _store.clear();
    await _store.write((txn) async {
      await txn.setMeta(_ownerKey, userId);
      // A cursor only covers the entities synced when it was taken; when an
      // app update adds entities, start over with a full pull.
      final entities = SyncEntities.all.join(',');
      if (await txn.meta(_entitiesKey) != entities) {
        await txn.setMeta(_cursorKey, null);
        await txn.setMeta(_entitiesKey, entities);
      }
    });
    if (await _store.meta(_cursorKey) != null && !_ready.isCompleted) {
      _ready.complete();
    }

    if (_running) return;
    _running = true;
    _outboxWatch = _store.changes
        .where((t) => t.contains(SyncEntities.outbox))
        .listen((_) => _refreshPending());
    _intervalTimer = Timer.periodic(interval, (_) => _schedule(Duration.zero));
    if (followAppLifecycle) {
      _lifecycle = AppLifecycleListener(
        onResume: () => _schedule(Duration.zero),
      );
    }
    await _refreshPending();
    _schedule(Duration.zero);
  }

  /// Stops syncing and keeps local data (session expired: the same user
  /// may sign in again and still has unsent changes).
  Future<void> stop() async {
    _running = false;
    _debounceTimer?.cancel();
    _intervalTimer?.cancel();
    _retryTimer?.cancel();
    _lifecycle?.dispose();
    _lifecycle = null;
    await _outboxWatch?.cancel();
    _outboxWatch = null;
    await _cycle;
    status.value = const SyncStatus();
  }

  /// Signing out: tries to push what is left, then deletes local data.
  Future<void> signOut() async {
    if (_running) {
      try {
        await syncNow().timeout(const Duration(seconds: 5));
      } catch (_) {
        // Offline: the changes are lost with the account's local data.
      }
    }
    await stop();
    await _store.clear();
    if (_ready.isCompleted) _ready = Completer<void>();
  }

  /// Push and pull now; completes when that round is done.
  Future<void> syncNow() {
    _failures = 0;
    _retryTimer?.cancel();
    return _run();
  }

  Future<void> dispose() async {
    await stop();
    await _issues.close();
    status.dispose();
  }

  // ---------------------------------------------------------------------------
  // Local changes

  /// Creates a record locally and queues it. Returns the stored record.
  Future<Json> create(String entity, Json data, {String? id}) async {
    final recordId = id ?? newId();
    final now = _now();
    final existing = await _store.get(entity, recordId);
    if (existing != null) {
      return await update(entity, recordId, data) ?? existing;
    }
    final record = {
      ...data,
      'id': recordId,
      'created_at': now,
      'updated_at': now,
    };
    await _store.write((txn) async {
      await txn.put(entity, record);
      await txn.addOp(
        opId: newId(),
        entity: entity,
        id: recordId,
        type: 'create',
        data: data,
      );
    });
    _schedule(debounce);
    return record;
  }

  /// Changes some fields locally and queues them. Returns the updated
  /// record, or null if it doesn't exist.
  Future<Json?> update(String entity, String id, Json changes) async {
    final updated = await _store.write((txn) async {
      final current = await txn.get(entity, id);
      if (current == null) return null;
      final record = {...current, ...changes, 'updated_at': _now()};
      await txn.put(entity, record);

      // Fold into the last queued change of this record if it hasn't been
      // sent yet, so offline edits go out as one operation.
      final pending = await txn.pendingFor(entity, id);
      final last = pending.isEmpty ? null : pending.last;
      if (last != null &&
          last.type != 'delete' &&
          !_inflight.contains(last.key)) {
        await txn.replaceOpData(last.key, {...last.data, ...changes});
      } else {
        await txn.addOp(
          opId: newId(),
          entity: entity,
          id: id,
          type: 'update',
          data: changes,
        );
      }
      return record;
    });
    if (updated != null) _schedule(debounce);
    return updated;
  }

  /// Deletes a record (and its children, see [SyncEntities.children])
  /// locally and queues the deletion.
  Future<void> delete(String entity, String id) async {
    await _store.write((txn) async {
      final pending = await txn.pendingFor(entity, id);
      final unsent = pending.where((op) => !_inflight.contains(op.key));
      final createdLocally =
          unsent.any((op) => op.type == 'create') &&
          pending.every((op) => !_inflight.contains(op.key));
      for (final op in unsent) {
        await txn.removeOp(op.key);
      }
      // The server never saw it: nothing to tell it.
      if (!createdLocally) {
        await txn.addOp(opId: newId(), entity: entity, id: id, type: 'delete');
      }
      await _removeLocally(txn, entity, id, dropChildOps: true);
    });
    _schedule(debounce);
  }

  /// Removes a record and its children from the device. The server deletes
  /// children itself, so only their unsent changes are dropped.
  Future<void> _removeLocally(
    LocalTxn txn,
    String entity,
    String id, {
    required bool dropChildOps,
  }) async {
    await txn.remove(entity, id);
    for (final MapEntry(key: child, value: foreignKey)
        in (SyncEntities.children[entity] ?? const <String, String>{})
            .entries) {
      for (final childId in await txn.idsWhere(child, foreignKey, id)) {
        if (dropChildOps) {
          for (final op in await txn.pendingFor(child, childId)) {
            if (!_inflight.contains(op.key)) await txn.removeOp(op.key);
          }
        }
        await _removeLocally(txn, child, childId, dropChildOps: dropChildOps);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Sync rounds

  void _schedule(Duration delay) {
    if (!_running) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () => unawaited(_run()));
  }

  Future<void> _run() {
    if (!_running) return Future.value();
    if (_cycle != null) {
      _again = true;
      return _cycle!;
    }
    final cycle = _cycleLoop();
    _cycle = cycle;
    return cycle.whenComplete(() => _cycle = null);
  }

  Future<void> _cycleLoop() async {
    do {
      _again = false;
      status.value = status.value.copyWith(phase: SyncPhase.syncing);
      try {
        await _pushAll();
        await _pull();
        _failures = 0;
        status.value = status.value.copyWith(
          phase: SyncPhase.idle,
          lastSyncedAt: _clock(),
        );
      } on ApiException catch (e) {
        _failures++;
        status.value = status.value.copyWith(
          phase: e.isNetwork ? SyncPhase.offline : SyncPhase.error,
          message: e.message,
        );
        if (e.statusCode != 401) _retryLater();
        return;
      } catch (e, stack) {
        _failures++;
        debugPrint('Sync failed: $e\n$stack');
        status.value = status.value.copyWith(
          phase: SyncPhase.error,
          message: '$e',
        );
        _retryLater();
        return;
      } finally {
        _inflight.clear();
        await _refreshPending();
        if (!_ready.isCompleted) _ready.complete();
      }
    } while (_again && _running);
  }

  void _retryLater() {
    if (!_running) return;
    // 5, 10, 20, then every 30 seconds.
    final seconds = math.min(30, 5 * math.pow(2, _failures - 1)).toInt();
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: seconds), () => unawaited(_run()));
  }

  Future<void> _refreshPending() async {
    final pending = await _store.pendingCount();
    if (pending != status.value.pending) {
      status.value = status.value.copyWith(
        pending: pending,
        message: status.value.message,
      );
    }
  }

  Future<void> _pushAll() async {
    while (_running) {
      final batch = await _store.outbox(limit: _batchSize);
      if (batch.isEmpty) return;
      _inflight.addAll(batch.map((op) => op.key));
      final results = await _api.push(batch);
      final byOpId = {for (final r in results) r.opId: r};

      final issues = <SyncIssue>[];
      await _store.write((txn) async {
        for (final op in batch) {
          final result = byOpId[op.opId];
          if (result == null) continue; // Not answered: send again.
          await txn.removeOp(op.key);
          _inflight.remove(op.key);
          if (!result.applied) {
            issues.add(
              SyncIssue(
                entity: op.entity,
                id: op.id,
                code: result.code ?? 'rejected',
                message: result.message ?? 'The server refused a change.',
              ),
            );
          }
          await _acceptServerCopy(txn, op.entity, op.id, result.record);
        }
      });
      issues.forEach(_issues.add);
      if (batch.length < _batchSize) return;
    }
  }

  /// Makes the local copy of [id] the server's [record], then re-applies
  /// local changes still queued for it.
  Future<void> _acceptServerCopy(
    LocalTxn txn,
    String entity,
    String id,
    Json? record,
  ) async {
    final pending = await txn.pendingFor(entity, id);
    if (pending.any((op) => op.type == 'delete')) return;

    if (record == null) {
      // A delete went through, or the record is gone on the server.
      if (pending.isEmpty) {
        await _removeLocally(txn, entity, id, dropChildOps: true);
      }
      return;
    }

    final serverId = record['id'] as String;
    if (serverId != id) {
      // Merged into an existing record (e.g. the same habit day).
      await txn.remove(entity, id);
    }
    final serverPending = serverId == id
        ? pending
        : await txn.pendingFor(entity, serverId);
    await txn.put(entity, {
      ...record,
      for (final op in serverPending) ...op.data,
    });
  }

  Future<void> _pull() async {
    final cursor = await _store.meta(_cursorKey) as String?;
    final result = await _api.pull(cursor);

    await _store.write((txn) async {
      for (final entity in SyncEntities.all) {
        final incoming = result.changes[entity] ?? const [];
        for (final record in incoming) {
          await _acceptServerCopy(txn, entity, record['id'] as String, record);
        }

        for (final id in result.deleted[entity] ?? const <String>[]) {
          for (final op in await txn.pendingFor(entity, id)) {
            // Edits to something deleted elsewhere can only fail.
            if (!_inflight.contains(op.key)) await txn.removeOp(op.key);
          }
          await _removeLocally(txn, entity, id, dropChildOps: true);
        }

        if (result.full) {
          // Drop what the server no longer has, except unsent creations.
          final serverIds = {for (final r in incoming) r['id'] as String};
          for (final local in await txn.all(entity)) {
            final id = local['id'] as String;
            if (serverIds.contains(id)) continue;
            if ((await txn.pendingFor(entity, id)).isNotEmpty) continue;
            await txn.remove(entity, id);
          }
        }
      }
      await txn.setMeta(_cursorKey, result.cursor);
    });
  }
}
