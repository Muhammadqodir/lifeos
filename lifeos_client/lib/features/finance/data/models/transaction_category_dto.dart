import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'transaction_category_dto.g.dart';

@HiveType(typeId: 3)
enum TransactionCategoryType {
  @HiveField(0)
  income,
  
  @HiveField(1)
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

@HiveType(typeId: 4)
class TransactionCategoryDto extends Equatable {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final int? userId;
  
  @HiveField(2)
  final String title;
  
  @HiveField(3)
  final String icon;
  
  @HiveField(4)
  final String color;
  
  @HiveField(5)
  final TransactionCategoryType type;
  
  @HiveField(6)
  final bool isSystem;
  
  @HiveField(7)
  final DateTime createdAt;
  
  @HiveField(8)
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
