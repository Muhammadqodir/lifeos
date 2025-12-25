import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
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

  var searchValue = '';
  
  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
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
          child: ShadSelect<int>.withSearch(

            onSearchChanged: (value) => setState(() => searchValue = value),
            searchPlaceholder: const Text('Category'),
            placeholder: const Text('Select category'),
            options: widget.categories.map((category) {
              return ShadOption(
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
            selectedOptionBuilder: (context, value) {
              final category = widget.categories.firstWhere((c) => c.id == value);
              return Row(
                children: [
                  Text(category.icon),
                  const SizedBox(width: 8),
                  Text(category.title),
                ],
              );
            },
            onChanged: widget.onChanged,
            initialValue: widget.selectedCategoryId,
          ),
        ),
      ],
    );
  }
}
