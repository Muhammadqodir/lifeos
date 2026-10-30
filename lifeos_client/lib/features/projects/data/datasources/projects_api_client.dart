import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_exception.dart';

/// The one project call that doesn't go through sync: files.
/// Everything else is read and written locally (see ProjectsRepositoryImpl).
class ProjectsApiClient {
  final Dio dio;

  ProjectsApiClient({required this.dio});

  /// `POST /projects/{id}/icon` with the backend's numeric id.
  Future<void> uploadProjectIcon(int serverId, XFile icon) async {
    try {
      await dio.post(
        '/projects/$serverId/icon',
        data: FormData.fromMap({
          'icon': MultipartFile.fromBytes(
            await icon.readAsBytes(),
            filename: icon.name,
          ),
        }),
        options: Options(contentType: 'multipart/form-data'),
      );
    } catch (e) {
      throw ApiException.from(e);
    }
  }
}
