import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos_client/core/network/api_exception.dart';
import 'package:lifeos_client/core/sync/local_store.dart';
import 'package:lifeos_client/core/sync/sync_api.dart';
import 'package:lifeos_client/core/sync/sync_engine.dart';
import 'package:sembast/sembast_memory.dart';

/// A tiny in-memory stand-in for the backend's sync API.
class FakeServer implements SyncApi {
  final Map<String, Map<String, Json>> records = {
    for (final e in SyncEntities.all) e: {},
  };
  final Map<String, List<String>> tombstones = {
    for (final e in SyncEntities.all) e: [],
  };
  final List<List<OutboxOp>> pushes = [];
  bool offline = false;

  /// Accept pushes but don't answer them (the ops stay queued).
  bool silent = false;

  /// Op ids to reject, with the code to reject them with.
  final Map<String, String> reject = {};
  int _serverId = 1;

  @override
  Future<List<PushResult>> push(List<OutboxOp> ops) async {
    if (offline) throw const ApiException('offline', code: 'network');
    pushes.add(ops);
    if (silent) return const [];
    return [
      for (final op in ops)
        if (reject[op.id] case final code?)
          PushResult(
            opId: op.opId,
            applied: false,
            code: code,
            message: 'Rejected: $code',
            record: records[op.entity]![op.id],
          )
        else
          _apply(op),
    ];
  }

  PushResult _apply(OutboxOp op) {
    final table = records[op.entity]!;
    if (op.type == 'delete') {
      table.remove(op.id);
      return PushResult(opId: op.opId, applied: true);
    }
    final record = {
      ...?table[op.id],
      ...op.data,
      'id': op.id,
      'server_id': table[op.id]?['server_id'] ?? _serverId++,
      'updated_at': 'server',
    };
    table[op.id] = record;
    return PushResult(opId: op.opId, applied: true, record: record);
  }

  @override
  Future<PullResult> pull(String? cursor) async {
    if (offline) throw const ApiException('offline', code: 'network');
    return PullResult(
      cursor: 'c${pushes.length}',
      full: cursor == null,
      changes: {
        for (final e in records.entries) e.key: e.value.values.toList(),
      },
      deleted: cursor == null ? const {} : tombstones,
    );
  }
}

void main() {
  late LocalStore store;
  late FakeServer server;
  late SyncEngine engine;

  setUp(() async {
    store = await LocalStore.open(
      name: 'test.db',
      factory: newDatabaseFactoryMemory(),
    );
    server = FakeServer();
    engine = SyncEngine(
      store,
      server,
      debounce: const Duration(days: 1),
      interval: const Duration(days: 1),
      followAppLifecycle: false,
    );
    await engine.start('user-1');
    await engine.syncNow();
  });

  tearDown(() async {
    await engine.dispose();
  });

  Json project(String title) => {'title': title, 'color': '22c55e'};

  test('a change is stored and queued before any network call', () async {
    server.offline = true;

    final created = await engine.create(
      SyncEntities.projects,
      project('Garden'),
    );

    expect(
      (await store.get(
        SyncEntities.projects,
        created['id'] as String,
      ))?['title'],
      'Garden',
    );
    expect(await store.pendingCount(), 1);
  });

  test('edits made before a push go out as one create', () async {
    final created = await engine.create(
      SyncEntities.projects,
      project('Garden'),
    );
    final id = created['id'] as String;
    await engine.update(SyncEntities.projects, id, {'title': 'Garden v2'});
    await engine.update(SyncEntities.projects, id, {
      'description': 'Back yard',
    });

    await engine.syncNow();

    expect(server.pushes.single.map((op) => op.type), ['create']);
    expect(server.records[SyncEntities.projects]![id]!['title'], 'Garden v2');
    expect(
      (await store.get(SyncEntities.projects, id))!['server_id'],
      isNotNull,
    );
    expect(await store.pendingCount(), 0);
    expect(engine.status.value.phase, SyncPhase.idle);
  });

  test('deleting something the server never saw sends nothing', () async {
    final created = await engine.create(
      SyncEntities.projects,
      project('Garden'),
    );

    await engine.delete(SyncEntities.projects, created['id'] as String);
    await engine.syncNow();

    expect(server.pushes, isEmpty);
    expect(await store.all(SyncEntities.projects), isEmpty);
  });

  test('offline changes wait in the outbox and go out later', () async {
    server.offline = true;
    final created = await engine.create(
      SyncEntities.projects,
      project('Garden'),
    );

    await engine.syncNow();
    expect(engine.status.value.phase, SyncPhase.offline);
    expect(engine.status.value.pending, 1);

    server.offline = false;
    await engine.syncNow();
    expect(server.records[SyncEntities.projects]!.keys, [created['id']]);
    expect(engine.status.value.pending, 0);
  });

  test('a pull keeps local edits that are not pushed yet', () async {
    final created = await engine.create(
      SyncEntities.projects,
      project('Garden'),
    );
    final id = created['id'] as String;
    await engine.syncNow();

    await engine.update(SyncEntities.projects, id, {'title': 'Mine'});
    server.records[SyncEntities.projects]![id] = {
      ...server.records[SyncEntities.projects]![id]!,
      'title': 'Theirs',
      'description': 'From the other device',
    };
    server.silent = true;
    await engine.syncNow();

    final local = (await store.get(SyncEntities.projects, id))!;
    expect(local['title'], 'Mine');
    expect(local['description'], 'From the other device');
    expect(await store.pendingCount(), 1);
  });

  test(
    'a refused change is replaced by the server copy and reported',
    () async {
      final created = await engine.create(
        SyncEntities.projects,
        project('Garden'),
      );
      final id = created['id'] as String;
      await engine.syncNow();

      await engine.update(SyncEntities.projects, id, {'title': 'x'});
      server.reject[id] = 'validation_failed';
      final issue = engine.issues.first;
      await engine.syncNow();

      expect((await issue).code, 'validation_failed');
      expect((await store.get(SyncEntities.projects, id))!['title'], 'Garden');
    },
  );

  test('a deletion elsewhere removes the record and its children', () async {
    final p = await engine.create(SyncEntities.projects, project('Garden'));
    final projectId = p['id'] as String;
    await engine.create(SyncEntities.todos, {
      'project_id': projectId,
      'title': 'Dig',
    });
    await engine.syncNow();

    // The server deletes the todos with the project but only reports the
    // project; the device must drop the children itself.
    server.records[SyncEntities.projects]!.remove(projectId);
    server.records[SyncEntities.todos]!.clear();
    server.tombstones[SyncEntities.projects]!.add(projectId);
    await engine.syncNow();

    expect(await store.all(SyncEntities.projects), isEmpty);
    expect(await store.all(SyncEntities.todos), isEmpty);
  });

  test('watchers re-read after every write', () async {
    final counts = <int>[];
    final sub = store
        .watch({
          SyncEntities.projects,
        }, () async => (await store.all(SyncEntities.projects)).length)
        .listen(counts.add);

    await pumpEventQueue();
    await engine.create(SyncEntities.projects, project('A'));
    await engine.create(SyncEntities.projects, project('B'));
    await pumpEventQueue();
    await sub.cancel();

    expect(counts, [0, 1, 2]);
  });

  test('signing in as someone else clears the previous account', () async {
    await engine.create(SyncEntities.projects, project('Garden'));
    await engine.stop();

    await engine.start('user-2');

    expect(await store.all(SyncEntities.projects), isEmpty);
    expect(await store.pendingCount(), 0);
  });

  test(
    'an app update that syncs more entities starts with a full pull',
    () async {
      await engine.stop();
      await store.write((txn) => txn.setMeta('entities', 'projects,todos'));

      await engine.start('user-1');

      expect(await store.meta('cursor'), isNull);
      await engine.syncNow();
      expect(await store.meta('cursor'), isNotNull);
    },
  );
}
