import 'package:lifeos_client/core/extension/extensions.dart';
import 'package:lifeos_client/features/finance/data/datasources/constants.dart';
import 'package:lifeos_client/utils/dialogs.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../injection.dart';
import '../../data/models/wallet_dto.dart';
import '../bloc/manage_wallets_bloc.dart';
import '../bloc/manage_wallets_event.dart';
import '../bloc/manage_wallets_state.dart';
import 'package:lifeos_client/core/ui/ui.dart';

class ManageWalletsPage extends StatelessWidget {
  const ManageWalletsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ManageWalletsBloc>()..add(const ManageWalletsLoad()),
      child: const _ManageWalletsPageContent(),
    );
  }
}

class _ManageWalletsPageContent extends StatefulWidget {
  const _ManageWalletsPageContent();

  @override
  State<_ManageWalletsPageContent> createState() =>
      _ManageWalletsPageContentState();
}

class _ManageWalletsPageContentState extends State<_ManageWalletsPageContent> {
  void _showDeleteConfirmation(BuildContext context, WalletDto wallet) async {
    bool? confirmed = await Dialogs.showConfirmDialog(
      title: 'Delete Wallet',
      message: 'Are you sure you want to delete "${wallet.name}"?',
      context: context,
      confirmLabel: 'Delete',
      destructive: true,
    );

    if (confirmed == true) {
      if (context.mounted) {
        context.read<ManageWalletsBloc>().add(
          ManageWalletsDelete(walletId: wallet.id),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<ManageWalletsBloc, ManageWalletsState>(
      listener: (context, state) {
        if (state is ManageWalletsDeleteSuccess) {
          AppToast.success(context, 'Wallet deleted');
        } else if (state is ManageWalletsDeleteError) {
          AppToast.error(
            context,
            'Something went wrong',
            message: state.message,
          );
        }
      },
      child: Scaffold(
        headers: [
          AppHeader(
            title: 'Wallets',
            // actions: [
            //   HeaderAction(
            //     icon: HugeIcons.strokeRoundedAdd01,
            //     tooltip: 'Add wallet',
            //     onTap: () => _navigateToAddWallet(context),
            //   ),
            // ],
          ),
        ],
        child: BlocBuilder<ManageWalletsBloc, ManageWalletsState>(
          builder: (context, state) {
            if (state is ManageWalletsLoading) {
              return LoadingState(message: 'Loading wallets...');
            }

            if (state is ManageWalletsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedAlert02,
                      size: 48,
                      color: colorScheme.destructive,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load wallets',
                      style: Theme.of(context).typography.normal.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.foreground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).typography.small.copyWith(
                        color: colorScheme.mutedForeground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      onPressed: () {
                        context.read<ManageWalletsBloc>().add(
                          const ManageWalletsLoad(),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final wallets = state is ManageWalletsLoaded
                ? state.wallets
                : state is ManageWalletsDeleting
                ? state.wallets
                : state is ManageWalletsDeleteSuccess
                ? state.wallets
                : state is ManageWalletsDeleteError
                ? state.wallets
                : <WalletDto>[];

            final deletingWalletId = state is ManageWalletsDeleting
                ? state.walletId
                : null;

            if (wallets.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedWallet02,
                      size: 64,
                      color: colorScheme.mutedForeground,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No wallets yet',
                      style: Theme.of(context).typography.large.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.foreground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first wallet to get started',
                      style: Theme.of(context).typography.small.copyWith(
                        color: colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: ContentWidth(
                child: AppListSection(
                  title: 'Your wallets',
                  count: wallets.length,
                  footer:
                      'Deleting a wallet hides it; its transaction history is kept.',
                  children: [
                    for (final wallet in wallets)
                      AppListTile(
                        leading: LeadingTile.icon(
                          FinanceConstants.getWalletTypeIcon(wallet.type),
                        ),
                        title: wallet.name,
                        subtitle:
                            '${FinanceConstants.getWalletTypeName(wallet.type)} · ${wallet.balance.toMoneyFormat()} ${wallet.currency.code}',
                        loading: deletingWalletId == wallet.id,
                        actions: [
                          AppAction(
                            label: 'Delete wallet',
                            icon: HugeIcons.strokeRoundedDelete02,
                            destructive: true,
                            onSelected: () =>
                                _showDeleteConfirmation(context, wallet),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Future<void> _navigateToAddWallet(BuildContext context) async {
  //   final result = await Navigator.of(
  //     context,
  //   ).push<bool>(CupertinoPageRoute(builder: (_) => const AddWalletPage()));

  //   // If wallet was created successfully, refresh the page
  //   if (result == true && context.mounted) {
  //     context.read<ManageWalletsBloc>().add(const ManageWalletsLoad());
  //   }
  // }
}
