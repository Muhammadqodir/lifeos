/// Request DTO for creating a new transaction
class CreateTransactionRequestDto {
  final String clientId;
  final String type;
  final int? categoryId;
  final String? description;
  final DateTime occurredAt;
  final List<CreateTransactionEntryDto> entries;

  const CreateTransactionRequestDto({
    required this.clientId,
    required this.type,
    this.categoryId,
    this.description,
    required this.occurredAt,
    required this.entries,
  });

  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'type': type,
      'category_id': categoryId,
      'description': description,
      'occurred_at': occurredAt.toIso8601String(),
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }
}

/// Entry DTO for creating transaction entries
class CreateTransactionEntryDto {
  final int walletId;
  final String amount;
  final int currencyId;
  final String? rate;
  final String? note;

  const CreateTransactionEntryDto({
    required this.walletId,
    required this.amount,
    required this.currencyId,
    this.rate,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'wallet_id': walletId,
      'amount': amount,
      'currency_id': currencyId,
      'rate': rate,
      'note': note,
    };
  }
}
