import 'package:lifeos_client/core/widgets/selectable_group.dart';
import 'package:lifeos_client/features/finance/data/datasources/constants.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../injection.dart';
import '../../data/models/wallet_dto.dart';
import '../bloc/add_wallet_bloc.dart';
import '../bloc/add_wallet_event.dart';
import '../bloc/add_wallet_state.dart';
import 'package:lifeos_client/core/ui/ui.dart';

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
      AppToast.error(
        context,
        'Check the form',
        message: 'Enter a wallet name.',
      );
      return;
    }

    // Validate currency selection
    if (_selectedCurrencyId == null) {
      AppToast.error(context, 'Check the form', message: 'Choose a currency.');
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
    final outerContext = context;

    return BlocListener<AddWalletBloc, AddWalletState>(
      listener: (context, state) {
        if (state is AddWalletSuccess) {
          AppToast.success(context, 'Wallet created');
          Navigator.of(context).pop(true);
        } else if (state is AddWalletError) {
          AppToast.error(
            context,
            'Something went wrong',
            message: state.message,
          );
          Navigator.of(context).pop(false);
        }
      },
      child: Scaffold(
        headers: [AppHeader(title: 'New wallet')],
        child: BlocBuilder<AddWalletBloc, AddWalletState>(
          builder: (context, state) {
            if (state is AddWalletLoadingCurrencies) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AddWalletCurrenciesError) {
              return ErrorState(
                title: "Couldn't load currencies",
                message: state.message,
                onRetry: () => context.read<AddWalletBloc>().add(
                  const AddWalletLoadCurrencies(),
                ),
              );
            }

            final currencies = state is AddWalletReady ? state.currencies : [];
            final isSubmitting = state is AddWalletSubmitting;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.page,
                vertical: AppSpacing.lg,
              ),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: ContentWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppFormField(
                      label: 'Name',
                      child: TextField(
                        initialValue: _walletName,
                        placeholder: const Text('Main card'),
                        onSubmitted: (_) => FocusScope.of(context).unfocus(),
                        onChanged: (value) =>
                            setState(() => _walletName = value),
                      ),
                    ),
                    AppFormField(
                      label: 'Type',
                      child: SelectableGroup<WalletType>(
                        scrollable: true,
                        initialValue: _selectedWalletType,
                        options: [
                          for (final type in WalletType.values)
                            SelectableGroupOption(
                              value: type,
                              widget: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  HugeIcon(
                                    icon: FinanceConstants.getWalletTypeIcon(
                                      type,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs + 2),
                                  Flexible(
                                    child: Text(
                                      FinanceConstants.getWalletTypeName(type),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                        onChanged: (type) =>
                            setState(() => _selectedWalletType = type),
                      ),
                    ),
                    AppFormField(
                      label: 'Currency',
                      child: currencies.isEmpty
                          ? Text(
                              'No currencies available',
                              style: context.text.itemSubtitle,
                            )
                          : Select<int>(
                              placeholder: const Text('Choose currency'),
                              value: _selectedCurrencyId,
                              itemBuilder: (context, item) {
                                final currency = currencies.firstWhere(
                                  (c) => c.id == item,
                                );
                                return Text(
                                  '${currency.code} · ${currency.name}',
                                );
                              },
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedCurrencyId = value);
                                }
                              },
                              popup: SelectPopup(
                                items: SelectItemList(
                                  children: [
                                    for (final currency in currencies)
                                      SelectItemButton<int>(
                                        value: currency.id,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              currency.code,
                                              style: context.text.label,
                                            ),
                                            Text(
                                              currency.name,
                                              style: context.text.caption,
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ).call,
                            ),
                    ),
                    AppListSection(
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      dividerIndent: AppSpacing.md,
                      children: [
                        AppListTile(
                          title: 'Active',
                          subtitle: "Inactive wallets don't appear when adding transactions",
                          onTap: () => setState(() => _isActive = !_isActive),
                          trailing: Switch(
                            value: _isActive,
                            onChanged: (value) =>
                                setState(() => _isActive = value),
                          ),
                        ),
                      ],
                    ),
                    FormSubmitButton(
                      label: 'Create wallet',
                      loadingLabel: 'Creating…',
                      loading: isSubmitting,
                      onPressed: () => _handleFormSubmit(outerContext),
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
}
