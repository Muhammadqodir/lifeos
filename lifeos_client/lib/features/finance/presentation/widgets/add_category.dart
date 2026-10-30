
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/core/widgets/color_selector.dart';
import 'package:lifeos_client/core/widgets/selectable_group.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:lifeos_client/core/ui/ui.dart';
import 'package:lifeos_client/core/utils/color_utils.dart';
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

  void _submit() {
    if (nameController.text.trim().isEmpty) {
      AppToast.error(context, 'Check the form', message: 'Enter a category name.');
      return;
    }
    Navigator.of(context).pop();
    widget.bloc.add(
      FinanceSettingsAddCategory(
        title: nameController.text.trim(),
        type: selectedType,
        icon: selectedIcon,
        color: selectedColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormSheet(
      title: 'New category',
      description: 'Group transactions so analytics stay meaningful.',
      leading: LeadingTile.emoji(
        selectedIcon.isEmpty ? '📦' : selectedIcon,
        color: parseHexColor(selectedColor),
        size: 44,
      ),
      submit: FormSubmitButton(label: 'Create category', onPressed: _submit),
      children: [
        AppFormField(
          label: 'Name',
          child: TextField(
            controller: nameController,
            placeholder: const Text('Groceries'),
            onSubmitted: (_) => _submit(),
          ),
        ),
        AppFormField(
          label: 'Type',
          child: SelectableGroup<String>(
            initialValue: selectedType,
            options: const [
              SelectableGroupOption(
                value: 'expense',
                widget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HugeIcon(icon: HugeIcons.strokeRoundedArrowUpRight01),
                    SizedBox(width: AppSpacing.xs + 2),
                    Text('Expense'),
                  ],
                ),
              ),
              SelectableGroupOption(
                value: 'income',
                widget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HugeIcon(icon: HugeIcons.strokeRoundedArrowDownLeft01),
                    SizedBox(width: AppSpacing.xs + 2),
                    Text('Income'),
                  ],
                ),
              ),
            ],
            onChanged: (value) => setState(() => selectedType = value),
          ),
        ),
        AppFormField(
          label: 'Emoji',
          child: TextField(
            initialValue: selectedIcon,
            maxLength: 2,
            placeholder: const Text('🛒'),
            onChanged: (value) => setState(() => selectedIcon = value),
          ),
        ),
        AppFormField(
          label: 'Colour',
          child: ColorSelector(
            initialColor: selectedColor,
            onChanged: (value) => setState(() => selectedColor = value),
          ),
        ),
      ],
    );
  }
}
