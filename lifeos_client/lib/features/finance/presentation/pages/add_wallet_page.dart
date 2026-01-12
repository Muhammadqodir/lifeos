import 'package:lifeos_client/core/widgets/selectable_group.dart';
import 'package:lifeos_client/features/finance/data/datasources/constants.dart';
import 'package:lifeos_client/utils/toast.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../injection.dart';
import '../../../navigation/presentation/widgets/custom_app_bar.dart';
import '../../data/models/wallet_dto.dart';
import '../bloc/add_wallet_bloc.dart';
import '../bloc/add_wallet_event.dart';
import '../bloc/add_wallet_state.dart';

class AddWalletPage extends StatelessWidget {
  const AddWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<AddWalletBloc>()..add(const AddWalletLoadCurrencies()),
      child: const _AddWalletPageContent(),
    );
  }
}

class _AddWalletPageContent extends StatefulWidget {
  const _AddWalletPageContent();

  @override
  State<_AddWalletPageContent> createState() => _AddWalletPageContentState();
}

class _AddWalletPageContentState extends State<_AddWalletPageContent> {
  String _walletName = '';
  int? _selectedCurrencyId;
  WalletType _selectedWalletType = WalletType.card;
  bool _isActive = true;

  void _handleFormSubmit(BuildContext context) {
    // Validate wallet name
    if (_walletName.trim().isEmpty) {
      showToast(
        context: context,
        builder: (context, overlay) {
          return Utils.buildToast(
            context,
            overlay,
            'Validation Error',
            'Please enter a wallet name',
          );
        },
        location: ToastLocation.topCenter,
      );
      return;
    }

    // Validate currency selection
    if (_selectedCurrencyId == null) {
      showToast(
        context: context,
        builder: (context, overlay) {
          return Utils.buildToast(
            context,
            overlay,
            'Validation Error',
            'Please select a currency',
          );
        },
        location: ToastLocation.topCenter,
      );
      return;
    }

    // Submit to BLoC
    context.read<AddWalletBloc>().add(
      AddWalletSubmitted(
        name: _walletName.trim(),
        currencyId: _selectedCurrencyId!,
        type: _selectedWalletType.toJson(),
        isActive: _isActive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final outerContext = context;

    return BlocListener<AddWalletBloc, AddWalletState>(
      listener: (context, state) {
        if (state is AddWalletSuccess) {
          showToast(
            context: context,
            builder: (context, overlay) {
              return Utils.buildToast(
                context,
                overlay,
                'Success',
                'Wallet created successfully',
              );
            },
            location: ToastLocation.topCenter,
          );
          Navigator.of(context).pop(true);
        } else if (state is AddWalletError) {
          showToast(
            context: context,
            builder: (context, overlay) {
              return Utils.buildToast(context, overlay, 'Error', state.message);
            },
            location: ToastLocation.bottomCenter,
          );
          Navigator.of(context).pop(false);
        }
      },
      child: Scaffold(
        headers: [
          CustomAppBar(
            title: 'Add Wallet',
            leftActions: [
              AppBarAction(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                tooltip: 'Back',
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
        child: BlocBuilder<AddWalletBloc, AddWalletState>(
          builder: (context, state) {
            if (state is AddWalletLoadingCurrencies) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AddWalletCurrenciesError) {
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
                      'Failed to load currencies',
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
                        context.read<AddWalletBloc>().add(
                          const AddWalletLoadCurrencies(),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final currencies = state is AddWalletReady ? state.currencies : [];
            final isSubmitting = state is AddWalletSubmitting;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Wallet Name Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wallet Name',
                        style: Theme.of(context).typography.small,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        initialValue: _walletName,
                        placeholder: const Text('e.g., My Cash Wallet'),
                        onSubmitted: (_) => FocusScope.of(context).unfocus(),
                        onChanged: (value) {
                          setState(() {
                            _walletName = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Currency Selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Currency',
                        style: Theme.of(context).typography.small,
                      ),
                      const SizedBox(height: 8),
                      if (currencies.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.muted,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'No currencies available',
                            style: Theme.of(context).typography.normal.copyWith(
                              color: colorScheme.mutedForeground,
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: Select<int>(
                            placeholder: Text("Select currency",
                                style: Theme.of(context)
                                    .typography
                                    .small
                                    .copyWith(color: colorScheme.mutedForeground)),
                            value: _selectedCurrencyId,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            itemBuilder: (context, item) {
                              final currency = currencies.firstWhere(
                                (c) => c.id == item,
                              );
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Text(currency.icon, style: Theme.of(context).typography.small),
                                  // const SizedBox(width: 12),
                                  Text(
                                    currency.name,
                                    style: Theme.of(context).typography.small.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              );
                            },
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedCurrencyId = value;
                                });
                              }
                            },
                            popup: SelectPopup(
                              items: SelectItemList(
                                children: currencies
                                    .map(
                                      (currency) => SelectItemButton<int>(
                                        value: currency.id,
                                        child: Row(
                                          children: [
                                            // Text(
                                            //   currency.icon,
                                            //   style: Theme.of(context).typography.base,
                                            // ),
                                            // const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    currency.code,
                                                    style: Theme.of(context).typography.small.copyWith(
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  Text(
                                                    currency.name,
                                                    style: Theme.of(context).typography.xSmall,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ).call,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Wallet Type
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wallet Type',
                        style: Theme.of(context).typography.small,
                      ),
                      const SizedBox(height: 8),
                      SelectableGroup(
                        initialValue: _selectedWalletType,
                        options: WalletType.values.map((type) {
                          return SelectableGroupOption(
                            value: type,
                            widget: Row(
                              children: [
                                HugeIcon(
                                  icon: FinanceConstants.getWalletTypeIcon(
                                    type,
                                  ),
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  FinanceConstants.getWalletTypeName(type),
                                  style: Theme.of(context).typography.small,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (WalletType v) {
                          setState(() {
                            _selectedWalletType = v;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Active Toggle
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active',
                              style: Theme.of(context).typography.small
                                  .copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Inactive wallets won\'t show in transactions',
                              style: Theme.of(context).typography.small
                                  .copyWith(color: colorScheme.mutedForeground),
                            ),
                          ],
                        ),
                      ),
                      Checkbox(
                        state: _isActive
                            ? CheckboxState.checked
                            : CheckboxState.unchecked,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value == CheckboxState.checked;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      onPressed: !isSubmitting
                          ? () => _handleFormSubmit(outerContext)
                          : null,
                      child: isSubmitting
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Creating...'),
                              ],
                            )
                          : const Text('Create Wallet'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
