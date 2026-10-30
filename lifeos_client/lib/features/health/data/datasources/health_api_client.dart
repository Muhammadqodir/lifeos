import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';

/// Health calls that stay online: file uploads. Sleep, wellbeing, exercises
/// and workouts are local-first (see the health repositories and
/// docs/local-first.md).
class HealthApiClient {
  final Dio dio;
  final String baseUrl;

  HealthApiClient({required this.dio, required this.baseUrl});

  /// `POST /gym/workouts/{id}/photo` with the backend's numeric id.
  Future<void> uploadWorkoutPhoto(int serverId, String path) =>
      _upload('$baseUrl/gym/workouts/$serverId/photo', 'photo', path);

  /// `POST /gym/exercises/{id}/image` with the backend's numeric id.
  Future<void> uploadExerciseImage(int serverId, String path) =>
      _upload('$baseUrl/gym/exercises/$serverId/image', 'image', path);

  Future<void> _upload(String url, String field, String path) async {
    try {
      await dio.post(
        url,
        data: FormData.fromMap({
          field: await MultipartFile.fromFile(
            path,
            filename: path.split('/').last,
          ),
        }),
        options: Options(contentType: 'multipart/form-data'),
      );
    } catch (e) {
      throw ApiException.from(e);
    }
  }
}
