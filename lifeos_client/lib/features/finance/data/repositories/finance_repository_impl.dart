import 'dart:async';

import '../../../../core/network/api_exception.dart';
import '../../../../core/sync/local_store.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../domain/repositories/finance_repository.dart';
import '../datasources/finance_api_client.dart';
import '../models/analytics_summary_dto.dart';
import '../models/create_transaction_dto.dart';
import '../models/currency_dto.dart';
import '../models/finance_summary_dto.dart';
import '../models/transaction_category_dto.dart';
import '../models/transaction_dto.dart';
import '../models/wallet_dto.dart';

/// Local-first finance (docs/local-first.md).
///
/// Wallets, categories and transactions come from [store] and are written
/// through [sync]; wallet balances are the sum of their transaction entries,
/// computed here. Currencies, the base-currency setting and FX rates are
/// fetched when online and cached on the device for offline use.
class FinanceRepositoryImpl implements FinanceRepository {
  FinanceRepositoryImpl({
    required this.apiClient,
    required this.store,
    required this.sync,
  });

  final FinanceApiClient apiClient;
  final LocalStore store;
  final SyncEngine sync;

  static const _entities = {
    SyncEntities.wallets,
    SyncEntities.transactionCategories,
    SyncEntities.transactions,
  };
  static const _currenciesKey = 'cache:currencies';
  static const _settingsKey = 'cache:finance_settings';
  static String _fxKey(String origin, String target) =>
      'cache:fx:$origin:$target';

  @override
  Stream<void> get changes =>
      store.changes.where((touched) => touched.any(_entities.contains));

  // ---------------------------------------------------------------------------
  // Cached server data

  /// Runs [fetch] and caches the result under [key]; offline, returns the
  /// cached copy (or rethrows when there is none).
  Future<T> _cached<T>(
    String key,
    Future<T> Function() fetch,
    Object? Function(T value) encode,
    T Function(Object? cached) decode,
  ) async {
    try {
      final value = await fetch();
      await store.setMeta(key, encode(value));
      return value;
    } on ApiException catch (e) {
      final cached = await store.meta(key);
      if (cached == null || e.statusCode == 401) rethrow;
      return decode(cached);
    }
  }

  @override
  Future<List<CurrencyDto>> getAllCurrencies() => _cached(
    _currenciesKey,
    apiClient.getAllCurrencies,
    (list) => [for (final c in list) c.toJson()],
    (cached) => [
      for (final c in cached as List)
        CurrencyDto.fromJson(Map<String, dynamic>.from(c as Map)),
    ],
  );

  @override
  Future<List<CurrencyDto>> getUserCurrencies() => getAllCurrencies();

  /// Currencies by id, without waiting for the network when a copy exists.
  Future<Map<int, Map<String, dynamic>>> _currencyMaps() async {
    var cached = await store.meta(_currenciesKey) as List?;
    if (cached == null) {
      try {
        await getAllCurrencies();
        cached = await store.meta(_currenciesKey) as List?;
      } on ApiException {
        cached = null;
      }
    }
    return {
      for (final c in cached ?? const [])
        (c as Map)['id'] as int: Map<String, dynamic>.from(c),
    };
  }

  static Map<String, dynamic> _unknownCurrency(int id) => {
    'id': id,
    'code': '—',
    'name': 'Unknown currency',
    'color': '9ca3af',
    'icon': '',
  };

  @override
  Future<Map<String, dynamic>> getFinanceSettings() => _cached(
    _settingsKey,
    apiClient.getFinanceSettings,
    (settings) => settings,
    (cached) => Map<String, dynamic>.from(cached as Map),
  );

  @override
  Future<Map<String, dynamic>> updateFinanceSettings({
    required int baseCurrencyId,
  }) async {
    final settings = await apiClient.updateFinanceSettings(
      baseCurrencyId: baseCurrencyId,
    );
    await store.setMeta(_settingsKey, settings);
    return settings;
  }

  Future<double?> _fxRate(String origin, String target) async {
    if (origin == target) return 1;
    try {
      final rate = await apiClient.getFxRate(origin, target);
      if (rate != null) await store.setMeta(_fxKey(origin, target), rate);
      return rate;
    } on ApiException {
      return (await store.meta(_fxKey(origin, target)) as num?)?.toDouble();
    }
  }

  @override
  Future<AnalyticsSummaryDto> getAnalytics({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? currencyId,
  }) async {
    // Analytics is computed on the server: send local changes first so the
    // report includes them. Offline, the request fails with a clear message.
    try {
      await sync.syncNow().timeout(const Duration(seconds: 5));
    } catch (_) {}
    return apiClient.getAnalytics(
      dateFrom: dateFrom,
      dateTo: dateTo,
      currencyId: currencyId,
    );
  }

  // ---------------------------------------------------------------------------
  // Wallets

  Future<List<WalletDto>> _wallets({bool activeOnly = true}) async {
    final currencies = await _currencyMaps();
    final balances = <String, double>{};
    for (final t in await store.all(SyncEntities.transactions)) {
      for (final entry in (t['entries'] as List? ?? const [])) {
        final e = entry as Map;
        final walletId = e['wallet_id'] as String?;
        if (walletId == null) continue;
        balances[walletId] =
            (balances[walletId] ?? 0) +
            ((e['amount'] as num?)?.toDouble() ?? 0);
      }
    }
    return [
      for (final w in await store.all(SyncEntities.wallets))
        if (!activeOnly || w['is_active'] != false)
          WalletDto.fromJson({
            ...w,
            'is_active': w['is_active'] ?? true,
            'currency':
                currencies[w['currency_id']] ??
                _unknownCurrency(w['currency_id'] as int),
            'balance': balances[w['id']] ?? 0,
          }),
    ]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<List<WalletDto>> getWallets() => _wallets();

  @override
  Future<List<WalletDto>> getWalletsWithBalances() => _wallets();

  @override
  Future<WalletDto> getWalletWithBalance(String walletId) async =>
      (await _wallets(activeOnly: false)).firstWhere((w) => w.id == walletId);

  @override
  Future<WalletDto> createWallet({
    required String name,
    required int currencyId,
    required String type,
    bool isActive = true,
  }) async {
    final record = await sync.create(SyncEntities.wallets, {
      'name': name,
      'currency_id': currencyId,
      'type': type,
      'is_active': isActive,
    });
    return (await _wallets(
      activeOnly: false,
    )).firstWhere((w) => w.id == record['id']);
  }

  /// Archives the wallet; its transactions stay.
  @override
  Future<void> deleteWallet(String walletId) =>
      sync.update(SyncEntities.wallets, walletId, {'is_active': false});

  @override
  Future<FinanceSummaryDto> getFinanceSummary() async {
    Map<String, dynamic> settings;
    try {
      settings = await getFinanceSettings();
    } on ApiException {
      settings = const {};
    }
    final base = settings['base_currency'] as Map?;
    if (base == null) {
      return const FinanceSummaryDto(totalBalance: 0, currencyCode: 'USD');
    }
    final baseCode = base['code'] as String;

    // Same rule as before: positive balances, converted to the base
    // currency with the last known rate.
    final byCurrency = <String, double>{};
    for (final wallet in await _wallets()) {
      if (wallet.balance <= 0) continue;
      byCurrency[wallet.currency.code] =
          (byCurrency[wallet.currency.code] ?? 0) + wallet.balance;
    }
    var total = 0.0;
    for (final MapEntry(key: code, value: sum) in byCurrency.entries) {
      final rate = await _fxRate(code, baseCode);
      if (rate != null) total += sum * rate;
    }
    return FinanceSummaryDto(totalBalance: total, currencyCode: baseCode);
  }

  // ---------------------------------------------------------------------------
  // Categories

  @override
  Future<List<TransactionCategoryDto>> getTransactionCategories({
    String? type,
  }) async => [
    for (final c in await store.all(SyncEntities.transactionCategories))
      if (type == null || c['type'] == type) TransactionCategoryDto.fromJson(c),
  ]..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

  @override
  Future<TransactionCategoryDto> createCategory({
    required String title,
    required String type,
    required String icon,
    required String color,
  }) async => TransactionCategoryDto.fromJson(
    await sync.create(SyncEntities.transactionCategories, {
      'title': title,
      'type': type,
      'icon': icon,
      'color': color,
      'is_system': false,
    }),
  );

  @override
  Future<void> deleteCategory(String categoryId) async {
    final category = await store.get(
      SyncEntities.transactionCategories,
      categoryId,
    );
    if (category?['is_system'] == true) {
      throw const ApiException(
        'Built-in categories can\'t be deleted.',
        code: 'forbidden',
      );
    }
    await sync.delete(SyncEntities.transactionCategories, categoryId);
  }

  // ---------------------------------------------------------------------------
  // Transactions

  Future<List<TransactionDto>> _transactions() async {
    final currencies = await _currencyMaps();
    final wallets = {
      for (final w in await store.all(SyncEntities.wallets)) w['id']: w,
    };
    final categories = {
      for (final c in await store.all(SyncEntities.transactionCategories))
        c['id']: c,
    };
    return [
      for (final t in await store.all(SyncEntities.transactions))
        TransactionDto.fromJson({
          ...t,
          'category': categories[t['category_id']],
          'entries': [
            for (final entry in (t['entries'] as List? ?? const []))
              () {
                final e = Map<String, dynamic>.from(entry as Map);
                final wallet = wallets[e['wallet_id']];
                return {
                  ...e,
                  'transaction_id': t['id'],
                  'wallet': {
                    'id': e['wallet_id'],
                    'name': wallet?['name'] ?? 'Deleted wallet',
                    'type': wallet?['type'] ?? 'other',
                  },
                  'currency':
                      currencies[e['currency_id']] ??
                      _unknownCurrency(e['currency_id'] as int),
                  'created_at': t['created_at'],
                };
              }(),
          ],
        }),
    ]..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  }

  @override
  Future<TransactionListResponseDto> getTransactions({
    int page = 1,
    int perPage = 20,
    String? type,
    String? walletId,
    String? categoryId,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? searchQuery,
  }) async {
    final query = searchQuery?.trim().toLowerCase() ?? '';
    final matching = (await _transactions()).where((t) {
      if (type != null && t.type.toJson() != type) return false;
      if (categoryId != null && t.categoryId != categoryId) return false;
      if (walletId != null && !t.entries.any((e) => e.walletId == walletId)) {
        return false;
      }
      if (dateFrom != null && t.occurredAt.isBefore(dateFrom)) return false;
      if (dateTo != null && t.occurredAt.isAfter(dateTo)) return false;
      if (query.isNotEmpty &&
          !(t.description ?? '').toLowerCase().contains(query) &&
          !(t.category?.title ?? '').toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList();

    final start = ((page - 1) * perPage).clamp(0, matching.length);
    final end = (start + perPage).clamp(0, matching.length);
    return TransactionListResponseDto(
      data: matching.sublist(start, end),
      meta: PaginationMeta(
        currentPage: page,
        lastPage: (matching.length / perPage).ceil().clamp(1, 1 << 30),
        perPage: perPage,
        total: matching.length,
      ),
    );
  }

  @override
  Future<TransactionDto> createTransaction(
    CreateTransactionRequestDto request,
  ) async {
    final record = await sync.create(SyncEntities.transactions, {
      'type': request.type,
      'category_id': request.categoryId,
      'description': request.description,
      'occurred_at': request.occurredAt.toUtc().toIso8601String(),
      'entries': [
        for (final e in request.entries)
          {
            'wallet_id': e.walletId,
            'amount': double.parse(e.amount),
            'currency_id': e.currencyId,
            'rate': e.rate == null ? null : double.tryParse(e.rate!),
            'note': e.note,
          },
      ],
    }, id: request.clientId);
    return (await _transactions()).firstWhere((t) => t.id == record['id']);
  }

  @override
  Future<void> deleteTransaction(String transactionId) =>
      sync.delete(SyncEntities.transactions, transactionId);
}
