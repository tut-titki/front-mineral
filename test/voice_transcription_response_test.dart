import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mineral/core/api/api_client.dart';
import 'package:mineral/features/orders/widgets/voice_description_button.dart';

import 'helpers/backend_api_fixture.dart';

void main() {
  const transcript = 'Заменить подшипник. Проверить насос.';
  final audio = voiceWav(Uint8List.fromList([0, 0, 255, 127]));
  http.Response raw(String body, {String type = 'text/plain'}) =>
      http.Response.bytes(
        utf8.encode(body),
        200,
        headers: {'content-type': '$type; charset=utf-8'},
      );

  final supported = <String, http.Response>{
    'documented text': jsonResponse({'text': '  $transcript  '}),
    'data envelope': jsonResponse({
      'data': {'text': transcript},
    }),
    'nested result envelope': jsonResponse({
      'data': {
        'result': {'text': transcript},
      },
    }),
    'transcript field': jsonResponse({'transcript': transcript}),
    'transcription field': jsonResponse({'transcription': transcript}),
    'transcription object': jsonResponse({
      'transcription': {'text': transcript},
    }),
    'plain UTF-8 text': raw('  $transcript  '),
    'JSON string': jsonResponse('  $transcript  '),
    'JSON encoded twice': jsonResponse(jsonEncode({'text': transcript})),
    'JSON with BOM': raw(
      '\uFEFF${jsonEncode({'text': transcript})}',
      type: 'application/json',
    ),
    'segments': jsonResponse({
      'segments': [
        {'text': ' Заменить подшипник. ', 'start': 0},
        {'text': ' '},
        {'text': ' Проверить насос. ', 'start': 2},
      ],
    }),
    'segment array': jsonResponse([
      {'text': 'Заменить подшипник.'},
      {'text': 'Проверить насос.'},
    ]),
    'successful envelope with null error': jsonResponse({
      'success': true,
      'error': null,
      'text': transcript,
    }),
    'documented JSON with wrong HTML MIME type': raw(
      jsonEncode({'text': transcript}),
      type: 'text/html',
    ),
    'wrapped JSON with wrong XHTML MIME type': raw(
      jsonEncode({
        'result': {'text': transcript},
      }),
      type: 'application/xhtml+xml',
    ),
    'BOM JSON with wrong HTML MIME type': raw(
      '\uFEFF${jsonEncode({'text': transcript})}',
      type: 'text/html',
    ),
  };
  for (final entry in supported.entries) {
    test('HTTP 200 ${entry.key} yields the full transcript', () async {
      var requests = 0;
      final api = testApi(
        handle: (request) async {
          requests++;
          expect(request.url.path, '/api/ai/transcribe');
          expect(request.headers['Authorization'], 'Bearer test-token');
          return entry.value;
        },
      );
      addTearDown(api.dispose);
      expect(await transcribeVoice(api, audio), transcript);
      expect(requests, 1);
    });
  }

  final invalid = <String, http.Response>{
    'unrelated message': jsonResponse({'message': transcript}),
    'numeric text': jsonResponse({'text': 123}),
    'unknown fields': jsonResponse({'description': transcript}),
    'non-JSON HTML MIME body': raw('Gateway page', type: 'text/html'),
    'unrelated JSON with HTML MIME type': raw(
      jsonEncode({'message': transcript}),
      type: 'text/html',
    ),
    'string instead of segments': jsonResponse({'segments': transcript}),
    'empty list': jsonResponse([]),
    'string list': jsonResponse([transcript]),
    'incomplete segment list': jsonResponse({
      'segments': [
        {'text': transcript},
        {'start': 2},
      ],
    }),
    'error envelope with text': jsonResponse({
      'error': 'Whisper unavailable',
      'text': transcript,
    }),
    'failed envelope with text': jsonResponse({
      'success': false,
      'data': {'text': transcript},
    }),
    'failed status with text': jsonResponse({
      'status': 'error',
      'text': transcript,
    }),
    'failed segment': jsonResponse({
      'segments': [
        {'text': transcript, 'ok': false},
      ],
    }),
    'truncated JSON': raw('{"text":"$transcript"', type: 'application/json'),
    'excessive nesting': jsonResponse({
      'data': {
        'data': {
          'data': {
            'data': {
              'data': {
                'data': {'text': transcript},
              },
            },
          },
        },
      },
    }),
  };
  for (final entry in invalid.entries) {
    test('HTTP 200 ${entry.key} is not inserted as a transcript', () async {
      final api = testApi(handle: (_) async => entry.value);
      addTearDown(api.dispose);
      await expectLater(
        transcribeVoice(api, audio),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'status', 200)
              .having(
                (e) => e.message,
                'message',
                'Сервер распознавания вернул неверный формат ответа',
              ),
        ),
      );
    });
  }

  for (final response in [
    raw('<!DOCTYPE html><html><body>Gateway</body></html>', type: 'text/html'),
    raw('<html><body>Login</body></html>', type: 'application/json'),
    jsonResponse({'text': '<html><body>Login</body></html>'}),
  ]) {
    test('HTML response is reported separately (${response.body})', () async {
      final api = testApi(handle: (_) async => response);
      addTearDown(api.dispose);
      await expectLater(
        transcribeVoice(api, audio),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Сервер распознавания вернул HTML вместо текста',
          ),
        ),
      );
    });
  }

  for (final data in [
    {'text': ' '},
    {
      'data': {'transcript': ''},
    },
    {
      'segments': [
        {'text': ' '},
      ],
    },
    '',
  ]) {
    test(
      'empty transcript is reported as unrecognized speech ($data)',
      () async {
        final api = testApi(handle: (_) async => jsonResponse(data));
        addTearDown(api.dispose);
        await expectLater(
          transcribeVoice(api, audio),
          throwsA(
            isA<ApiException>().having((e) => e.statusCode, 'status', 422),
          ),
        );
      },
    );
  }

  test('empty HTTP body has a separate response error', () async {
    final api = testApi(handle: (_) async => raw('  '));
    addTearDown(api.dispose);
    await expectLater(
      transcribeVoice(api, audio),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          'Сервер распознавания вернул пустой ответ',
        ),
      ),
    );
  });

  test('HTTP error status and server message are preserved', () async {
    final api = testApi(
      handle: (_) async =>
          jsonResponse({'message': 'Whisper unavailable'}, status: 502),
    );
    addTearDown(api.dispose);
    await expectLater(
      transcribeVoice(api, audio),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'status', 502)
            .having((e) => e.message, 'message', 'Whisper unavailable'),
      ),
    );
  });

  test('response diagnostics log structure without response values', () async {
    final logs = <String>[];
    final original = debugPrint;
    debugPrint = (message, {wrapWidth}) {
      if (message != null) logs.add(message);
    };
    addTearDown(() => debugPrint = original);
    final api = testApi(
      handle: (_) async => jsonResponse({
        'message': 'private speech',
        'private-key': 'private value',
        'data': {'unknown': 'secret'},
      }),
    );
    addTearDown(api.dispose);
    await expectLater(
      transcribeVoice(api, audio),
      throwsA(isA<ApiException>()),
    );
    expect(logs.single, contains('HTTP 200'));
    expect(
      logs.single,
      contains('POST https://backend.test/api/ai/transcribe'),
    );
    expect(logs.single, contains('message:string'));
    for (final secret in [
      'private speech',
      'private-key',
      'private value',
      'secret',
      'test-token',
    ]) {
      expect(logs.single, isNot(contains(secret)));
    }
  });
}
