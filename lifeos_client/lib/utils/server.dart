import 'package:lifeos_client/core/config/app_config.dart';

class ServerUtills {
  static String getServerStorageUrl(String path) {
    final serverBaseUrl = AppConfig.serverBaseUrl;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (path.startsWith('/')) {
      return '${serverBaseUrl}storage$path';
    }
    return '$serverBaseUrl/storage/$path';
  }
}
