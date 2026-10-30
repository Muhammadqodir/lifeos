import 'package:dio/dio.dart';

import '../network/api_exception.dart';
import 'local_store.dart';

/// Result of one pushed operation.
class PushResult {
  const PushResult({
    required this.opId,
    required this.applied,
    this.record,
    this.code,
    this.message,
  });

  final String opId;
  final bool applied;

  /// The server's copy after the operation (null when it has none).
  final Json? record;
  final String? code;
  final String? message;

  factory PushResult.fromJson(Map<String, dynamic> json) => PushResult(
    opId: json['op_id'] as String,
    applied: json['status'] == 'applied',
    record: json['record'] == null ? null : Json.from(json['record'] as Map),
    code: json['code'] as String?,
    message: json['message'] as String?,
  );
}

class PullResult {
  const PullResult({
    required this.cursor,
    required this.full,
    required this.changes,
    required this.deleted,
  });

  final String cursor;

  /// True when this is everything the server has, not just changes.
  final bool full;
  final Map<String, List<Json>> changes;
  final Map<String, List<String>> deleted;

  factory PullResult.fromJson(Map<String, dynamic> json) {
    final changes = (json['changes'] as Map?) ?? const {};
    final deleted = (json['deleted'] as Map?) ?? const {};
    return PullResult(
      cursor: json['cursor'] as String,
      full: json['full'] as bool? ?? false,
      changes: {
        for (final entry in changes.entries)
          '${entry.key}': [
            for (final record in entry.value as List) Json.from(record as Map),
          ],
      },
      deleted: {
        for (final entry in deleted.entries)
          '${entry.key}': [for (final id in entry.value as List) '$id'],
      },
    );
  }
}

/// HTTP side of sync: `GET /sync/pull` and `POST /sync/push`.
class SyncApi {
  SyncApi(this._dio);

  final Dio _dio;

  Future<PullResult> pull(String? cursor) async {
    try {
      final response = await _dio.get(
        '/sync/pull',
        queryParameters: {if (cursor != null) 'cursor': cursor},
      );
      return PullResult.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<List<PushResult>> push(List<OutboxOp> ops) async {
    try {
      final response = await _dio.post(
        '/sync/push',
        data: {
          'ops': [for (final op in ops) op.toJson()],
        },
      );
      final results = response.data['data']['results'] as List;
      return [
        for (final r in results) PushResult.fromJson(r as Map<String, dynamic>),
      ];
    } catch (e) {
      throw ApiException.from(e);
    }
  }
}
