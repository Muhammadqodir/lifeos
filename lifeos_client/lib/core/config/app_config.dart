/// Application configuration constants
class AppConfig {
  // Private constructor to prevent instantiation
  AppConfig._();

  static const String serverBaseUrl = 'https://lifeos.alfocus.uz';

  /// API base URL - can be overridden using --dart-define
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://lifeos.alfocus.uz/api/v1',
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
