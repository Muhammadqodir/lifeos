import 'package:equatable/equatable.dart';

class CurrencyDto extends Equatable {
  final int id;
  final int? userId;
  final String code;
  final String name;
  final String color;
  final String icon;
  final bool? isActive;
  final DateTime? createdAt;
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
