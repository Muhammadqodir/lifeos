import 'package:dio/dio.dart';
import '../models/wallet_dto.dart';
import '../models/transaction_dto.dart';
import '../models/finance_summary_dto.dart';
import '../models/currency_dto.dart';
import '../models/transaction_category_dto.dart';
import '../models/create_transaction_dto.dart';
import '../models/analytics_summary_dto.dart';

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
  Future<double> getWalletBalance(int walletId) async {
    try {
      final response = await dio.get('$baseUrl/wallets/$walletId/balance');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return (data['balance'] as num?)?.toDouble() ?? 0.0;
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
  /// Computes total balance converted to user's default currency
  Future<FinanceSummaryDto> getFinanceSummary() async {
    try {
      // Get user's default currency from finance settings
      final settings = await getFinanceSettings();
      final baseCurrencyData = settings['base_currency'] as Map<String, dynamic>?;
      
      if (baseCurrencyData == null) {
        // No default currency set, return 0
        return const FinanceSummaryDto(
          totalBalance: 0.0,
          currencyCode: 'USD',
        );
      }

      final baseCurrency = CurrencyDto.fromJson(baseCurrencyData);
      
      // Get all wallets with balances
      final response = await dio.get('$baseUrl/wallets?with_balances=true');
      
      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }

      final walletsJson = response.data['data'] as List<dynamic>;
      final wallets = walletsJson.map((json) => WalletDto.fromJson(json as Map<String, dynamic>)).toList();

      if (wallets.isEmpty) {
        return FinanceSummaryDto(
          totalBalance: 0.0,
          currencyCode: baseCurrency.code,
        );
      }

      // Group wallets by currency to minimize API calls
      final walletsByCurrency = <String, List<WalletDto>>{};
      for (final wallet in wallets) {
        if (wallet.balance != null && wallet.balance! > 0) {
          walletsByCurrency.putIfAbsent(wallet.currency.code, () => []).add(wallet);
        }
      }

      // Calculate total in base currency
      double totalInBaseCurrency = 0.0;

      for (final entry in walletsByCurrency.entries) {
        final currencyCode = entry.key;
        final walletsInCurrency = entry.value;
        
        // Sum balances in this currency
        final sumInCurrency = walletsInCurrency.fold<double>(
          0.0,
          (sum, wallet) => sum + (wallet.balance ?? 0.0),
        );

        // Convert to base currency
        if (currencyCode == baseCurrency.code) {
          // Same currency, no conversion needed
          totalInBaseCurrency += sumInCurrency;
        } else {
          // Different currency, need to convert using FX rates
          try {
            final fxResponse = await dio.get(
              '$baseUrl/fx/rates',
              queryParameters: {
                'origin': currencyCode,
                'target': baseCurrency.code,
              },
            );

            if (fxResponse.statusCode == 200) {
              final rates = fxResponse.data['data']['rates'] as Map<String, dynamic>;
              final rate = (rates[baseCurrency.code] as num?)?.toDouble() ?? 1.0;
              totalInBaseCurrency += sumInCurrency * rate;
            } else {
              // If conversion fails, skip this currency
              // In production, you might want to handle this differently
              print('Failed to get FX rate for $currencyCode to ${baseCurrency.code}');
            }
          } catch (e) {
            // If FX rate fetch fails, skip this currency
            print('Error fetching FX rate for $currencyCode: $e');
          }
        }
      }

      return FinanceSummaryDto(
        totalBalance: totalInBaseCurrency,
        currencyCode: baseCurrency.code,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get all system currencies
  Future<List<CurrencyDto>> getUserCurrencies() async {
    // All currencies are now system currencies
    return getAllCurrencies();
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

  /// Delete a wallet
  Future<void> deleteWallet(int walletId) async {
    try {
      final response = await dio.delete('$baseUrl/wallets/$walletId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get transaction categories
  Future<List<TransactionCategoryDto>> getTransactionCategories({
    String? type,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (type != null) queryParameters['type'] = type;

      final response = await dio.get(
        '$baseUrl/transaction-categories',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data
            .map((json) => TransactionCategoryDto.fromJson(json))
            .toList();
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

  /// Create a new transaction
  Future<TransactionDto> createTransaction(
    CreateTransactionRequestDto request,
  ) async {
    try {
      final response = await dio.post(
        '$baseUrl/transactions',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        return TransactionDto.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e, s) {
      print('Exception in createTransaction: $e'); // Debug log
      print(s);
      if (e is! DioException) {
        print('Stack trace: ${StackTrace.current}'); // Debug log
      }
      throw _handleError(e);
    }
  }

  /// Delete a transaction
  Future<void> deleteTransaction(int transactionId) async {
    try {
      final response = await dio.delete(
        '$baseUrl/transactions/$transactionId',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e, s) {
      print('Exception in deleteTransaction: $e');
      print(s);
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final statusCode = error.response!.statusCode;
        final message =
            error.response!.data['message'] as String? ?? 'An error occurred';

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

  /// Get analytics data grouped by category for a given period
  Future<AnalyticsSummaryDto> getAnalytics({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? currencyId,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (dateFrom != null) {
        queryParameters['date_from'] = dateFrom.toIso8601String().split('T')[0];
      }
      if (dateTo != null) {
        queryParameters['date_to'] = dateTo.toIso8601String().split('T')[0];
      }
      if (currencyId != null) {
        queryParameters['currency_id'] = currencyId;
      }

      final response = await dio.get(
        '$baseUrl/analytics',
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        print(data);
        return AnalyticsSummaryDto.fromJson(data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e, s) {
      print("Analytics API error: $e");
      print("Stack trace: $s");
      if (e is DioException && e.response != null) {
        print("Response status: ${e.response!.statusCode}");
        print("Response data: ${e.response!.data}");
      }
      throw _handleError(e);
    }
  }

  /// Get user's finance settings including default currency
  Future<Map<String, dynamic>> getFinanceSettings() async {
    try {
      final response = await dio.get('$baseUrl/user/finance-settings');

      if (response.statusCode == 200) {
        return response.data['data'] as Map<String, dynamic>;
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

  /// Update user's finance settings (base currency)
  Future<Map<String, dynamic>> updateFinanceSettings({
    required int baseCurrencyId,
  }) async {
    try {
      final response = await dio.patch(
        '$baseUrl/user/finance-settings',
        data: {'base_currency_id': baseCurrencyId},
      );

      if (response.statusCode == 200) {
        return response.data['data'] as Map<String, dynamic>;
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

  /// Get all available currencies
  Future<List<CurrencyDto>> getAllCurrencies() async {
    try {
      final response = await dio.get('$baseUrl/currencies');

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



  /// Create a new transaction category
  Future<TransactionCategoryDto> createCategory({
    required String title,
    required String type,
    required String icon,
    required String color,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/transaction-categories',
        data: {'title': title, 'type': type, 'icon': icon, 'color': color},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        return TransactionCategoryDto.fromJson(data);
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

  /// Delete a transaction category
  Future<void> deleteCategory(int categoryId) async {
    try {
      final response = await dio.delete(
        '$baseUrl/transaction-categories/$categoryId',
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }
}
