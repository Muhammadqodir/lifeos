import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/ui/ui.dart';
import '../../../../core/utils/date_labels.dart';
import '../../../../injection.dart';
import '../../data/models/transaction_dto.dart';
import '../../data/models/wallet_dto.dart';
import '../bloc/manage_transactions_bloc.dart';
import '../bloc/manage_transactions_event.dart';
import '../bloc/manage_transactions_state.dart';
import '../bloc/manage_wallets_bloc.dart';
import '../bloc/manage_wallets_event.dart';
import '../bloc/manage_wallets_state.dart';
import '../widgets/total_card.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/wallet_carousel.dart';
import 'add_transaction_page.dart';
import 'add_wallet_page.dart';
import 'analytics_page.dart';
import 'finance_settings_page.dart';
import 'manage_wallets.dart';

class FinanceMainPage extends StatefulWidget {
  const FinanceMainPage({super.key});

  @override
  State<FinanceMainPage> createState() => _FinanceMainPageState();
}

class _FinanceMainPageState extends State<FinanceMainPage> {
  late final ManageWalletsBloc _walletsBloc;
  late final ManageTransactionsBloc _transactionsBloc;

  final GlobalKey<RefreshTriggerState> _refreshTriggerKey =
      GlobalKey<RefreshTriggerState>();

  @override
  void initState() {
    super.initState();
    _walletsBloc = getIt<ManageWalletsBloc>()..add(const ManageWalletsLoad());
    _transactionsBloc = getIt<ManageTransactionsBloc>()
      ..add(const ManageTransactionsLoad());
  }

  @override
  void dispose() {
    _walletsBloc.close();
    _transactionsBloc.close();
    super.dispose();
  }

  void _refresh() {
    _walletsBloc.add(const ManageWalletsRefresh());
    _transactionsBloc.add(const ManageTransactionsRefresh());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ManageWalletsBloc>.value(value: _walletsBloc),
        BlocProvider<ManageTransactionsBloc>.value(value: _transactionsBloc),
      ],
      child: BlocListener<ManageTransactionsBloc, ManageTransactionsState>(
        listener: (context, state) {
          if (state is ManageTransactionsDeleteSuccess) {
            // Balances change when a transaction is removed.
            _walletsBloc.add(const ManageWalletsRefresh());
            AppToast.success(context, 'Transaction deleted');
          }
        },
        child: Scaffold(
          headers: [
            AppHeader(
              title: 'Finances',
              onRefresh: _refresh,
              actions: [
                HeaderAction(
                  icon: HugeIcons.strokeRoundedPieChart,
                  tooltip: 'Analytics',
                  onTap: () => _push(context, const AnalyticsPage()),
                ),
                HeaderAction(
                  icon: HugeIcons.strokeRoundedSettings02,
                  tooltip: 'Finance settings',
                  onTap: () => _push(context, const FinanceSettingsPage()),
                ),
                HeaderAction(
                  icon: HugeIcons.strokeRoundedAdd01,
                  tooltip: 'Add transaction',
                  label: 'Add transaction',
                  primary: true,
                  onTap: () => _navigateToAddTransaction(context),
                ),
              ],
            ),
          ],
          child: RefreshTrigger(
            key: _refreshTriggerKey,
            onRefresh: () async {
              _refresh();
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: _buildBody(context),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<ManageWalletsBloc, ManageWalletsState>(
      builder: (context, walletsState) {
        return BlocBuilder<ManageTransactionsBloc, ManageTransactionsState>(
          builder: (context, transactionsState) {
            final List<WalletDto> wallets =
                walletsState is ManageWalletsWithData
                ? walletsState.wallets
                : const [];
            final summary = walletsState is ManageWalletsWithData
                ? walletsState.summary
                : null;
            final walletsLoading = walletsState is ManageWalletsLoading;

            final List<TransactionDto> transactions =
                transactionsState is ManageTransactionsWithData
                ? transactionsState.transactions
                : const [];
            final transactionsLoading =
                transactionsState is ManageTransactionsLoading;
            final hasMore =
                transactionsState is ManageTransactionsLoaded &&
                transactionsState.hasMore;
            final isLoadingMore =
                transactionsState is ManageTransactionsLoaded &&
                transactionsState.isLoadingMore;

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverContentWidth(
                  vertical: const EdgeInsets.only(top: AppSpacing.lg),
                  sliver: SliverToBoxAdapter(
                    child: TotalCard(
                      amount: summary?.totalBalance ?? 0.0,
                      currencyCode: summary?.currencyCode ?? '',
                    ).asSkeleton(enabled: walletsLoading),
                  ),
                ),
                SliverContentWidth(
                  vertical: const EdgeInsets.only(top: AppSpacing.section),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SectionHeader(
                          title: 'Wallets',
                          count: walletsLoading ? null : wallets.length,
                          trailing: wallets.isEmpty
                              ? null
                              : GhostButton(
                                  size: ButtonSize.small,
                                  density: ButtonDensity.compact,
                                  onPressed: () =>
                                      _navigateToManageWallet(context),
                                  child: const Text('Manage'),
                                ),
                        ),
                        WalletCarousel(
                          wallets: wallets,
                          onAddWallet: () => _navigateToAddWallet(context),
                          onManageWallet: () =>
                              _navigateToManageWallet(context),
                          onWalletTap: (_) => _navigateToManageWallet(context),
                        ).asSkeleton(enabled: walletsLoading),
                      ],
                    ),
                  ),
                ),
                SliverContentWidth(
                  vertical: const EdgeInsets.only(top: AppSpacing.section),
                  sliver: SliverToBoxAdapter(
                    child: _buildHistory(
                      context,
                      transactions,
                      loading: transactionsLoading,
                    ),
                  ),
                ),
                if (transactions.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.xxl,
                      ),
                      child: Center(
                        child: isLoadingMore
                            ? const CircularProgressIndicator(size: 20)
                            : hasMore
                            ? OutlineButton(
                                onPressed: () => _transactionsBloc.add(
                                  const ManageTransactionsLoadMore(),
                                ),
                                child: const Text('Show more'),
                              )
                            : Text(
                                "You've reached the beginning",
                                style: context.text.caption,
                              ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  /// Transactions grouped by day, newest first.
  Widget _buildHistory(
    BuildContext context,
    List<TransactionDto> transactions, {
    required bool loading,
  }) {
    if (loading && transactions.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'History'),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: context.colors.muted,
              borderRadius: context.theme.cardRadius,
            ),
          ).asSkeleton(),
        ],
      );
    }

    if (transactions.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'History'),
          AppCard(
            child: EmptyState(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedInvoice03),
              title: 'No transactions yet',
              description: 'Income and expenses you add will appear here.',
              action: OutlineButton(
                onPressed: () => _navigateToAddTransaction(context),
                child: const Text('Add transaction'),
              ),
            ),
          ),
        ],
      );
    }

    final groups = <DateTime, List<TransactionDto>>{};
    for (final t in transactions) {
      final day = DateTime(
        t.occurredAt.year,
        t.occurredAt.month,
        t.occurredAt.day,
      );
      groups.putIfAbsent(day, () => []).add(t);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in groups.entries)
          AppListSection(
            title: DateLabels.relativeDay(entry.key),
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            children: [
              for (final transaction in entry.value)
                TransactionTile(
                  transaction: transaction,
                  onDelete: () => _confirmDelete(context, transaction),
                ),
            ],
          ),
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TransactionDto transaction,
  ) async {
    final confirmed = await AppDialogs.confirmDelete(
      context,
      itemName: 'transaction',
      message: 'Wallet balances will be recalculated.',
    );
    if (confirmed && mounted) {
      _transactionsBloc.add(
        ManageTransactionsDelete(transactionId: transaction.id),
      );
    }
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(CupertinoPageRoute(builder: (_) => page));
  }

  Future<void> _navigateToAddTransaction(BuildContext context) async {
    final result = await Navigator.of(
      context,
    ).push<bool>(CupertinoPageRoute(builder: (_) => const AddTransactionPage()));
    if (result == true && mounted) _refresh();
  }

  Future<void> _navigateToAddWallet(BuildContext context) async {
    final result = await Navigator.of(
      context,
    ).push<bool>(CupertinoPageRoute(builder: (_) => const AddWalletPage()));
    if (result == true && mounted) {
      _walletsBloc.add(const ManageWalletsRefresh());
    }
  }

  Future<void> _navigateToManageWallet(BuildContext context) async {
    final result = await Navigator.of(
      context,
    ).push<bool>(CupertinoPageRoute(builder: (_) => const ManageWalletsPage()));
    if (result == true && mounted) _refresh();
  }
}
