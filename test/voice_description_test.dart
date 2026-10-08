import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mineral/core/api/api_client.dart';
import 'package:mineral/features/orders/widgets/voice_description_button.dart';
import 'package:mineral/l10n/app_localizations.dart';
import 'package:record/record.dart';
import 'helpers/backend_api_fixture.dart';
import 'helpers/recording_fixture.dart';

void main() {
  Future<void> tapVoice(WidgetTester tester, String label) async {
    await tester.runAsync(() async {
      await tester.tap(find.text(label));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();
  }

  late TestRecorderPlatform platform;
  setUp(() {
    final original = RecordPlatform.instance;
    platform = TestRecorderPlatform();
    RecordPlatform.instance = platform;
    addTearDown(() => RecordPlatform.instance = original);
  });

  Future<void> mount(WidgetTester tester, {bool networkError = false}) async {
    final api = testApi(
      handle: (_) async {
        if (networkError) throw http.ClientException('offline');
        return jsonResponse({'text': 'Описание голосом'});
      },
    );
    addTearDown(api.dispose);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: VoiceDescriptionButton(
            api: api,
            onText: (value) {
              expect(value, 'Описание голосом');
            },
          ),
        ),
      ),
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await platform.states.close();
    });
  }

  testWidgets('recording starts with microphone and consumes final PCM chunk', (
    tester,
  ) async {
    await mount(tester);
    await tapVoice(tester, 'Голосовое описание');
    expect(platform.config!.encoder, AudioEncoder.pcm16bits);
    expect(platform.config!.sampleRate, 16000);
    expect(find.text('Остановить и распознать'), findsOneWidget);
    await tapVoice(tester, 'Остановить и распознать');
    expect(find.text('Голосовое описание'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('denied microphone permission does not start recording', (
    tester,
  ) async {
    platform.permission = false;
    await mount(tester);
    await tapVoice(tester, 'Голосовое описание');
    expect(platform.config, isNull);
    expect(
      find.text('Разрешите доступ к микрофону или введите текст.'),
      findsOneWidget,
    );
  });

  testWidgets('recording startup error allows another attempt', (tester) async {
    platform.startError = PlatformException(
      code: 'record',
      message: 'microphone unavailable',
    );
    await mount(tester);
    await tapVoice(tester, 'Голосовое описание');
    expect(
      find.text(
        'Не удалось включить микрофон. Проверьте разрешение и повторите запись.',
      ),
      findsOneWidget,
    );
    platform.startError = null;
    await tapVoice(tester, 'Голосовое описание');
    expect(find.text('Остановить и распознать'), findsOneWidget);
  });

  testWidgets('network failure is reported as transcription failure', (
    tester,
  ) async {
    await mount(tester, networkError: true);
    await tapVoice(tester, 'Голосовое описание');
    await tapVoice(tester, 'Остановить и распознать');
    expect(
      find.text(
        'Не удалось отправить голос на распознавание. Проверьте соединение и повторите.',
      ),
      findsOneWidget,
    );
    expect(find.text('Голосовое описание'), findsOneWidget);
  });

  testWidgets('native recorder errors stop recording and unlock the button', (
    tester,
  ) async {
    await mount(tester);
    await tapVoice(tester, 'Голосовое описание');
    await tester.runAsync(() async {
      platform.states.addError(
        PlatformException(code: 'record', message: 'audio interrupted'),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();
    expect(
      find.text('Запись прервана. Повторите или введите текст.'),
      findsOneWidget,
    );
    expect(find.text('Голосовое описание'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test(
    'unexpected transcription response produces a controlled API error',
    () async {
      final api = testApi(handle: (_) async => jsonResponse([]));
      addTearDown(api.dispose);
      await expectLater(
        transcribeVoice(api, voiceWav(Uint8List.fromList([0, 0]))),
        throwsA(
          isA<ApiException>().having(
            (error) => error.statusCode,
            'status',
            200,
          ),
        ),
      );
    },
  );
}
