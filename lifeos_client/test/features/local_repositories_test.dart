import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos_client/core/network/api_exception.dart';
import 'package:lifeos_client/core/sync/local_store.dart';
import 'package:lifeos_client/core/sync/sync_api.dart';
import 'package:lifeos_client/core/sync/sync_engine.dart';
import 'package:lifeos_client/features/finance/data/datasources/finance_api_client.dart';
import 'package:lifeos_client/features/finance/data/models/create_transaction_dto.dart';
import 'package:lifeos_client/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:lifeos_client/features/health/data/repositories/health_repository_impl.dart';
import 'package:sembast/sembast_memory.dart';

/// Never reachable: these tests run with the device offline.
class _OfflineSyncApi implements SyncApi {
  @override
  Future<PullResult> pull(String? cursor) async =>
      throw const ApiException('offline', code: 'network');

  @override
  Future<List<PushResult>> push(List<OutboxOp> ops) async =>
      throw const ApiException('offline', code: 'network');
}

void main() {
  late LocalStore store;
  late SyncEngine sync;

  setUp(() async {
    store = await LocalStore.open(
      name: 'repos.db',
      factory: newDatabaseFactoryMemory(),
    );
    sync = SyncEngine(
      store,
      _OfflineSyncApi(),
      debounce: const Duration(days: 1),
      interval: const Duration(days: 1),
      followAppLifecycle: false,
    );
    await sync.start('user-1');
  });

  tearDown(() => sync.dispose());

  test('wallet balances and transactions work offline', () async {
    final finance = FinanceRepositoryImpl(
      apiClient: FinanceApiClient(
        dio: Dio(BaseOptions(connectTimeout: const Duration(milliseconds: 1))),
        baseUrl: 'http://127.0.0.1:1',
      ),
      store: store,
      sync: sync,
    );
    await store.setMeta('cache:currencies', [
      {
        'id': 1,
        'code': 'USD',
        'name': 'US Dollar',
        'color': '22c55e',
        'icon': r'$',
      },
    ]);

    final wallet = await finance.createWallet(
      name: 'Cash',
      currencyId: 1,
      type: 'cash',
    );
    final category = await finance.createCategory(
      title: 'Food',
      type: 'expense',
      icon: 'food',
      color: 'f97316',
    );
    for (final amount in ['100', '-12.5']) {
      await finance.createTransaction(
        CreateTransactionRequestDto(
          clientId: '00000000-0000-4000-8000-00000000000${amount.length}',
          type: amount.startsWith('-') ? 'expense' : 'income',
          categoryId: amount.startsWith('-') ? category.id : null,
          occurredAt: DateTime(2026, 10, amount.length),
          entries: [
            CreateTransactionEntryDto(
              walletId: wallet.id,
              amount: amount,
              currencyId: 1,
            ),
          ],
        ),
      );
    }

    final wallets = await finance.getWalletsWithBalances();
    expect(wallets.single.balance, 87.5);
    expect(wallets.single.currency.code, 'USD');

    final expenses = await finance.getTransactions(type: 'expense');
    expect(expenses.data.single.category?.title, 'Food');
    expect(expenses.data.single.entries.single.wallet.name, 'Cash');
    expect(await store.pendingCount(), 4);
  });

  test(
    'sleep summary is computed on the device, one entry per night',
    () async {
      final health = HealthRepositoryImpl(store: store, sync: sync);

      await health.createSleepEntry(
        date: '2026-10-29',
        sleepStart: '2026-10-28T23:00:00',
        sleepEnd: '2026-10-29T07:00:00',
        quality: 3,
      );
      await health.createSleepEntry(
        date: '2026-10-29',
        sleepStart: '2026-10-28T22:30:00',
        sleepEnd: '2026-10-29T07:00:00',
        quality: 5,
      );
      await health.createSleepEntry(
        date: '2026-10-30',
        sleepStart: '2026-10-29T23:30:00',
        sleepEnd: '2026-10-30T06:30:00',
        quality: 4,
      );

      final summary = await health.getSleepSummary();
      expect(summary.count, 2);
      expect(summary.avgQuality, 4.5);
      expect(summary.avgDurationHours, 7.75);
      expect(summary.points.map((p) => p.date), ['2026-10-29', '2026-10-30']);
    },
  );
}
