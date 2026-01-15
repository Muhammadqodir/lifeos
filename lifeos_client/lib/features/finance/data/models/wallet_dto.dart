import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'currency_dto.dart';

part 'wallet_dto.g.dart';

@HiveType(typeId: 1)
enum WalletType {
  @HiveField(0)
  card,
  
  @HiveField(1)
  bankAccount,
  
  @HiveField(2)
  cash,
  
  @HiveField(3)
  other;

  String toJson() {
    switch (this) {
      case WalletType.card:
        return 'card';
      case WalletType.bankAccount:
        return 'bank_account';
      case WalletType.cash:
        return 'cash';
      case WalletType.other:
        return 'other';
    }
  }

  static WalletType fromJson(String value) {
    switch (value) {
      case 'card':
        return WalletType.card;
      case 'bank_account':
        return WalletType.bankAccount;
      case 'cash':
        return WalletType.cash;
      case 'other':
        return WalletType.other;
      default:
        return WalletType.other;
    }
  }
}

@HiveType(typeId: 2)
class WalletDto extends Equatable {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final int userId;
  
  @HiveField(2)
  final String name;
  
  @HiveField(3)
  final int currencyId;
  
  @HiveField(4)
  final CurrencyDto currency;
  
  @HiveField(5)
  final WalletType type;
  
  @HiveField(6)
  final bool isActive;
  
  @HiveField(7)
  final double? balance; // Coming from balance endpoint
  
  @HiveField(8)
  final DateTime createdAt;
  
  @HiveField(9)
  final DateTime updatedAt;

  const WalletDto({
    required this.id,
    required this.userId,
    required this.name,
    required this.currencyId,
    required this.currency,
    required this.type,
    required this.isActive,
    this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletDto.fromJson(Map<String, dynamic> json) {
    return WalletDto(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      currencyId: json['currency_id'] as int,
      currency: CurrencyDto.fromJson(json['currency'] as Map<String, dynamic>),
      type: WalletType.fromJson(json['type'] as String),
      isActive: json['is_active'] as bool,
      balance: (json['balance'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'currency_id': currencyId,
      'currency': currency.toJson(),
      'type': type.toJson(),
      'is_active': isActive,
      'balance': balance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  WalletDto copyWith({double? balance}) {
    return WalletDto(
      id: id,
      userId: userId,
      name: name,
      currencyId: currencyId,
      currency: currency,
      type: type,
      isActive: isActive,
      balance: balance ?? this.balance,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    currencyId,
    currency,
    type,
    isActive,
    balance,
    createdAt,
    updatedAt,
  ];
}
