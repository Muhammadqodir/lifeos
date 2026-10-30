import 'package:dio/dio.dart';

/// An API error in the backend's one error shape:
/// `{"message": "...", "code": "...", "errors": {"field": ["..."]}}`.
///
/// [toString] is the human-readable message, so `e.toString()` in a bloc
/// shows something a person can read.
class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.code = 'unknown',
    this.statusCode,
    this.fieldErrors = const {},
  });

  final String message;

  /// Machine-readable code from the backend (`validation_failed`,
  /// `not_found`, ...), or `network` when the server was not reached.
  final String code;
  final int? statusCode;
  final Map<String, List<String>> fieldErrors;

  bool get isNetwork => code == 'network';

  factory ApiException.from(Object error) {
    if (error is ApiException) return error;
    if (error is! DioException) return ApiException(error.toString());

    final response = error.response;
    if (response == null) {
      return const ApiException(
        "Can't reach the server. Check your connection.",
        code: 'network',
      );
    }

    final body = response.data;
    if (body is Map) {
      final errors = <String, List<String>>{};
      final rawErrors = body['errors'];
      if (rawErrors is Map) {
        rawErrors.forEach((key, value) {
          errors['$key'] = value is List
              ? value.map((e) => '$e').toList()
              : ['$value'];
        });
      }
      final message = body['message'];
      return ApiException(
        message is String && message.isNotEmpty
            ? message
            : 'Request failed (${response.statusCode}).',
        code: body['code'] is String ? body['code'] as String : 'http_error',
        statusCode: response.statusCode,
        fieldErrors: errors,
      );
    }

    return ApiException(
      'Request failed (${response.statusCode}).',
      code: 'http_error',
      statusCode: response.statusCode,
    );
  }

  @override
  String toString() => message;
}
