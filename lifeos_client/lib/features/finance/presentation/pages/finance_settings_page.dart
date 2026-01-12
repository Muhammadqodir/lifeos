import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/core/widgets/category_icon.dart';
import 'package:lifeos_client/utils/dialogs.dart';
import 'package:lifeos_client/utils/modal.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../injection.dart';
import '../../../../utils/toast.dart';
import '../../../navigation/presentation/widgets/custom_app_bar.dart';
import '../bloc/finance_settings_bloc.dart';
import '../bloc/finance_settings_event.dart';
import '../bloc/finance_settings_state.dart';
import '../../data/models/transaction_category_dto.dart';
import '../../../../core/widgets/selectable_group.dart';
import '../../../../core/widgets/color_selector.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<FinanceSettingsBloc, FinanceSettingsState>(
      listener: (context, state) {
        if (state is FinanceSettingsOperationSuccess) {
          showToast(
            context: context,
            builder: (ctx, overlay) {
              return Utils.buildToast(ctx, overlay, 'Success', state.message);
            },
            location: ToastLocation.topCenter,
          );
        } else if (state is FinanceSettingsError) {
          showToast(
            context: context,
            builder: (ctx, overlay) {
              return Utils.buildToast(ctx, overlay, 'Error', state.message);
            },
            location: ToastLocation.topCenter,
          );
        }
      },
      child: Scaffold(
        headers: [
          CustomAppBar(
            title: 'Finance Settings',
            leftActions: [
              AppBarAction(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                tooltip: 'Back',
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
        child: BlocBuilder<FinanceSettingsBloc, FinanceSettingsState>(
          builder: (context, state) {
            if (state is FinanceSettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is FinanceSettingsError) {
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
                      'Failed to load settings',
                      style: theme.typography.normal.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.foreground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        state.message,
                        style: theme.typography.small.copyWith(
                          color: colorScheme.mutedForeground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      onPressed: () {
                        context.read<FinanceSettingsBloc>().add(
                          const FinanceSettingsLoadData(),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is FinanceSettingsLoaded ||
                state is FinanceSettingsOperationSuccess) {
              final loadedState = state is FinanceSettingsLoaded
                  ? state
                  : (state as FinanceSettingsOperationSuccess).previousState;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDefaultCurrencySection(context, loadedState),
                    const SizedBox(height: 12),
                    _buildCategoriesSection(context, loadedState),
                    const SizedBox(height: 24),
                  ],
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
    return SettingsSection(
      title: 'Default Currency',
      subTitle: 'Set your preferred currency',
      icon: HugeIcon(icon: HugeIcons.strokeRoundedMoneyExchange02),
      content: SizedBox(
        width: double.infinity,
        child: Select<int>(
          value: state.defaultCurrencyId,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          itemBuilder: (context, item) {
            final currency = state.userCurrencies.firstWhere(
              (c) => c.id == item,
            );
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text(currency.icon, style: Theme.of(context).typography.small),
                // const SizedBox(width: 12),
                Text(
                  currency.name,
                  style: Theme.of(
                    context,
                  ).typography.small.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
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
              children: state.userCurrencies
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
                                  style: Theme.of(context).typography.small
                                      .copyWith(fontWeight: FontWeight.w600),
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
    );
  }


  Widget _buildCategoriesSection(
    BuildContext context,
    FinanceSettingsLoaded state,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final expenseCategories = state.categories
        .where((c) => c.type == TransactionCategoryType.expense)
        .toList();
    final incomeCategories = state.categories
        .where((c) => c.type == TransactionCategoryType.income)
        .toList();

    return SettingsSection(
      title: "Categories",
      subTitle: "Organize your transactions",
      icon: HugeIcon(
        icon: HugeIcons.strokeRoundedFolderLibrary,
        size: 32,
        color: colorScheme.primary,
      ),
      trailing: IconButton.primary(
        onPressed: () => _showAddCategoryDialog(context),
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedAdd01,
          strokeWidth: 3,
          size: 16,
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Expense Categories',
            style: theme.typography.xSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.foreground,
            ),
          ),
          const SizedBox(height: 8),
          _buildCategoryList(context, expenseCategories, state),

          const SizedBox(height: 16),

          // Income Categories
          Text(
            'Income Categories',
            style: theme.typography.xSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.foreground,
            ),
          ),
          const SizedBox(height: 8),
          _buildCategoryList(context, incomeCategories, state),
        ],
      ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    List<TransactionCategoryDto> categories,
    FinanceSettingsLoaded state,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Text(
            'No categories added yet',
            style: theme.typography.xSmall.copyWith(
              color: colorScheme.mutedForeground,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: colorScheme.border),
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSystemCategory = category.userId == null;

        return GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
            child: Row(
              children: [
                CategoryIcon(icon: category.icon, color: category.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.title,
                    style: theme.typography.small.copyWith(
                      color: colorScheme.foreground,
                    ),
                  ),
                ),
                isSystemCategory
                    ? SecondaryBadge(
                        child: Text(
                          'System',
                          style: theme.typography.xSmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : IconButton.ghost(
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedDelete02,
                          size: 20,
                          color: colorScheme.destructive,
                        ),
                        onPressed: () =>
                            _confirmRemoveCategory(context, category),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    String selectedIcon = '📦';
    String selectedColor = 'FF6B7280';

    // Capture the bloc before showing the dialog
    final bloc = context.read<FinanceSettingsBloc>();

    BottomSheetModal.openSheet(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          String selectedType = 'expense';

          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Category',
                    style: Theme.of(
                      context,
                    ).typography.large.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Category Name:',
                    style: Theme.of(dialogContext).typography.small,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    placeholder: const Text('Category name'),
                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Type:',
                    style: Theme.of(dialogContext).typography.small,
                  ),
                  const SizedBox(height: 8),
                  SelectableGroup<String>(
                    initialValue: selectedType,
                    options: [
                      SelectableGroupOption(
                        value: 'expense',
                        widget: Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowDown01,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Expense',
                              style: Theme.of(dialogContext).typography.small,
                            ),
                          ],
                        ),
                      ),
                      SelectableGroupOption(
                        value: 'income',
                        widget: Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowUp01,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Income',
                              style: Theme.of(dialogContext).typography.small,
                            ),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Icon (emoji):',
                    style: Theme.of(dialogContext).typography.small,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    initialValue: selectedIcon,
                    maxLength: 1,
                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    placeholder: const Text('Enter emoji'),
                    onChanged: (value) => selectedIcon = value,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Color:',
                    style: Theme.of(dialogContext).typography.small,
                  ),
                  const SizedBox(height: 8),
                  ColorSelector(
                    initialColor: selectedColor,
                    onChanged: (value) {
                      setState(() {
                        selectedColor = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty) {
                          Navigator.of(dialogContext).pop();
                          bloc.add(
                            FinanceSettingsAddCategory(
                              title: nameController.text,
                              type: selectedType,
                              icon: selectedIcon,
                              color: selectedColor,
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Add',
                        style: Theme.of(dialogContext).typography.small,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmRemoveCategory(
    BuildContext context,
    TransactionCategoryDto category,
  ) async {
    bool? confirmed = await Dialogs.showConfirmDialog(
      title: 'Remove Category',
      message: 'Are you sure you want to remove "${category.title}" category?',
      context: context,
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

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.subTitle,
    required this.icon,
    required this.content,
    this.trailing,
  });

  final String title;
  final String subTitle;
  final HugeIcon icon;
  final Widget content;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HugeIcon(
                icon: icon.icon,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).typography.small.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.foreground,
                      ),
                    ),
                    Text(
                      subTitle,
                      style: Theme.of(context).typography.xSmall.copyWith(
                        color: Theme.of(context).colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}
