import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

/// A record as stored and sent over the wire: the sync API's JSON, with the
/// uuid as `id`.
typedef Json = Map<String, Object?>;

/// The entities kept on the device, parents before children (the same
/// order as the backend's SyncRegistry).
abstract final class SyncEntities {
  static const projects = 'projects';
  static const todos = 'todos';
  static const habits = 'habits';
  static const habitEntries = 'habit_entries';
  static const wallets = 'wallets';
  static const transactionCategories = 'transaction_categories';
  static const transactions = 'transactions';
  static const sleepEntries = 'sleep_entries';
  static const wellbeingEntries = 'wellbeing_entries';
  static const exercises = 'exercises';
  static const workoutSessions = 'workout_sessions';

  static const all = [
    projects,
    todos,
    habits,
    habitEntries,
    wallets,
    transactionCategories,
    transactions,
    sleepEntries,
    wellbeingEntries,
    exercises,
    workoutSessions,
  ];

  /// Children that go when their parent is deleted: entity → foreign key.
  static const children = {
    projects: {todos: 'project_id'},
    habits: {habitEntries: 'habit_id'},
  };

  /// Pseudo-entity reported by [LocalStore.changes] when the outbox changes.
  static const outbox = '_outbox';
}

/// A local change waiting to be pushed.
class OutboxOp {
  const OutboxOp({
    required this.key,
    required this.opId,
    required this.entity,
    required this.id,
    required this.type,
    required this.data,
  });

  /// Position in the queue.
  final int key;
  final String opId;
  final String entity;
  final String id;

  /// `create`, `update` or `delete`.
  final String type;
  final Json data;

  factory OutboxOp._fromRecord(int key, Map<String, Object?> value) => OutboxOp(
    key: key,
    opId: value['op_id'] as String,
    entity: value['entity'] as String,
    id: value['id'] as String,
    type: value['type'] as String,
    data: Json.from((value['data'] as Map?) ?? const {}),
  );

  Json toJson() => {
    'op_id': opId,
    'entity': entity,
    'id': id,
    'type': type,
    'data': data,
  };
}

/// The on-device database: one store per synced entity, the outbox of
/// changes not yet pushed, and sync metadata.
///
/// Every write goes through [write]; when it commits, [changes] reports the
/// entities it touched so [watch] streams re-read. Screens therefore update
/// the moment anything changes, whichever screen or sync made the change.
class LocalStore {
  LocalStore._(this._db);

  final Database _db;

  final _records = {
    for (final entity in SyncEntities.all)
      entity: stringMapStoreFactory.store(entity),
  };
  final _outbox = intMapStoreFactory.store('outbox');
  final _meta = StoreRef<String, Object?>('meta');

  final _changes = StreamController<Set<String>>.broadcast(sync: true);

  static Future<LocalStore> open({
    String name = 'lifeos.db',
    DatabaseFactory? factory,
  }) async {
    if (factory != null) {
      return LocalStore._(await factory.openDatabase(name));
    }
    if (kIsWeb) {
      return LocalStore._(await databaseFactoryWeb.openDatabase(name));
    }
    final dir = await getApplicationSupportDirectory();
    await dir.create(recursive: true);
    return LocalStore._(
      await databaseFactoryIo.openDatabase(p.join(dir.path, name)),
    );
  }

  /// Entities touched by each committed write.
  Stream<Set<String>> get changes => _changes.stream;

  /// Emits [read]'s result now and again after every write that touches
  /// one of [entities]. Reads run one at a time, so results arrive in order.
  Stream<T> watch<T>(Set<String> entities, Future<T> Function() read) {
    late final StreamController<T> controller;
    StreamSubscription<Set<String>>? subscription;
    var queue = Future<void>.value();

    void refresh() {
      queue = queue
          .then((_) async {
            final value = await read();
            if (!controller.isClosed) controller.add(value);
          })
          .catchError((Object error, StackTrace stack) {
            if (!controller.isClosed) controller.addError(error, stack);
          });
    }

    controller = StreamController<T>(
      onListen: () {
        refresh();
        subscription = changes
            .where((touched) => touched.any(entities.contains))
            .listen((_) => refresh());
      },
      onCancel: () => subscription?.cancel(),
    );
    return controller.stream;
  }

  Future<List<Json>> all(String entity) async {
    final snapshots = await _records[entity]!.find(_db);
    return [for (final s in snapshots) Json.from(s.value)];
  }

  Future<Json?> get(String entity, String id) async {
    final value = await _records[entity]!.record(id).get(_db);
    return value == null ? null : Json.from(value);
  }

  Future<int> pendingCount() => _outbox.count(_db);

  Future<List<OutboxOp>> outbox({int? limit}) async {
    final snapshots = await _outbox.find(
      _db,
      finder: Finder(sortOrders: [SortOrder(Field.key)], limit: limit),
    );
    return [for (final s in snapshots) OutboxOp._fromRecord(s.key, s.value)];
  }

  Future<Object?> meta(String key) => _meta.record(key).get(_db);

  /// Caches a value that isn't synced (currencies, settings, FX rates).
  Future<void> setMeta(String key, Object? value) =>
      write((txn) => txn.setMeta(key, value));

  /// Runs [body] in one transaction and then notifies watchers.
  Future<R> write<R>(Future<R> Function(LocalTxn txn) body) async {
    final touched = <String>{};
    final result = await _db.transaction(
      (transaction) => body(LocalTxn._(this, transaction, touched)),
    );
    if (touched.isNotEmpty) _changes.add(touched);
    return result;
  }

  /// Deletes everything (sign-out, or another account signing in).
  Future<void> clear() => write((txn) async {
    for (final store in _records.values) {
      await store.delete(txn._txn);
    }
    await _outbox.delete(txn._txn);
    await _meta.delete(txn._txn);
    txn._touched.addAll([...SyncEntities.all, SyncEntities.outbox]);
  });

  Future<void> close() async {
    await _changes.close();
    await _db.close();
  }
}

/// Reads and writes inside one [LocalStore.write] transaction.
class LocalTxn {
  LocalTxn._(this._store, this._txn, this._touched);

  final LocalStore _store;
  final Transaction _txn;
  final Set<String> _touched;

  StoreRef<String, Map<String, Object?>> _records(String entity) =>
      _store._records[entity]!;

  Future<Json?> get(String entity, String id) async {
    final value = await _records(entity).record(id).get(_txn);
    return value == null ? null : Json.from(value);
  }

  Future<List<Json>> all(String entity) async {
    final snapshots = await _records(entity).find(_txn);
    return [for (final s in snapshots) Json.from(s.value)];
  }

  Future<List<String>> idsWhere(
    String entity,
    String field,
    Object? value,
  ) async {
    final keys = await _records(
      entity,
    ).findKeys(_txn, finder: Finder(filter: Filter.equals(field, value)));
    return keys;
  }

  Future<void> put(String entity, Json record) async {
    await _records(entity).record(record['id'] as String).put(_txn, record);
    _touched.add(entity);
  }

  Future<void> remove(String entity, String id) async {
    await _records(entity).record(id).delete(_txn);
    _touched.add(entity);
  }

  Future<List<OutboxOp>> pendingFor(String entity, String id) async {
    final snapshots = await _store._outbox.find(
      _txn,
      finder: Finder(
        filter: Filter.and([
          Filter.equals('entity', entity),
          Filter.equals('id', id),
        ]),
        sortOrders: [SortOrder(Field.key)],
      ),
    );
    return [for (final s in snapshots) OutboxOp._fromRecord(s.key, s.value)];
  }

  Future<void> addOp({
    required String opId,
    required String entity,
    required String id,
    required String type,
    Json data = const {},
  }) async {
    await _store._outbox.add(_txn, {
      'op_id': opId,
      'entity': entity,
      'id': id,
      'type': type,
      'data': data,
    });
    _touched.add(SyncEntities.outbox);
  }

  Future<void> replaceOpData(int key, Json data) async {
    await _store._outbox.record(key).update(_txn, {'data': data});
    _touched.add(SyncEntities.outbox);
  }

  Future<void> removeOp(int key) async {
    await _store._outbox.record(key).delete(_txn);
    _touched.add(SyncEntities.outbox);
  }

  Future<Object?> meta(String key) => _store._meta.record(key).get(_txn);

  Future<void> setMeta(String key, Object? value) async {
    if (value == null) {
      await _store._meta.record(key).delete(_txn);
    } else {
      await _store._meta.record(key).put(_txn, value);
    }
  }
}
