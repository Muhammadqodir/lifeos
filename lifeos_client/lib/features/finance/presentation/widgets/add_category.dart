
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/core/widgets/color_selector.dart';
import 'package:lifeos_client/core/widgets/selectable_group.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../bloc/finance_settings_bloc.dart';
import '../bloc/finance_settings_event.dart';

class AddCategorySheet extends StatefulWidget {
  final FinanceSettingsBloc bloc;

  const AddCategorySheet({super.key, required this.bloc});

  @override
  State<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {
  final nameController = TextEditingController();
  String selectedIcon = '📦';
  String selectedColor = 'FF6B7280';
  String selectedType = 'expense';

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
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
              style: theme.typography.large.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.foreground,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Category Name:',
              style: theme.typography.small.copyWith(
                color: colorScheme.foreground,
              ),
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
              style: theme.typography.small.copyWith(
                color: colorScheme.foreground,
              ),
            ),
            const SizedBox(height: 8),
            SelectableGroup<String>(
              initialValue: selectedType,
              options: [
                SelectableGroupOption(
                  value: 'expense',
                  widget: Row(
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowDown01,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Expense',
                        style: theme.typography.small
                      ),
                    ],
                  ),
                ),
                SelectableGroupOption(
                  value: 'income',
                  widget: Row(
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowUp01,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Income',
                        style: theme.typography.small
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
              style: theme.typography.small.copyWith(
                color: colorScheme.foreground,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              initialValue: selectedIcon,
              maxLength: 1,
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
              placeholder: const Text('Enter emoji'),
              onChanged: (value) {
                setState(() {
                  selectedIcon = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Color:',
              style: theme.typography.small.copyWith(
                color: colorScheme.foreground,
              ),
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
                    Navigator.of(context).pop();
                    widget.bloc.add(
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
                  style: theme.typography.small,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}