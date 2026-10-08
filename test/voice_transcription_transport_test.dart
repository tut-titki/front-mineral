import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/core/api/api_client.dart';
import 'package:mineral/core/api/api_services.dart';
import 'package:mineral/features/orders/widgets/voice_description_button.dart';
import 'package:mineral/features/references/data/reference_storage_stub.dart';

void main() {
  final audio = voiceWav(Uint8List.fromList([0, 0, 255, 127]));
  final requests =
      <
        ({
          String method,
          String path,
          String? authorization,
          String? contentType,
          String body,
        })
      >[];

  Future<ApiServices> localApi(
    void Function(HttpRequest request) respond,
  ) async {
    // Real HTTP transport, restricted to an ephemeral loopback port.
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final subscription = server.listen((request) async {
      final bytes = await request.fold<List<int>>(
        [],
        (all, part) => all..addAll(part),
      );
      requests.add((
        method: request.method,
        path: request.uri.path,
        authorization: request.headers.value(HttpHeaders.authorizationHeader),
        contentType: request.headers.value(HttpHeaders.contentTypeHeader),
        body: latin1.decode(bytes),
      ));
      respond(request);
      await request.response.close();
    });
    final api = ApiServices(
      baseUrl: 'http://127.0.0.1:${server.port}',
      referenceStorage: MemoryReferenceStorage(),
    )..client.setAccessToken('local-test-token');
    addTearDown(() async {
      api.dispose();
      await server.close(force: true);
      await subscription.cancel();
    });
    return api;
  }

  setUp(requests.clear);

  test(
    'real multipart WAV yields documented JSON even with HTML MIME type',
    () async {
      final api = await localApi((request) {
        request.response.headers.contentType = ContentType.html;
        request.response.write(jsonEncode({'text': '  Заменить подшипник.  '}));
      });
      expect(await transcribeVoice(api, audio), 'Заменить подшипник.');
      final request = requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/api/ai/transcribe');
      expect(request.authorization, 'Bearer local-test-token');
      expect(request.contentType, startsWith('multipart/form-data; boundary='));
      expect(
        request.body,
        contains('name="audio"; filename="description.wav"'),
      );
      expect(request.body, contains('content-type: audio/wav'));
      expect(request.body, contains(latin1.decode(audio)));
    },
  );

  test('real HTML response remains an error with HTTP 200', () async {
    final api = await localApi((request) {
      request.response.headers.contentType = ContentType.html;
      request.response.write(
        '<!doctype html><html><body>Sign in</body></html>',
      );
    });
    await expectLater(
      transcribeVoice(api, audio),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'status', 200)
            .having(
              (e) => e.message,
              'message',
              'Сервер распознавания вернул HTML вместо текста',
            ),
      ),
    );
    expect(requests.single.method, 'POST');
  });

  test('POST 303 is reported without issuing GET to an HTML page', () async {
    final api = await localApi((request) {
      if (request.uri.path == '/api/ai/transcribe') {
        request.response.statusCode = HttpStatus.seeOther;
        request.response.headers.set(HttpHeaders.locationHeader, '/sign-in');
      } else {
        request.response.headers.contentType = ContentType.html;
        request.response.write('<html><body>Sign in</body></html>');
      }
    });
    await expectLater(
      transcribeVoice(api, audio),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'status', 303)
            .having(
              (e) => e.message,
              'message',
              'Сервер перенаправил запрос распознавания. Проверьте адрес API',
            ),
      ),
    );
    expect(requests, hasLength(1));
    expect(requests.single.method, 'POST');
    expect(requests.single.path, '/api/ai/transcribe');
  });
}
