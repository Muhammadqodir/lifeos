import 'package:dio/dio.dart';
import '../models/wallet_dto.dart';
import '../models/transaction_dto.dart';
import '../models/finance_summary_dto.dart';
import '../models/currency_dto.dart';

class FinanceApiClient {
  final Dio dio;
  final String baseUrl;

  FinanceApiClient({required this.dio, required this.baseUrl});

  /// Get all wallets for the authenticated user
  Future<List<WalletDto>> getWallets() async {
    try {
      final response = await dio.get('$baseUrl/wallets');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => WalletDto.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get wallet balance by ID
  Future<String> getWalletBalance(int walletId) async {
    try {
      final response = await dio.get('$baseUrl/wallets/$walletId/balance');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return data['balance'] as String;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get transactions with pagination and optional filters
  Future<TransactionListResponseDto> getTransactions({
    int page = 1,
    int perPage = 20,
    String? type,
    int? walletId,
    int? categoryId,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? searchQuery,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (type != null) queryParameters['type'] = type;
      if (walletId != null) queryParameters['wallet_id'] = walletId;
      if (categoryId != null) queryParameters['category_id'] = categoryId;
      if (dateFrom != null) {
        queryParameters['date_from'] = dateFrom.toIso8601String().split('T')[0];
      }
      if (dateTo != null) {
        queryParameters['date_to'] = dateTo.toIso8601String().split('T')[0];
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParameters['q'] = searchQuery;
      }

      final response = await dio.get(
        '$baseUrl/transactions',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return TransactionListResponseDto.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get finance summary
  /// TODO: Replace with actual endpoint when API provides a summary endpoint
  /// For now, this is a placeholder that computes total from wallets
  Future<FinanceSummaryDto> getFinanceSummary() async {
    try {
      // TODO: Replace this with actual API call when endpoint is available
      // Placeholder: compute from wallets
      final wallets = await getWallets();
      
      // For now, return a simple computed total
      // This should be replaced with proper API endpoint
      double total = 0.0;
      String baseCurrency = 'USD'; // Default fallback
      
      for (final wallet in wallets) {
        if (wallet.balance != null) {
          total += double.tryParse(wallet.balance!) ?? 0.0;
          baseCurrency = wallet.currency.code; // Use first wallet's currency
        }
      }

      return FinanceSummaryDto(
        totalBalance: total.toStringAsFixed(2),
        currencyCode: baseCurrency,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get user's currencies
  Future<List<CurrencyDto>> getUserCurrencies() async {
    try {
      final response = await dio.get('$baseUrl/user/currencies');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => CurrencyDto.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Create a new wallet
  Future<WalletDto> createWallet({
    required String name,
    required int currencyId,
    required String type,
    bool isActive = true,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/wallets',
        data: {
          'name': name,
          'currency_id': currencyId,
          'type': type,
          'is_active': isActive,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        return WalletDto.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final statusCode = error.response!.statusCode;
        final message = error.response!.data['message'] as String? ??
            'An error occurred';

        switch (statusCode) {
          case 401:
            return Exception('Unauthorized: Please log in again');
          case 403:
            return Exception('Forbidden: $message');
          case 404:
            return Exception('Not found: $message');
          case 422:
            final errors = error.response!.data['errors'] as Map?;
            if (errors != null) {
              final firstError = errors.values.first as List;
              return Exception(firstError.first as String);
            }
            return Exception(message);
          case 500:
            return Exception('Server error: Please try again later');
          default:
            return Exception(message);
        }
      } else if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return Exception('Connection timeout: Please check your internet');
      } else if (error.type == DioExceptionType.connectionError) {
        return Exception('Connection error: Please check your internet');
      }
    }
    return Exception('An unexpected error occurred');
  }
}
