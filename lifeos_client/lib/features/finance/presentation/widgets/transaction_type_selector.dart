import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/core/ui/ui.dart';
import 'package:lifeos_client/core/widgets/selectable_group.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../data/models/transaction_dto.dart';

class TransactionTypeSelector extends StatelessWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onChanged;

  const TransactionTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {

    Widget option(String label, List<List<dynamic>> icon) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        HugeIcon(icon: icon),
        const SizedBox(width: AppSpacing.xs + 2),
        Flexible(child: Text(label)),
      ],
    );

    return AppFormField(
      label: 'Type',
      child: SelectableGroup<TransactionType>(
        value: selectedType,
        initialValue: selectedType,
        options: [
          SelectableGroupOption(
            value: TransactionType.expense,
            widget: option('Expense', HugeIcons.strokeRoundedArrowUpRight01),
          ),
          SelectableGroupOption(
            value: TransactionType.income,
            widget: option('Income', HugeIcons.strokeRoundedArrowDownLeft01),
          ),
          SelectableGroupOption(
            value: TransactionType.transfer,
            widget: option(
              'Transfer',
              HugeIcons.strokeRoundedArrowDataTransferHorizontal,
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
