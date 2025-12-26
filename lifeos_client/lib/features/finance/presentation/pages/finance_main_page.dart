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
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/loading_skeleton.dart';
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
        if (state is FinanceHomeLoading || state is FinanceHomeInitial) {
          return const LoadingSkeleton();
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
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedWallet03,
              size: 24,
            ),
            action: PrimaryButton(
              onPressed: () => _navigateToAddWallet(context),
              child: const Text('Add Wallet'),
            ),
          );
        }

        if (state is FinanceHomeSuccess) {
          return RefreshTrigger(
            key: _refreshTriggerKey,
            onRefresh: () async {
              context.read<FinanceHomeBloc>().add(const FinanceHomeRefreshed());
              // Wait a bit for the refresh to complete
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: _buildSuccessContent(context, state),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSuccessContent(BuildContext context, FinanceHomeSuccess state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomScrollView(
      slivers: [
        // Total card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TotalCard(
              amount: state.summary.totalBalance,
              currencyCode: state.summary.currencyCode,
            ),
          ),
        ),

        // Wallets section
        if (state.wallets.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                'Wallets',
                style: TextStyle(
                  fontSize: 16,
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
                wallets: state.wallets,
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.foreground,
              ),
            ),
          ),
        ),

        // Transactions list
        if (state.transactions.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index < state.transactions.length) {
                final transaction = state.transactions[index];
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
                    child: state.isLoadingMore
                        ? const CircularProgressIndicator()
                        : state.hasMoreTransactions
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
                            style: TextStyle(
                              color: colorScheme.mutedForeground,
                            ),
                          ),
                  ),
                );
              }
            }, childCount: state.transactions.length + 1),
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

  Future<void> _navigateToAddWallet(BuildContext context) async {
    final result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const AddWalletPage()));

    // If wallet was created successfully, refresh the page
    if (result == true && context.mounted) {
      context.read<FinanceHomeBloc>().add(const FinanceHomeRefreshed());
    }
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
      location: ToastLocation.bottomCenter,
    );
  }
}
