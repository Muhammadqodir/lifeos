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
  // Form field keys using shadcn_flutter structure
  final _walletNameKey = const TextFieldKey(#walletName);
  final _currencyKey = const TextFieldKey(#currency);
  final _walletTypeKey = const TextFieldKey(#walletType);
  final _isActiveKey = const CheckboxKey(#isActive);

  CheckboxState _isActiveState = CheckboxState.checked;
  int? _selectedCurrencyId;
  WalletType _selectedWalletType = WalletType.cash;

  void _handleFormSubmit(BuildContext context, Map<FormKey, dynamic> values) {
    // Extract form values
    String? walletName = _walletNameKey[values];
    CheckboxState? isActive = _isActiveKey[values];

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
        location: ToastLocation.bottomCenter,
      );
      return;
    }

    // Submit to BLoC
    context.read<AddWalletBloc>().add(
      AddWalletSubmitted(
        name: walletName ?? '',
        currencyId: _selectedCurrencyId!,
        type: _selectedWalletType.toJson(),
        isActive: isActive == CheckboxState.checked,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
            location: ToastLocation.bottomCenter,
          );
          Navigator.of(context).pop(true); // Return true to indicate success
        } else if (state is AddWalletError) {
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.foreground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 14,
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

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                onSubmit: (context, values) => _handleFormSubmit(context, values),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Wallet Name Field
                          FormField(
                            key: _walletNameKey,
                            label: const Text('Wallet Name'),
                            hint: const Text('e.g., My Cash Wallet'),
                            validator: const LengthValidator(min: 1),
                            showErrors: const {
                              FormValidationMode.changed,
                              FormValidationMode.submitted
                            },
                            child: const TextField(),
                          ),
                          const Gap(24),

                          // Currency Selection
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Currency',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Gap(8),
                              if (currencies.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colorScheme.muted,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'No currencies available',
                                    style: TextStyle(
                                      color: colorScheme.mutedForeground,
                                    ),
                                  ),
                                )
                              else
                                FormField(
                                  key: _currencyKey,
                                  label: const Text('Select Currency'),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: currencies.map((currency) {
                                      final isSelected =
                                          _selectedCurrencyId == currency.id;
                                      return _CurrencyChip(
                                        currency: currency,
                                        isSelected: isSelected,
                                        onTap: () {
                                          setState(() {
                                            _selectedCurrencyId = currency.id;
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          ),
                          const Gap(24),

                          // Wallet Type
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Wallet Type',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Gap(8),
                              FormField(
                                key: _walletTypeKey,
                                label: const Text('Select Type'),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: WalletType.values.map((type) {
                                    final isSelected =
                                        _selectedWalletType == type;
                                    return _WalletTypeChip(
                                      type: type,
                                      isSelected: isSelected,
                                      onTap: () {
                                        setState(() {
                                          _selectedWalletType = type;
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                          const Gap(24),

                          // Active Toggle
                          FormInline(
                            key: _isActiveKey,
                            label: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Active',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  'Inactive wallets won\'t show in transactions',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                            showErrors: const {
                              FormValidationMode.changed,
                              FormValidationMode.submitted
                            },
                            child: Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Checkbox(
                                state: _isActiveState,
                                onChanged: (value) {
                                  setState(() {
                                    _isActiveState = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ).gap(24),
                      const Gap(24),

                      // Submit Button with Error Builder
                      BlocBuilder<AddWalletBloc, AddWalletState>(
                        builder: (context, state) {
                          final isSubmitting = state is AddWalletSubmitting;
                          return FormErrorBuilder(
                            builder: (context, errors, child) {
                              return SizedBox(
                                width: double.infinity,
                                child: PrimaryButton(
                                  onPressed: errors.isEmpty && !isSubmitting
                                      ? () => context.submitForm()
                                      : null,
                                  child: isSubmitting
                                      ? const SizedBox(
                                          height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Create Wallet'),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Currency selection chip
class _CurrencyChip extends StatelessWidget {
  final dynamic currency;
  final bool isSelected;
  final VoidCallback onTap;

  const _CurrencyChip({
    required this.currency,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.muted,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currency.icon,
              style: TextStyle(
                fontSize: 14,
                color: isSelected
                    ? colorScheme.primaryForeground
                    : colorScheme.foreground,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              currency.code,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? colorScheme.primaryForeground
                    : colorScheme.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Wallet type selection chip
class _WalletTypeChip extends StatelessWidget {
  final WalletType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _WalletTypeChip({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  String _getTypeName(WalletType type) {
    switch (type) {
      case WalletType.card:
        return 'Card';
      case WalletType.bankAccount:
        return 'Bank Account';
      case WalletType.cash:
        return 'Cash';
      case WalletType.other:
        return 'Other';
    }
  }

  dynamic _getTypeIcon(WalletType type) {
    switch (type) {
      case WalletType.card:
        return HugeIcons.strokeRoundedCreditCard;
      case WalletType.bankAccount:
        return HugeIcons.strokeRoundedBank;
      case WalletType.cash:
        return HugeIcons.strokeRoundedMoneyBag01;
      case WalletType.other:
        return HugeIcons.strokeRoundedWallet03;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.muted,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: _getTypeIcon(type),
              size: 20,
              color: isSelected
                  ? colorScheme.primaryForeground
                  : colorScheme.foreground,
            ),
            const SizedBox(width: 8),
            Text(
              _getTypeName(type),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? colorScheme.primaryForeground
                    : colorScheme.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
