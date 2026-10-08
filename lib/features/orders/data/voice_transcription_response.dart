import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';

/// Reads a transcript without treating arbitrary API messages as spoken text.
String readVoiceTranscript(ApiResponse<dynamic> response, {Uri? requestUri}) {
  final data = response.data;
  final contentType = response.headers['content-type']
      ?.split(';')
      .first
      .trim()
      .toLowerCase();
  final htmlContentType =
      contentType == 'text/html' || contentType == 'application/xhtml+xml';
  // A wrong MIME type must not hide a valid JSON transcript. Conversely,
  // arbitrary text from an HTML response must not become an order description.
  final text = _transcript(data, allowPlainText: !htmlContentType);
  String? failure;
  if ((data is String && _isMarkup(data)) ||
      (text != null && _isMarkup(text))) {
    failure = 'Сервер распознавания вернул HTML вместо текста';
  } else if (data == null) {
    failure = 'Сервер распознавания вернул пустой ответ';
  } else if (text == null) {
    failure = 'Сервер распознавания вернул неверный формат ответа';
  }
  if (failure != null) {
    // Log only structure, never the transcript, audio or authorization token.
    debugPrint(
      'Voice transcription response: '
      '${requestUri == null ? '' : 'POST ${requestUri.origin}${requestUri.path}, '}'
      'HTTP ${response.statusCode}, '
      'content-type ${contentType ?? 'missing'}, shape ${_shape(data)}',
    );
    throw ApiException(statusCode: response.statusCode, message: failure);
  }
  if (text!.isEmpty) {
    throw const ApiException(
      statusCode: 422,
      message: 'Речь не распознана. Повторите запись или введите текст.',
    );
  }
  return text;
}

String _trim(String text) =>
    text.trim().replaceFirst(RegExp(r'^\uFEFF'), '').trim();

bool _isMarkup(String text) => RegExp(
  r'^<(?:!doctype\b|\?xml\b|/?[a-z][\w:-]*(?:\s|/?>))',
  caseSensitive: false,
).hasMatch(_trim(text));

String? _transcript(dynamic data, {int depth = 0, bool allowPlainText = true}) {
  if (depth >= 6) return null;
  if (data is String) {
    final text = _trim(data);
    // Also handle a JSON body with a BOM or a JSON-encoded response string.
    if (text.startsWith('{') || text.startsWith('[') || text.startsWith('"')) {
      try {
        return _transcript(jsonDecode(text), depth: depth + 1);
      } on FormatException {
        return null;
      }
    }
    return allowPlainText ? text : null;
  }
  if (data is Map) {
    if (_isFailure(data)) return null;
    for (final key in const ['text', 'transcript', 'transcription']) {
      final value = data[key];
      if (value is String) return _trim(value);
      if (value is Map || value is List) {
        final text = _transcript(value, depth: depth + 1);
        if (text != null) return text;
      }
    }
    for (final key in const ['data', 'result']) {
      final text = _transcript(data[key], depth: depth + 1);
      if (text != null) return text;
    }
    if (data['segments'] is List) {
      return _transcript(data['segments'], depth: depth + 1);
    }
  }
  // Segment responses are accepted only when every item has actual text.
  if (data is List && data.isNotEmpty) {
    final parts = <String>[];
    for (final item in data) {
      if (item is! Map || item['text'] is! String || _isFailure(item)) {
        return null;
      }
      final text = _trim(item['text'] as String);
      if (_isMarkup(text)) return null;
      if (text.isNotEmpty) parts.add(text);
    }
    return parts.join(' ');
  }
  return null;
}

bool _isFailure(Map data) {
  final error = data['error'];
  return data['success'] == false ||
      data['ok'] == false ||
      const ['error', 'failed', 'failure'].contains(data['status']) ||
      (error != null && error != false && error != '');
}

String _shape(dynamic data, [int depth = 0]) {
  if (data == null) return 'null';
  if (data is String) {
    return '${_isMarkup(data) ? 'html' : 'string'}(length=${data.length})';
  }
  if (data is List) {
    return 'array(length=${data.length}'
        '${data.isEmpty || depth >= 2 ? '' : ', first=${_shape(data.first, depth + 1)}'})';
  }
  if (data is Map) {
    if (depth >= 2) return 'object(fields=${data.length})';
    final fields = <String>[];
    // Only fixed contract keys are logged; unknown keys could contain user data.
    for (final key in const [
      'text',
      'transcript',
      'transcription',
      'data',
      'result',
      'segments',
      'error',
      'message',
      'success',
      'ok',
      'status',
    ]) {
      if (data.containsKey(key)) {
        fields.add('$key:${_shape(data[key], depth + 1)}');
      }
    }
    return 'object(fields=${data.length}, ${fields.join(', ')})';
  }
  return data.runtimeType.toString();
}
