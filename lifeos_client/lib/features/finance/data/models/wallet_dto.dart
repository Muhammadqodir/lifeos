import 'package:equatable/equatable.dart';
import 'currency_dto.dart';

enum WalletType {
  card,
  bankAccount,
  cash,
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

class WalletDto extends Equatable {
  final int id;
  final int userId;
  final String name;
  final int currencyId;
  final CurrencyDto currency;
  final WalletType type;
  final bool isActive;
  final String? balance; // Coming from balance endpoint
  final DateTime createdAt;
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
      balance: json['balance'] as String?,
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

  WalletDto copyWith({
    String? balance,
  }) {
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
