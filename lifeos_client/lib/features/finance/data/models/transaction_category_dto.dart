import 'package:equatable/equatable.dart';

enum TransactionCategoryType {
  income,
  expense;

  String toJson() {
    switch (this) {
      case TransactionCategoryType.income:
        return 'income';
      case TransactionCategoryType.expense:
        return 'expense';
    }
  }

  static TransactionCategoryType fromJson(String value) {
    switch (value) {
      case 'income':
        return TransactionCategoryType.income;
      case 'expense':
        return TransactionCategoryType.expense;
      default:
        return TransactionCategoryType.expense;
    }
  }
}

class TransactionCategoryDto extends Equatable {
  final int id;
  final int? userId;
  final String title;
  final String icon;
  final String color;
  final TransactionCategoryType type;
  final bool isSystem;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionCategoryDto({
    required this.id,
    this.userId,
    required this.title,
    required this.icon,
    required this.color,
    required this.type,
    required this.isSystem,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionCategoryDto.fromJson(Map<String, dynamic> json) {
    return TransactionCategoryDto(
      id: json['id'] as int,
      userId: json['user_id'] as int?,
      title: json['title'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      type: TransactionCategoryType.fromJson(json['type'] as String),
      isSystem: json['is_system'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'icon': icon,
      'color': color,
      'type': type.toJson(),
      'is_system': isSystem,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        icon,
        color,
        type,
        isSystem,
        createdAt,
        updatedAt,
      ];
}
