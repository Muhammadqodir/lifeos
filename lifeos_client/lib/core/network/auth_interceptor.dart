import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'session_events.dart';

/// Adds the bearer token to requests and signs the user out when the
/// backend rejects it.
///
/// Sanctum tokens issued by the backend do not expire and there is no
/// refresh endpoint, so a 401 on an authenticated request means the token
/// was revoked: clear it and let [SessionEvents] route the UI to login.
class AuthInterceptor extends Interceptor {
  final SharedPreferences _prefs;
  final SessionEvents _sessionEvents;

  AuthInterceptor(this._prefs, this._sessionEvents);

  static const _publicAuthPaths = ['/auth/login', '/auth/register'];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _prefs.getString(AppConfig.authTokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isPublicAuthCall = _publicAuthPaths.any(
      (path) => err.requestOptions.path.contains(path),
    );
    if (err.response?.statusCode == 401 && !isPublicAuthCall) {
      await _prefs.remove(AppConfig.authTokenKey);
      await _prefs.remove(AppConfig.refreshTokenKey);
      _sessionEvents.notifyExpired();
    }
    handler.next(err);
  }
}
