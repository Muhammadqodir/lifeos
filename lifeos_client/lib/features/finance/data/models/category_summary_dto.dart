import 'package:equatable/equatable.dart';

/// Summary of transactions grouped by category
class CategorySummaryDto extends Equatable {
  final int categoryId;
  final String categoryTitle;
  final String categoryIcon;
  final String categoryColor;
  final String totalAmount;
  final int transactionCount;

  const CategorySummaryDto({
    required this.categoryId,
    required this.categoryTitle,
    required this.categoryIcon,
    required this.categoryColor,
    required this.totalAmount,
    required this.transactionCount,
  });

  factory CategorySummaryDto.fromJson(Map<String, dynamic> json) {
    return CategorySummaryDto(
      categoryId: json['category_id'] as int,
      categoryTitle: json['category_title'] as String,
      categoryIcon: json['category_icon'] as String,
      categoryColor: json['category_color'] as String,
      totalAmount: json['total_amount'] as String,
      transactionCount: json['transaction_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'category_title': categoryTitle,
      'category_icon': categoryIcon,
      'category_color': categoryColor,
      'total_amount': totalAmount,
      'transaction_count': transactionCount,
    };
  }

  @override
  List<Object?> get props => [
        categoryId,
        categoryTitle,
        categoryIcon,
        categoryColor,
        totalAmount,
        transactionCount,
      ];
}
