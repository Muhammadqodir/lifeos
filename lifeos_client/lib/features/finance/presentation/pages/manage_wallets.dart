import 'package:lifeos_client/core/extension/extensions.dart';
import 'package:lifeos_client/core/theme/app_colors.dart';
import 'package:lifeos_client/features/finance/data/datasources/constants.dart';
import 'package:lifeos_client/utils/dialogs.dart';
import 'package:lifeos_client/utils/toast.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../injection.dart';
import '../../../navigation/presentation/widgets/custom_app_bar.dart';
import '../../data/models/wallet_dto.dart';
import '../bloc/manage_wallets_bloc.dart';
import '../bloc/manage_wallets_event.dart';
import '../bloc/manage_wallets_state.dart';

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
          showToast(
            context: context,
            builder: (context, overlay) {
              return Utils.buildToast(
                context,
                overlay,
                'Success',
                'Wallet deleted successfully',
              );
            },
            location: ToastLocation.topCenter,
          );
        } else if (state is ManageWalletsDeleteError) {
          showToast(
            context: context,
            builder: (context, overlay) {
              return Utils.buildToast(context, overlay, 'Error', state.message);
            },
            location: ToastLocation.bottomCenter,
          );
        }
      },
      child: Scaffold(
        headers: [
          CustomAppBar(
            title: 'Manage Wallets',
            leftActions: [
              AppBarAction(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                tooltip: 'Back',
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
            // rightActions: [
            //   AppBarAction(
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
              return const Center(child: CircularProgressIndicator());
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...wallets.map((wallet) {
                    final isDeleting = deletingWalletId == wallet.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Wallet icon
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: colorScheme.muted,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: HugeIcon(
                                  icon: FinanceConstants.getWalletTypeIcon(
                                    wallet.type,
                                  ),
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Wallet details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    wallet.name,
                                    style: Theme.of(context).typography.small
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.foreground,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        FinanceConstants.getWalletTypeName(
                                          wallet.type,
                                        ),
                                        style: Theme.of(context)
                                            .typography
                                            .xSmall
                                            .copyWith(
                                              color:
                                                  colorScheme.mutedForeground,
                                            ),
                                      ),

                                      if (wallet.balance != null) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          '•',
                                          style: Theme.of(context)
                                              .typography
                                              .xSmall
                                              .copyWith(
                                                color:
                                                    colorScheme.mutedForeground,
                                              ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${wallet.balance!.toMoneyFormat()} ${wallet.currency.code}',
                                          style: Theme.of(context)
                                              .typography
                                              .xSmall
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    colorScheme.mutedForeground,
                                              ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Delete button
                            if (isDeleting)
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              IconButton.ghost(
                                icon: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedDelete02,
                                  size: 22,
                                  color: AppColors.redColor,
                                ),
                                onPressed: () =>
                                    _showDeleteConfirmation(context, wallet),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
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
  //   ).push<bool>(MaterialPageRoute(builder: (_) => const AddWalletPage()));

  //   // If wallet was created successfully, refresh the page
  //   if (result == true && context.mounted) {
  //     context.read<ManageWalletsBloc>().add(const ManageWalletsLoad());
  //   }
  // }
}
