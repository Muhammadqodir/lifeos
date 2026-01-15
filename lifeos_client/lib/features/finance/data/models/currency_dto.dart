import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'currency_dto.g.dart';

@HiveType(typeId: 0)
class CurrencyDto extends Equatable {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final int? userId;
  
  @HiveField(2)
  final String code;
  
  @HiveField(3)
  final String name;
  
  @HiveField(4)
  final String color;
  
  @HiveField(5)
  final String icon;
  
  @HiveField(6)
  final bool? isActive;
  
  @HiveField(7)
  final DateTime? createdAt;
  
  @HiveField(8)
  final DateTime? updatedAt;

  const CurrencyDto({
    required this.id,
    this.userId,
    required this.code,
    required this.name,
    required this.color,
    required this.icon,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory CurrencyDto.fromJson(Map<String, dynamic> json) {
    return CurrencyDto(
      id: json['id'] as int,
      userId: json['user_id'] as int?,
      code: json['code'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      icon: json['icon'] as String,
      isActive: json['is_active'] as bool?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'code': code,
      'name': name,
      'color': color,
      'icon': icon,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        code,
        name,
        color,
        icon,
        isActive,
        createdAt,
        updatedAt,
      ];
}
