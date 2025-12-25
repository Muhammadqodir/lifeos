import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
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
  final _formKey = GlobalKey<ShadFormState>();
  final _nameController = TextEditingController();

  int? _selectedCurrencyId;
  WalletType _selectedWalletType = WalletType.cash;
  bool _isActive = true;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.saveAndValidate()) {
      if (_selectedCurrencyId == null) {
        ShadToaster.of(context).show(
          const ShadToast.destructive(
            title: Text('Validation Error'),
            description: Text('Please select a currency'),
          ),
        );
        return;
      }

      context.read<AddWalletBloc>().add(
        AddWalletSubmitted(
          name: _nameController.text,
          currencyId: _selectedCurrencyId!,
          type: _selectedWalletType.toJson(),
          isActive: _isActive,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<AddWalletBloc, AddWalletState>(
      listener: (context, state) {
        if (state is AddWalletSuccess) {
          ShadToaster.of(context).show(
            const ShadToast(
              title: Text('Success'),
              description: Text('Wallet created successfully'),
            ),
          );
          Navigator.of(context).pop(true); // Return true to indicate success
        } else if (state is AddWalletError) {
          ShadToaster.of(context).show(
            ShadToast.destructive(
              title: const Text('Error'),
              description: Text(state.message),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Add Wallet',
          leftActions: [
            AppBarAction(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              tooltip: 'Back',
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        body: BlocBuilder<AddWalletBloc, AddWalletState>(
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
                    ShadButton(
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

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: ShadForm(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ShadInputFormField(
                            id: 'name',
                            label: const Text('Wallet Name'),
                            controller: _nameController,
                            placeholder: const Text('e.g., My Cash Wallet'),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter a wallet name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Currency Selection
                          Text(
                            'Currency',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.foreground,
                            ),
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
                                style: TextStyle(
                                  color: colorScheme.mutedForeground,
                                ),
                              ),
                            )
                          else
                            Wrap(
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
                          const SizedBox(height: 20),

                          // Wallet Type
                          Text(
                            'Wallet Type',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.foreground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: WalletType.values.map((type) {
                              final isSelected = _selectedWalletType == type;
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
                          const SizedBox(height: 20),

                          // Active Toggle
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Active',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: colorScheme.foreground,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Inactive wallets won\'t show in transactions',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ShadSwitch(
                                value: _isActive,
                                onChanged: (value) {
                                  setState(() {
                                    _isActive = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SafeArea(
                    top: false,
                    child: BlocBuilder<AddWalletBloc, AddWalletState>(
                      builder: (context, state) {
                        final isSubmitting = state is AddWalletSubmitting;
                        return ShadButton(
                          onPressed: isSubmitting ? null : _handleSubmit,
                          width: double.infinity,
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Create Wallet'),
                        );
                      },
                    ),
                  ),
                ),
              ],
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
    final theme = ShadTheme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
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
    final theme = ShadTheme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
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
