import 'package:flutter/cupertino.dart';
import 'package:lifeos_client/features/finance/presentation/pages/add_transaction_page.dart';
import 'package:lifeos_client/features/finance/presentation/pages/analytics_page.dart';
import 'package:lifeos_client/features/finance/presentation/pages/finance_settings_page.dart';
import 'package:lifeos_client/features/finance/presentation/pages/manage_wallets.dart';
import 'package:lifeos_client/features/navigation/presentation/widgets/custom_app_bar.dart';
import 'package:lifeos_client/utils/dialogs.dart';
import 'package:lifeos_client/utils/toast.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../injection.dart';
import '../../data/models/wallet_dto.dart';
import '../../data/models/transaction_dto.dart';
import '../bloc/manage_wallets_bloc.dart';
import '../bloc/manage_wallets_event.dart';
import '../bloc/manage_wallets_state.dart';
import '../bloc/manage_transactions_bloc.dart';
import '../bloc/manage_transactions_event.dart';
import '../bloc/manage_transactions_state.dart';
import '../widgets/total_card.dart';
import '../widgets/wallet_carousel.dart';
import '../widgets/transaction_tile.dart';
import '../../../../core/widgets/empty_state.dart';
import 'add_wallet_page.dart';

class FinanceMainPage extends StatefulWidget {
  const FinanceMainPage({super.key});

  @override
  State<FinanceMainPage> createState() => _FinanceMainPageState();
}

class _FinanceMainPageState extends State<FinanceMainPage> {
  late final ManageWalletsBloc _walletsBloc;
  late final ManageTransactionsBloc _transactionsBloc;

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

  final GlobalKey<RefreshTriggerState> _refreshTriggerKey =
      GlobalKey<RefreshTriggerState>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ManageWalletsBloc>.value(value: _walletsBloc),
        BlocProvider<ManageTransactionsBloc>.value(value: _transactionsBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ManageTransactionsBloc, ManageTransactionsState>(
            listener: (context, state) {
              // When transaction is deleted, refresh wallets to update balances
              if (state is ManageTransactionsDeleteSuccess) {
                _walletsBloc.add(const ManageWalletsRefresh());
                showToast(
                  context: context,
                  location: ToastLocation.topCenter,
                  builder: (context, overlay) {
                    return Utils.buildToast(
                      context,
                      overlay,
                      'Transaction Deleted',
                      'The transaction has been deleted successfully.',
                    );
                  },
                );
              }
            },
          ),
        ],
        child: Column(
          children: [
            CustomAppBar(
              title: "Finances",
              rightActions: [
                AppBarAction(
                  icon: HugeIcons.strokeRoundedAdd01,
                  tooltip: 'Add Transaction',
                  onTap: () {
                    _navigateToAddTransaction(context);
                  },
                ),
                AppBarAction(
                  icon: HugeIcons.strokeRoundedPieChart,
                  tooltip: 'Analytics',
                  onTap: () {
                    _navigateToAnalytics(context);
                  },
                ),
                AppBarAction(
                  icon: HugeIcons.strokeRoundedDatabaseSetting,
                  tooltip: 'Finance Settings',
                  onTap: () {
                    _navigateToFinanceSettings(context);
                  },
                ),
              ],
            ),
            Expanded(
              child: RefreshTrigger(
                key: _refreshTriggerKey,
                onRefresh: () async {
                  _walletsBloc.add(const ManageWalletsRefresh());
                  _transactionsBloc.add(const ManageTransactionsRefresh());
                  // Wait a bit for the refresh to complete
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: _buildBody(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<ManageWalletsBloc, ManageWalletsState>(
      builder: (context, walletsState) {
        return BlocBuilder<ManageTransactionsBloc, ManageTransactionsState>(
          builder: (context, transactionsState) {
            // Get wallets data
            final List<WalletDto> wallets =
                walletsState is ManageWalletsWithData
                ? walletsState.wallets
                : [];

            final summary = walletsState is ManageWalletsWithData
                ? walletsState.summary
                : null;

            // Get transactions data
            final List<TransactionDto> transactions =
                transactionsState is ManageTransactionsWithData
                ? transactionsState.transactions
                : [];

            final hasMoreTransactions =
                transactionsState is ManageTransactionsLoaded &&
                transactionsState.hasMore;
            final isLoadingMore =
                transactionsState is ManageTransactionsLoaded &&
                transactionsState.isLoadingMore;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: TotalCard(
                      amount: summary?.totalBalance ?? 0.0,
                      currencyCode: summary?.currencyCode ?? '',
                    ),
                  ).asSkeleton(enabled: walletsState is ManageWalletsLoading),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text(
                      'Wallets',
                      style: theme.typography.normal.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.foreground,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: WalletCarousel(
                      wallets: wallets,
                      onAddWallet: () {
                        _navigateToAddWallet(context);
                      },
                      onManageWallet: () {
                        _navigateToManageWallet(context);
                      },
                      onWalletTap: (walletId) {
                        // TODO: Navigate to wallet details
                        _showComingSoonToast(
                          context,
                          'Wallet Details #$walletId',
                        );
                      },
                    ),
                  ).asSkeleton(enabled: walletsState is ManageWalletsLoading),
                ),

                // History section header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      'History',
                      style: theme.typography.normal.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.foreground,
                      ),
                    ),
                  ),
                ),

                // Transactions list
                if (transactions.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index < transactions.length) {
                        final transaction = transactions[index];
                        return TransactionTile(
                          transaction: transaction,
                          onTap: () {
                            // TODO: Navigate to transaction details
                            _showComingSoonToast(
                              context,
                              'Transaction Details #${transaction.id}',
                            );
                          },
                          onDelete: () async {
                            bool? confirmed = await Dialogs.showConfirmDialog(
                              context: context,
                              title: 'Delete Transaction',
                              message:
                                  'Are you sure you want to delete this transaction?',
                            );
                            if (confirmed == true) {
                              if (context.mounted) {
                                _transactionsBloc.add(
                                  ManageTransactionsDelete(
                                    transactionId: transaction.id,
                                  ),
                                );
                              }
                            }
                          },
                        );
                      } else {
                        // Load more button
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: isLoadingMore
                                ? const CircularProgressIndicator()
                                : hasMoreTransactions
                                ? Button.outline(
                                    onPressed: () {
                                      _transactionsBloc.add(
                                        const ManageTransactionsLoadMore(),
                                      );
                                    },
                                    child: const Text('Load More'),
                                  )
                                : Text(
                                    'No more transactions',
                                    style: Theme.of(context).typography.small
                                        .copyWith(
                                          color: colorScheme.mutedForeground,
                                        ),
                                  ),
                          ),
                        );
                      }
                    }, childCount: transactions.length + 1),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: EmptyState(
                          title: 'No Transactions',
                          description:
                              'Your transaction history will appear here',
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedListView,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            );
          },
        );
      },
    );
  }

  /// Navigate to Add Transaction page
  Future<void> _navigateToAddTransaction(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(builder: (_) => const AddTransactionPage()),
    );

    // If transaction was created successfully, refresh both blocs
    if (result == true && context.mounted) {
      _walletsBloc.add(const ManageWalletsRefresh());
      _transactionsBloc.add(const ManageTransactionsRefresh());
    }
  }

  Future<void> _navigateToAddWallet(BuildContext context) async {
    final result = await Navigator.of(
      context,
    ).push<bool>(CupertinoPageRoute(builder: (_) => const AddWalletPage()));

    // If wallet was created successfully, refresh wallets
    if (result == true && context.mounted) {
      _walletsBloc.add(const ManageWalletsRefresh());
    }
  }

  Future<void> _navigateToManageWallet(BuildContext context) async {
    final result = await Navigator.of(
      context,
    ).push<bool>(CupertinoPageRoute(builder: (_) => const ManageWalletsPage()));

    // If wallet was deleted, refresh both blocs
    if (result == true && context.mounted) {
      _walletsBloc.add(const ManageWalletsRefresh());
      _transactionsBloc.add(const ManageTransactionsRefresh());
    }
  }

  void _navigateToAnalytics(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => const AnalyticsPage()),
    );
  }

  void _navigateToFinanceSettings(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => const FinanceSettingsPage()),
    );
  }

  void _showComingSoonToast(BuildContext context, String feature) {
    showToast(
      context: context,
      builder: (context, overlay) => Utils.buildToast(
        context,
        overlay,
        'Coming Soon',
        '$feature feature is not yet implemented',
      ),
      location: ToastLocation.topCenter,
    );
  }
}
