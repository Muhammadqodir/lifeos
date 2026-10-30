import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../models/currency_dto.dart';
import '../models/analytics_summary_dto.dart';

/// Finance calls that stay online. Wallets, categories and transactions
/// are local-first (see FinanceRepositoryImpl and docs/local-first.md).
class FinanceApiClient {
  final Dio dio;
  final String baseUrl;

  FinanceApiClient({required this.dio, required this.baseUrl});

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
        return AnalyticsSummaryDto.fromJson(data as Map<String, dynamic>);
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

  /// Rate from [origin] to [target] (`GET /fx/rates`).
  Future<double?> getFxRate(String origin, String target) async {
    try {
      final response = await dio.get(
        '$baseUrl/fx/rates',
        queryParameters: {'origin': origin, 'target': target},
      );
      final rates = response.data['data']['rates'] as Map<String, dynamic>;
      return (rates[target] as num?)?.toDouble();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(Object error) => ApiException.from(error);
}
