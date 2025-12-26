import 'package:lifeos_client/utils/toast.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../injection.dart';
import '../../../navigation/presentation/widgets/custom_app_bar.dart';
import '../../data/models/transaction_dto.dart';
import '../bloc/add_transaction_bloc.dart';
import '../bloc/add_transaction_event.dart';
import '../bloc/add_transaction_state.dart';
import '../widgets/transaction_type_selector.dart';
import '../widgets/wallet_selector.dart';
import '../widgets/amount_input_field.dart';
import '../widgets/category_selector.dart';

class AddTransactionPage extends StatelessWidget {
  const AddTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<AddTransactionBloc>()..add(const AddTransactionLoadData()),
      child: const _AddTransactionPageContent(),
    );
  }
}

class _AddTransactionPageContent extends StatelessWidget {
  const _AddTransactionPageContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<AddTransactionBloc, AddTransactionState>(
      listener: (context, state) {
        if (state is AddTransactionSuccess) {
          showToast(
            context: context,
            builder: (context, overlay) {
              return Utils.buildToast(
                context,
                overlay,
                'Success',
                'Transaction created successfully',
              );
            },
            location: ToastLocation.bottomCenter,
          );
          Navigator.of(context).pop(true);
        } else if (state is AddTransactionError) {
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
            title: 'Add Transaction',
            leftActions: [
              AppBarAction(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                tooltip: 'Back',
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
        child: BlocBuilder<AddTransactionBloc, AddTransactionState>(
          builder: (context, state) {
            if (state is AddTransactionLoadingData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AddTransactionLoadError) {
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
                      'Failed to load data',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.foreground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        state.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.mutedForeground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      onPressed: () {
                        context.read<AddTransactionBloc>().add(
                          const AddTransactionLoadData(),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is AddTransactionReady ||
                state is AddTransactionSubmitting) {
              final readyState = state is AddTransactionReady
                  ? state
                  : (state as AddTransactionSubmitting);

              // For submitting state, we need to get the last ready state
              // Let's assume submitting keeps the form data visible
              return _buildForm(
                context,
                readyState is AddTransactionReady ? readyState : null,
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, AddTransactionReady? state) {
    if (state == null) {
      return const Center(child: CircularProgressIndicator());
    }
    DateTime _value = state.occurredAt;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSubmitting =
        context.read<AddTransactionBloc>().state is AddTransactionSubmitting;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Transaction Type Selector
                TransactionTypeSelector(
                  selectedType: state.type,
                  onChanged: (type) {
                    context.read<AddTransactionBloc>().add(
                      AddTransactionTypeChanged(type),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Dynamic form based on transaction type
                _buildTypeSpecificFields(context, state),

                const SizedBox(height: 20),

                // Category (only for income/expense)
                if (state.type == TransactionType.income ||
                    state.type == TransactionType.expense) ...[
                  CategorySelector(
                    categories: state.type == TransactionType.income
                        ? state.incomeCategories
                        : state.expenseCategories,
                    selectedCategoryId: state.categoryId,
                    onChanged: (categoryId) {
                      context.read<AddTransactionBloc>().add(
                        AddTransactionCategoryChanged(categoryId),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                // Description
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description (optional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.foreground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      initialValue: state.description,
                      placeholder: const Text('Add a note...'),
                      maxLines: 3,
                      onChanged: (value) {
                        context.read<AddTransactionBloc>().add(
                          AddTransactionDescriptionChanged(value),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Date/Time
                DatePicker(
                  value: _value,
                  mode: PromptMode.dialog,
                  // Title shown at the top of the dialog variant.
                  dialogTitle: const Text('Select Date'),
                  stateBuilder: (date) {
                    if (date.isAfter(DateTime.now())) {
                      return DateState.disabled;
                    }
                    return DateState.enabled;
                  },
                  onChanged: (value) {
                    context.read<AddTransactionBloc>().add(
                      AddTransactionOccurredAtChanged(value!),
                    );
                  },
                ),

                const SizedBox(height: 150), // Space for bottom button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PrimaryButton(
                    onPressed: state.isValid && !isSubmitting
                        ? () {
                            context.read<AddTransactionBloc>().add(
                              const AddTransactionSubmitted(),
                            );
                          }
                        : null,
                    child: isSubmitting
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Creating...'),
                            ],
                          )
                        : const Text('Create Transaction'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSpecificFields(
    BuildContext context,
    AddTransactionReady state,
  ) {
    switch (state.type) {
      case TransactionType.income:
      case TransactionType.expense:
        return Column(
          children: [
            WalletSelector(
              label: 'Wallet',
              wallets: state.wallets,
              selectedWalletId: state.walletId,
              onChanged: (walletId) {
                if (walletId != null) {
                  context.read<AddTransactionBloc>().add(
                    AddTransactionWalletChanged(walletId),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            AmountInputField(
              label: 'Amount',
              value: state.amount,
              onChanged: (amount) {
                context.read<AddTransactionBloc>().add(
                  AddTransactionAmountChanged(amount),
                );
              },
              placeholder: '0.00',
            ),
          ],
        );

      case TransactionType.transfer:
        return Column(
          children: [
            WalletSelector(
              label: 'From Wallet',
              wallets: state.wallets,
              selectedWalletId: state.fromWalletId,
              onChanged: (walletId) {
                if (walletId != null) {
                  context.read<AddTransactionBloc>().add(
                    AddTransactionFromWalletChanged(walletId),
                  );
                }
              },
              placeholder: 'Select source wallet',
            ),
            const SizedBox(height: 16),
            WalletSelector(
              label: 'To Wallet',
              wallets: state.wallets,
              selectedWalletId: state.toWalletId,
              onChanged: (walletId) {
                if (walletId != null) {
                  context.read<AddTransactionBloc>().add(
                    AddTransactionToWalletChanged(walletId),
                  );
                }
              },
              placeholder: 'Select destination wallet',
            ),
            const SizedBox(height: 16),
            AmountInputField(
              label: 'Amount',
              value: state.amount,
              onChanged: (amount) {
                context.read<AddTransactionBloc>().add(
                  AddTransactionAmountChanged(amount),
                );
              },
              placeholder: '0.00',
            ),
          ],
        );

      case TransactionType.exchange:
        return Column(
          children: [
            WalletSelector(
              label: 'From Wallet',
              wallets: state.wallets,
              selectedWalletId: state.fromWalletId,
              onChanged: (walletId) {
                if (walletId != null) {
                  context.read<AddTransactionBloc>().add(
                    AddTransactionFromWalletChanged(walletId),
                  );
                }
              },
              placeholder: 'Select source currency',
            ),
            const SizedBox(height: 16),
            AmountInputField(
              label: 'From Amount',
              value: state.fromAmount,
              onChanged: (amount) {
                context.read<AddTransactionBloc>().add(
                  AddTransactionFromAmountChanged(amount),
                );
              },
              placeholder: '0.00',
            ),
            const SizedBox(height: 16),
            WalletSelector(
              label: 'To Wallet',
              wallets: state.wallets,
              selectedWalletId: state.toWalletId,
              onChanged: (walletId) {
                if (walletId != null) {
                  context.read<AddTransactionBloc>().add(
                    AddTransactionToWalletChanged(walletId),
                  );
                }
              },
              placeholder: 'Select destination currency',
            ),
            const SizedBox(height: 16),
            AmountInputField(
              label: 'To Amount',
              value: state.toAmount,
              onChanged: (amount) {
                context.read<AddTransactionBloc>().add(
                  AddTransactionToAmountChanged(amount),
                );
              },
              placeholder: '0.00',
            ),
            const SizedBox(height: 16),
            AmountInputField(
              label: 'Exchange Rate',
              value: state.rate ?? '',
              onChanged: (rate) {
                context.read<AddTransactionBloc>().add(
                  AddTransactionRateChanged(rate),
                );
              },
              placeholder: '1.0',
            ),
          ],
        );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (date == today) {
      dateStr = 'Today';
    } else if (date == yesterday) {
      dateStr = 'Yesterday';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$dateStr at $hour:$minute';
  }
}
