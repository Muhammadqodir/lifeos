import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../data/models/transaction_category_dto.dart';

class CategorySelector extends StatefulWidget {
  final List<TransactionCategoryDto> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onChanged;

  const CategorySelector({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onChanged,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  int? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.categories.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.muted,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'No categories available',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.mutedForeground,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.foreground,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: Select<int?>(
            itemBuilder: (context, item) {
              if (item == null) return const Text('Select category');
              final category = widget.categories.firstWhere((c) => c.id == item);
              return Row(
                children: [
                  Text(category.icon),
                  const SizedBox(width: 8),
                  Text(category.title),
                ],
              );
            },
            onChanged: (value) {
              setState(() {
                _selectedValue = value;
              });
              widget.onChanged(value);
            },
            value: _selectedValue,
            placeholder: const Text('Select category'),
            popup: SelectPopup(
              items: SelectItemList(
                children: widget.categories.map((category) {
                  return SelectItemButton(
                    value: category.id,
                    child: Row(
                      children: [
                        Text(category.icon),
                        const SizedBox(width: 8),
                        Text(category.title),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
