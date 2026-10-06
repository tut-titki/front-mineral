import 'api_client.dart';

/// Keeps undocumented response fields intact without inventing a schema.
class BackendDocument {
  const BackendDocument(this.value);
  final Object? value;

  factory BackendDocument.fromJson(dynamic value) {
    if (value is! Map && value is! List && value != null) {
      throw const ApiException(
        statusCode: 502,
        message: 'Сервер вернул неверный формат данных',
      );
    }
    return BackendDocument(value);
  }

  bool get isEmpty =>
      value == null ||
      (value is Map && (value as Map).isEmpty) ||
      (value is List && (value as List).isEmpty);
}
