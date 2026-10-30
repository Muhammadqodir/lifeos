import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/core/widgets/category_icon.dart';
import 'package:lifeos_client/features/finance/presentation/widgets/add_category.dart';
import 'package:lifeos_client/utils/dialogs.dart';
import 'package:lifeos_client/utils/modal.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../injection.dart';
import '../bloc/finance_settings_bloc.dart';
import '../bloc/finance_settings_event.dart';
import '../bloc/finance_settings_state.dart';
import '../../data/models/transaction_category_dto.dart';
import 'package:lifeos_client/core/ui/ui.dart';

class FinanceSettingsPage extends StatelessWidget {
  const FinanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<FinanceSettingsBloc>()..add(const FinanceSettingsLoadData()),
      child: const _FinanceSettingsPageContent(),
    );
  }
}

class _FinanceSettingsPageContent extends StatelessWidget {
  const _FinanceSettingsPageContent();

  @override
  Widget build(BuildContext context) {
    return BlocListener<FinanceSettingsBloc, FinanceSettingsState>(
      listener: (context, state) {
        if (state is FinanceSettingsOperationSuccess) {
          AppToast.success(context, state.message);
        } else if (state is FinanceSettingsError) {
          AppToast.error(
            context,
            'Something went wrong',
            message: state.message,
          );
        }
      },
      child: Scaffold(
        headers: [AppHeader(title: 'Finance settings')],
        child: BlocBuilder<FinanceSettingsBloc, FinanceSettingsState>(
          builder: (context, state) {
            if (state is FinanceSettingsLoading) {
              return LoadingState(message: 'Loading settings...');
            }

            if (state is FinanceSettingsError) {
              return ErrorState(
                title: "Couldn't load settings",
                message: state.message,
                onRetry: () => context.read<FinanceSettingsBloc>().add(
                  const FinanceSettingsLoadData(),
                ),
              );
            }

            if (state is FinanceSettingsLoaded ||
                state is FinanceSettingsOperationSuccess) {
              final loadedState = state is FinanceSettingsLoaded
                  ? state
                  : (state as FinanceSettingsOperationSuccess).previousState;

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
                      _buildDefaultCurrencySection(context, loadedState),
                      ..._buildCategoriesSection(context, loadedState),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildDefaultCurrencySection(
    BuildContext context,
    FinanceSettingsLoaded state,
  ) {
    return AppListSection(
      title: 'Currency',
      footer: 'Totals and analytics are converted to this currency.',
      children: [
        AppListTile(
          leading: LeadingTile.icon(HugeIcons.strokeRoundedMoneyExchange02),
          title: 'Default currency',
          trailing: SizedBox(
            width: 180,
            child: Select<int>(
              value: state.defaultCurrencyId,
              itemBuilder: (context, item) {
                final currency = state.userCurrencies.firstWhere(
                  (c) => c.id == item,
                );
                return Text(
                  '${currency.code} · ${currency.name}',
                  overflow: TextOverflow.ellipsis,
                );
              },
              onChanged: (value) {
                if (value != null) {
                  context.read<FinanceSettingsBloc>().add(
                    FinanceSettingsUpdateDefaultCurrency(value),
                  );
                }
              },
              popup: SelectPopup(
                items: SelectItemList(
                  children: [
                    for (final currency in state.userCurrencies)
                      SelectItemButton<int>(
                        value: currency.id,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(currency.code, style: context.text.label),
                            Text(currency.name, style: context.text.caption),
                          ],
                        ),
                      ),
                  ],
                ),
              ).call,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCategoriesSection(
    BuildContext context,
    FinanceSettingsLoaded state,
  ) {
    final groups = [
      (
        'Expense categories',
        state.categories
            .where((c) => c.type == TransactionCategoryType.expense)
            .toList(),
      ),
      (
        'Income categories',
        state.categories
            .where((c) => c.type == TransactionCategoryType.income)
            .toList(),
      ),
    ];

    return [
      for (final (title, categories) in groups)
        AppListSection(
          title: title,
          count: categories.length,
          headerTrailing: GhostButton(
            size: ButtonSize.small,
            density: ButtonDensity.compact,
            leading: const HugeIcon(
              icon: HugeIcons.strokeRoundedAdd01,
              size: AppIconSize.sm,
            ),
            onPressed: () => _showAddCategoryDialog(context),
            child: const Text('Add'),
          ),
          empty: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'No categories yet',
              style: context.text.caption,
              textAlign: TextAlign.center,
            ),
          ),
          children: [
            for (final category in categories)
              AppListTile(
                leading: CategoryIcon(
                  icon: category.icon,
                  color: category.color,
                ),
                title: category.title,
                trailing: category.userId == null
                    ? const AppBadge.neutral(label: 'Built-in')
                    : null,
                actions: [
                  if (category.userId != null)
                    AppAction(
                      label: 'Delete category',
                      icon: HugeIcons.strokeRoundedDelete02,
                      destructive: true,
                      onSelected: () =>
                          _confirmRemoveCategory(context, category),
                    ),
                ],
              ),
          ],
        ),
    ];
  }

  void _showAddCategoryDialog(BuildContext context) {
    final bloc = context.read<FinanceSettingsBloc>();

    BottomSheetModal.openSheet(
      context: context,
      builder: (dialogContext) => AddCategorySheet(bloc: bloc),
    );
  }

  void _confirmRemoveCategory(
    BuildContext context,
    TransactionCategoryDto category,
  ) async {
    bool? confirmed = await Dialogs.showConfirmDialog(
      title: 'Delete category?',
      message:
          '"${category.title}" will be removed. Existing transactions keep their history.',
      context: context,
      confirmLabel: 'Delete',
      destructive: true,
    );

    if (confirmed == true) {
      if (context.mounted) {
        context.read<FinanceSettingsBloc>().add(
          FinanceSettingsRemoveCategory(category.id),
        );
      }
    }
  }
}
