import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

/// Interceptor that automatically adds auth token to requests
/// and handles token refresh on 401 errors
class AuthInterceptor extends Interceptor {
  final SharedPreferences _prefs;
  final Dio _dio;

  AuthInterceptor(this._prefs, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add token to request headers if available
    final token = _prefs.getString(AppConfig.authTokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    // Always add content type and accept headers
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - token expired or invalid
    if (err.response?.statusCode == 401) {
      // Check if this is already a refresh token request to avoid infinite loop
      if (err.requestOptions.path.contains('/auth/refresh')) {
        // Refresh failed, clear tokens and let error propagate
        await _clearTokens();
        return handler.next(err);
      }

      // Try to refresh the token
      final refreshed = await _refreshToken();
      
      if (refreshed) {
        // Retry the original request with new token
        try {
          final response = await _retry(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          return handler.next(err);
        }
      } else {
        // Refresh failed, clear tokens
        await _clearTokens();
      }
    }

    handler.next(err);
  }

  /// Attempts to refresh the auth token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = _prefs.getString(AppConfig.refreshTokenKey);
      
      // If no refresh token, can't refresh
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      // Make refresh request
      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final newToken = data['token'];
        final newRefreshToken = data['refresh_token'];

        // Save new tokens
        await _prefs.setString(AppConfig.authTokenKey, newToken);
        if (newRefreshToken != null) {
          await _prefs.setString(AppConfig.refreshTokenKey, newRefreshToken);
        }

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Retries the original request with the new token
  Future<Response> _retry(RequestOptions requestOptions) async {
    final token = _prefs.getString(AppConfig.authTokenKey);
    
    // Update the authorization header with new token
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $token',
      },
    );

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// Clears stored tokens
  Future<void> _clearTokens() async {
    await _prefs.remove(AppConfig.authTokenKey);
    await _prefs.remove(AppConfig.refreshTokenKey);
  }
}
