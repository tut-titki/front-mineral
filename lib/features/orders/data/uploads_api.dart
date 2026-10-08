import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../../core/api/api_client.dart';

// MARK: - Uploaded file

class UploadedFile {
  const UploadedFile({
    required this.url,
    required this.originalName,
    required this.size,
  });

  final String url;
  final String originalName;
  final int size;

  factory UploadedFile.fromJson(Map<String, dynamic> json) {
    return UploadedFile(
      url: json['url']?.toString() ?? '',
      originalName: json['originalName']?.toString() ?? '',
      size: _toInt(json['size']),
    );
  }
}

// MARK: - Upload input

class UploadFileInput {
  const UploadFileInput({
    required this.bytes,
    required this.fileName,
    this.takenAt,
  });

  final Uint8List bytes;
  final String fileName;
  final DateTime? takenAt;
}

// MARK: - Uploads API

class UploadsApi {
  const UploadsApi({required ApiClient client, required String baseUrl})
    : _client = client,
      _baseUrl = baseUrl;

  final ApiClient _client;
  final String _baseUrl;

  static const int maxFileSizeBytes = 15 * 1024 * 1024;

  static const int maxPhotos = 5;

  // MARK: - Single upload

  Future<UploadedFile> uploadPhoto({
    required Uint8List bytes,
    required String fileName,
    DateTime? takenAt,
  }) async {
    if (bytes.isEmpty) {
      throw ArgumentError('Файл изображения пустой.');
    }

    if (bytes.length > maxFileSizeBytes) {
      throw ArgumentError('Размер фотографии не должен превышать 15 МБ.');
    }

    final normalizedFileName = fileName.trim().isEmpty
        ? 'photo.jpg'
        : fileName.trim();

    final token = _client.accessToken;

    if (token == null || token.trim().isEmpty) {
      throw ApiException(
        statusCode: 401,
        message: 'Не найден токен авторизации.',
        data: null,
      );
    }

    final uri = Uri.parse('${_normalizedBaseUrl()}/api/uploads');

    final request = http.MultipartRequest('POST', uri);
    if (takenAt != null) {
      request.fields['takenAt'] = takenAt.toUtc().toIso8601String();
    }

    request.headers['Accept'] = 'application/json';

    request.headers['Authorization'] = 'Bearer ${token.trim()}';

    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: normalizedFileName),
    );

    final response = await _client.sendMultipart(request);

    final decoded = response.data;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        statusCode: response.statusCode,
        message: _extractErrorMessage(
          decoded,
          fallback: 'Не удалось загрузить фотографию.',
        ),
        data: decoded,
      );
    }

    if (decoded is! Map) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Сервер вернул некорректный ответ при загрузке фотографии.',
        data: decoded,
      );
    }

    final json = Map<String, dynamic>.from(decoded);

    final uploaded = UploadedFile.fromJson(json);

    if (uploaded.url.trim().isEmpty) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Сервер не вернул URL загруженной фотографии.',
        data: decoded,
      );
    }

    return uploaded;
  }

  // MARK: - Multiple uploads

  Future<List<UploadedFile>> uploadPhotos(List<UploadFileInput> files) async {
    if (files.length > maxPhotos) {
      throw ArgumentError('Можно загрузить не более 5 фотографий.');
    }

    if (files.isEmpty) {
      return <UploadedFile>[];
    }

    final result = <UploadedFile>[];

    // Специально загружаем последовательно.
    //
    // Автоматического retry здесь нет:
    // повторный POST /api/uploads создаст
    // ещё один файл на сервере.
    for (final file in files) {
      final uploaded = await uploadPhoto(
        bytes: file.bytes,
        fileName: file.fileName,
        takenAt: file.takenAt,
      );

      result.add(uploaded);
    }

    return result;
  }

  // MARK: - URL only

  Future<List<String>> uploadPhotoUrls(List<UploadFileInput> files) async {
    final uploaded = await uploadPhotos(files);

    return uploaded.map((file) => file.url).toList(growable: false);
  }

  // MARK: - Helpers

  String _normalizedBaseUrl() {
    var value = _baseUrl.trim();

    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }

    return value;
  }

  String _extractErrorMessage(dynamic data, {required String fallback}) {
    if (data is Map) {
      final message = data['message'];

      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }

      if (message is List && message.isNotEmpty) {
        return message.join(', ');
      }

      final error = data['error'];

      if (error is String && error.trim().isNotEmpty) {
        return error.trim();
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    return fallback;
  }
}

// MARK: - Parsers

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString() ?? '') ?? 0;
}
