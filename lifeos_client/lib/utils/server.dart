import 'package:lifeos_client/core/config/app_config.dart';

/// Builds absolute URLs for files served from the backend's public storage.
abstract final class StorageUrl {
  /// Resolves [path] (as returned by the API, e.g. `projects/icon.png` or
  /// `/projects/icon.png`) to `https://host/storage/projects/icon.png`.
  /// Absolute URLs are returned unchanged.
  static String resolve(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final base = AppConfig.serverBaseUrl.endsWith('/')
        ? AppConfig.serverBaseUrl.substring(
            0,
            AppConfig.serverBaseUrl.length - 1,
          )
        : AppConfig.serverBaseUrl;
    var relative = path.startsWith('/') ? path.substring(1) : path;
    if (relative.startsWith('storage/')) {
      relative = relative.substring('storage/'.length);
    }
    return '$base/storage/$relative';
  }
}
