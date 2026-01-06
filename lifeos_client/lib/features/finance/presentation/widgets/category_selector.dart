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
  void didUpdateWidget(CategorySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset selection if the selected category is not in the new list
    if (_selectedValue != null && 
        !widget.categories.any((c) => c.id == _selectedValue)) {
      setState(() {
        _selectedValue = null;
      });
      widget.onChanged(null);
    }
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
            style: Theme.of(context).typography.small.copyWith(
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
              style: Theme.of(context).typography.xSmall,
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
          style: Theme.of(context).typography.small.copyWith(
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
              try {
                final category = widget.categories.firstWhere(
                  (c) => c.id == item,
                  orElse: () => throw StateError('Category not found'),
                );
                return Row(
                  children: [
                    Text(category.icon),
                    const SizedBox(width: 8),
                    Text(category.title),
                  ],
                );
              } catch (e) {
                // Category not in current list (e.g., after type switch)
                return const Text('Select category');
              }
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
            ).call,
          ),
        ),
      ],
    );
  }
}
