/// Application configuration constants
class AppConfig {
  // Private constructor to prevent instantiation
  AppConfig._();

  /// API base URL - can be overridden using --dart-define
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  /// API connection timeout in seconds
  static const int connectTimeoutSeconds = 30;

  /// API receive timeout in seconds
  static const int receiveTimeoutSeconds = 30;

  /// API send timeout in seconds
  static const int sendTimeoutSeconds = 30;

  /// Token storage keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
}
