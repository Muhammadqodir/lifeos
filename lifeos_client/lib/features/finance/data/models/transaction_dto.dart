import 'package:equatable/equatable.dart';
import 'transaction_category_dto.dart';
import 'wallet_dto.dart';
import 'currency_dto.dart';

enum TransactionType {
  income,
  expense,
  transfer,
  exchange;

  String toJson() {
    switch (this) {
      case TransactionType.income:
        return 'income';
      case TransactionType.expense:
        return 'expense';
      case TransactionType.transfer:
        return 'transfer';
      case TransactionType.exchange:
        return 'exchange';
    }
  }

  static TransactionType fromJson(String value) {
    switch (value) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      case 'transfer':
        return TransactionType.transfer;
      case 'exchange':
        return TransactionType.exchange;
      default:
        return TransactionType.expense;
    }
  }
}

class TransactionEntryDto extends Equatable {
  final int id;
  final int transactionId;
  final int walletId;
  final WalletEntryDto wallet;
  final String amount;
  final int currencyId;
  final CurrencyDto currency;
  final String? rate;
  final String? note;
  final DateTime createdAt;

  const TransactionEntryDto({
    required this.id,
    required this.transactionId,
    required this.walletId,
    required this.wallet,
    required this.amount,
    required this.currencyId,
    required this.currency,
    this.rate,
    this.note,
    required this.createdAt,
  });

  factory TransactionEntryDto.fromJson(Map<String, dynamic> json) {
    return TransactionEntryDto(
      id: json['id'] as int,
      transactionId: json['transaction_id'] as int,
      walletId: json['wallet_id'] as int,
      wallet: WalletEntryDto.fromJson(json['wallet'] as Map<String, dynamic>),
      amount: json['amount'] as String,
      currencyId: json['currency_id'] as int,
      currency: CurrencyDto.fromJson(json['currency'] as Map<String, dynamic>),
      rate: json['rate'] as String?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'wallet_id': walletId,
      'wallet': wallet.toJson(),
      'amount': amount,
      'currency_id': currencyId,
      'currency': currency.toJson(),
      'rate': rate,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        transactionId,
        walletId,
        wallet,
        amount,
        currencyId,
        currency,
        rate,
        note,
        createdAt,
      ];
}

// Simplified wallet info in transaction entry
class WalletEntryDto extends Equatable {
  final int id;
  final String name;
  final WalletType type;

  const WalletEntryDto({
    required this.id,
    required this.name,
    required this.type,
  });

  factory WalletEntryDto.fromJson(Map<String, dynamic> json) {
    return WalletEntryDto(
      id: json['id'] as int,
      name: json['name'] as String,
      type: WalletType.fromJson(json['type'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, name, type];
}

class TransactionDto extends Equatable {
  final int id;
  final int userId;
  final String clientId;
  final TransactionType type;
  final int? categoryId;
  final TransactionCategoryDto? category;
  final String? description;
  final DateTime occurredAt;
  final List<TransactionEntryDto> entries;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionDto({
    required this.id,
    required this.userId,
    required this.clientId,
    required this.type,
    this.categoryId,
    this.category,
    this.description,
    required this.occurredAt,
    required this.entries,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionDto.fromJson(Map<String, dynamic> json) {
    return TransactionDto(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      clientId: json['client_id'] as String,
      type: TransactionType.fromJson(json['type'] as String),
      categoryId: json['category_id'] as int?,
      category: json['category'] != null
          ? TransactionCategoryDto.fromJson(
              json['category'] as Map<String, dynamic>)
          : null,
      description: json['description'] as String?,
      occurredAt: DateTime.parse(json['occurred_at'] as String),
      entries: (json['entries'] as List)
          .map((e) => TransactionEntryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'client_id': clientId,
      'type': type.toJson(),
      'category_id': categoryId,
      'category': category?.toJson(),
      'description': description,
      'occurred_at': occurredAt.toIso8601String(),
      'entries': entries.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        clientId,
        type,
        categoryId,
        category,
        description,
        occurredAt,
        entries,
        createdAt,
        updatedAt,
      ];
}

class TransactionListResponseDto {
  final List<TransactionDto> data;
  final PaginationMeta meta;

  const TransactionListResponseDto({
    required this.data,
    required this.meta,
  });

  factory TransactionListResponseDto.fromJson(Map<String, dynamic> json) {
    return TransactionListResponseDto(
      data: (json['data'] as List)
          .map((e) => TransactionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] as int,
      lastPage: json['last_page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
    );
  }

  bool get hasMore => currentPage < lastPage;
}
