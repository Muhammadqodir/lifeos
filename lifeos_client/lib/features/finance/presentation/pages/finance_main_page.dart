import 'package:flutter/cupertino.dart';
import 'package:lifeos_client/features/finance/presentation/pages/add_transaction_page.dart';
import 'package:lifeos_client/features/finance/presentation/pages/analytics_page.dart';
import 'package:lifeos_client/features/finance/presentation/pages/finance_settings_page.dart';
import 'package:lifeos_client/core/widgets/loading_state.dart';
import 'package:lifeos_client/features/finance/presentation/pages/manage_wallets.dart';
import 'package:lifeos_client/features/navigation/presentation/widgets/custom_app_bar.dart';
import 'package:lifeos_client/utils/toast.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import '../bloc/finance_home_bloc.dart';
import '../bloc/finance_home_event.dart';
import '../bloc/finance_home_state.dart';
import '../widgets/total_card.dart';
import '../widgets/wallet_carousel.dart';
import '../widgets/transaction_tile.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import 'add_wallet_page.dart';

class FinanceMainPage extends StatefulWidget {
  const FinanceMainPage({super.key});

  @override
  State<FinanceMainPage> createState() => _FinanceMainPageState();
}

class _FinanceMainPageState extends State<FinanceMainPage> {
  final GlobalKey<RefreshTriggerState> _refreshTriggerKey =
      GlobalKey<RefreshTriggerState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceHomeBloc, FinanceHomeState>(
      builder: (context, state) {
        return Column(
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
                  context.read<FinanceHomeBloc>().add(
                    const FinanceHomeRefreshed(),
                  );
                  // Wait a bit for the refresh to complete
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: _buildBody(context, state),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, FinanceHomeState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (state is FinanceHomeLoading || state is FinanceHomeInitial) {
      return const LoadingState(message: "Loading...");
    }

    if (state is FinanceHomeFailure) {
      return ErrorState(
        message: state.message,
        onRetry: () {
          context.read<FinanceHomeBloc>().add(const FinanceHomeRetried());
        },
      );
    }

    if (state is FinanceHomeEmpty) {
      return EmptyState(
        title: 'No Finance Data',
        description: 'Start by adding your first wallet and transaction',
        icon: HugeIcon(icon: HugeIcons.strokeRoundedWallet03, size: 24),
        action: PrimaryButton(
          onPressed: () => _navigateToAddWallet(context),
          child: const Text('Add Wallet'),
        ),
      );
    }

    FinanceHomeSuccess successState = state as FinanceHomeSuccess;
    return CustomScrollView(
      slivers: [
        // Total card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TotalCard(
              amount: successState.summary.totalBalance,
              currencyCode: successState.summary.currencyCode,
            ),
          ),
        ),

        // Wallets section
        if (successState.wallets.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                wallets: successState.wallets,
                onAddWallet: () {
                  _navigateToAddWallet(context);
                },
                onManageWallet: () {
                  _navigateToManageWallet(context);
                },

                onWalletTap: (walletId) {
                  // TODO: Navigate to wallet details
                  _showComingSoonToast(context, 'Wallet Details #$walletId');
                },
              ),
            ),
          ),
        ] else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: EmptyState(
                    title: 'No Wallets',
                    description: 'Add your first wallet to start tracking',
                    action: Button.ghost(
                      onPressed: () => _navigateToAddWallet(context),
                      child: const Text('Add Wallet'),
                    ),
                  ),
                ),
              ),
            ),
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
        if (successState.transactions.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index < successState.transactions.length) {
                final transaction = successState.transactions[index];
                return TransactionTile(
                  transaction: transaction,
                  onTap: () {
                    // TODO: Navigate to transaction details
                    _showComingSoonToast(
                      context,
                      'Transaction Details #${transaction.id}',
                    );
                  },
                );
              } else {
                // Load more button
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: successState.isLoadingMore
                        ? const CircularProgressIndicator()
                        : successState.hasMoreTransactions
                        ? Button.outline(
                            onPressed: () {
                              context.read<FinanceHomeBloc>().add(
                                const FinanceHomeLoadMoreHistory(),
                              );
                            },
                            child: const Text('Load More'),
                          )
                        : Text(
                            'No more transactions',
                            style: Theme.of(context).typography.small.copyWith(
                              color: colorScheme.mutedForeground,
                            ),
                          ),
                  ),
                );
              }
            }, childCount: successState.transactions.length + 1),
          )
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: EmptyState(
                    title: 'No Transactions',
                    description: 'Your transaction history will appear here',
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedListView,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  /// Navigate to Add Transaction page
  Future<void> _navigateToAddTransaction(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddTransactionPage()),
    );

    // If wallet was created successfully, refresh the page
    if (result == true && context.mounted) {
      context.read<FinanceHomeBloc>().add(const FinanceHomeRefreshed());
    }
  }

  Future<void> _navigateToAddWallet(BuildContext context) async {
    final result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const AddWalletPage()));

    // If wallet was created successfully, refresh the page
    if (result == true && context.mounted) {
      context.read<FinanceHomeBloc>().add(const FinanceHomeRefreshed());
    }
  }

  Future<void> _navigateToManageWallet(BuildContext context) async {
    final result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const ManageWalletsPage()));

    // If wallet was created successfully, refresh the page
    if (result == true && context.mounted) {
      context.read<FinanceHomeBloc>().add(const FinanceHomeRefreshed());
    }
  }

  void _navigateToAnalytics(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AnalyticsPage()),
    );
  }

  void _navigateToFinanceSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FinanceSettingsPage()),
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
