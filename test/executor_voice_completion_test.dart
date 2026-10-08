import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mineral/core/api/api_scope.dart';
import 'package:mineral/features/executor/screens/completion_screen.dart';
import 'package:mineral/l10n/app_localizations.dart';
import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';
import 'package:record/record.dart';

import 'helpers/backend_api_fixture.dart';
import 'helpers/recording_fixture.dart';

void main() {
  late TestRecorderPlatform platform;
  setUp(() {
    final original = RecordPlatform.instance;
    platform = TestRecorderPlatform();
    RecordPlatform.instance = platform;
    addTearDown(() => RecordPlatform.instance = original);
  });

  Future<void> tapVoice(
    WidgetTester tester,
    String label, {
    bool settle = true,
  }) async {
    await tester.ensureVisible(find.text(label));
    await tester.runAsync(() async {
      await tester.tap(find.text(label));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  Future<({DemoStore store, WorkOrder order})> mount(
    WidgetTester tester, {
    String language = 'ru',
    required Future<http.Response> Function(http.Request) handle,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = testApi(handle: handle)..client.setAccessToken('executor-jwt');
    final store = DemoStore();
    final order = store.assignedTo(1).first;
    order.status = OrderStatus.working;
    order.planned = true;
    order.faultCode = DemoStore.faultCodes.first;
    await tester.pumpWidget(
      ApiScope(
        api: api,
        child: MaterialApp(
          locale: Locale(language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CompletionScreen(store: store, order: order, employeeId: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await platform.states.close();
      store.dispose();
      api.dispose();
    });
    return (store: store, order: order);
  }

  final workField = find.byKey(const ValueKey('completion-work'));
  FilledButton submitButton(WidgetTester tester) => tester.widget<FilledButton>(
    find.widgetWithText(FilledButton, 'Отправить на проверку'),
  );

  testWidgets(
    'dictation uses executor JWT, appends work, persists and submits edited text',
    (tester) async {
      late Completer<http.Response> response;
      var requests = 0;
      final data = await mount(
        tester,
        handle: (request) async {
          requests++;
          expect(request.url.path, '/api/ai/transcribe');
          expect(request.method, 'POST');
          expect(request.headers['Authorization'], 'Bearer executor-jwt');
          final body = latin1.decode(request.bodyBytes);
          expect(body, contains('name="audio"'));
          expect(body, contains('RIFF'));
          response = Completer<http.Response>();
          return response.future;
        },
      );
      await tester.enterText(workField, 'Осмотрен насос.');
      await tapVoice(tester, 'Продиктовать выполненные работы');
      expect(submitButton(tester).onPressed, isNull);
      await tapVoice(tester, 'Остановить и распознать', settle: false);
      expect(find.text('Обработка голоса…'), findsOneWidget);
      expect(submitButton(tester).onPressed, isNull);
      await tester.runAsync(() async {
        response.complete(
          http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'data': {'transcription': '  Заменено уплотнение.  '},
              }),
            ),
            200,
            headers: {'content-type': 'text/html; charset=utf-8'},
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();
      expect(requests, 1);
      expect(find.text('Продиктовать выполненные работы'), findsOneWidget);
      expect(submitButton(tester).onPressed, isNotNull);
      final text = tester.widget<TextFormField>(workField).controller!.text;
      expect(text, 'Осмотрен насос. Заменено уплотнение.');
      // The transcript callback runs in runAsync along with the recorder;
      // its debounce timer therefore uses real time rather than fake time.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 450)),
      );
      await tester.pumpAndSettle();
      expect(data.store.executionDraft(1, data.order.number)!.work, text);
      await tester.enterText(workField, '$text Проверена герметичность.');
      await tester.tap(find.text('Отправить на проверку'));
      await tester.pumpAndSettle();
      expect(data.order.status, OrderStatus.review);
      expect(data.order.completedWork, '$text Проверена герметичность.');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'transcription error preserves typed work and re-enables submission',
    (tester) async {
      var requests = 0;
      await mount(
        tester,
        handle: (_) async {
          requests++;
          throw http.ClientException('offline');
        },
      );
      await tester.enterText(workField, 'Выполнен осмотр');
      await tapVoice(tester, 'Продиктовать выполненные работы');
      await tapVoice(tester, 'Остановить и распознать');
      expect(requests, 1);
      expect(
        tester.widget<TextFormField>(workField).controller!.text,
        'Выполнен осмотр',
      );
      expect(submitButton(tester).onPressed, isNotNull);
      expect(
        find.text(
          'Не удалось отправить голос на распознавание. Проверьте соединение и повторите.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('HTTP 200 HTML preserves typed work and re-enables submission', (
    tester,
  ) async {
    await mount(
      tester,
      handle: (_) async => http.Response(
        '<html><body>Gateway</body></html>',
        200,
        headers: {'content-type': 'text/html'},
      ),
    );
    await tester.enterText(workField, 'Выполнен осмотр');
    await tapVoice(tester, 'Продиктовать выполненные работы');
    await tapVoice(tester, 'Остановить и распознать');
    expect(
      tester.widget<TextFormField>(workField).controller!.text,
      'Выполнен осмотр',
    );
    expect(submitButton(tester).onPressed, isNotNull);
    expect(
      find.textContaining('Сервер распознавания вернул HTML вместо текста'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Kazakh dictation label and microphone refusal preserve manual entry',
    (tester) async {
      platform.permission = false;
      var requests = 0;
      await mount(
        tester,
        language: 'kk',
        handle: (_) async {
          requests++;
          return jsonResponse({'text': 'Орындалды'});
        },
      );
      await tester.enterText(workField, 'Жұмыстар орындалды');
      await tapVoice(tester, 'Орындалған жұмыстарды дауыспен енгізу');
      expect(platform.config, isNull);
      expect(requests, 0);
      expect(
        tester.widget<TextFormField>(workField).controller!.text,
        'Жұмыстар орындалды',
      );
      expect(
        find.text('Микрофонға рұқсат беріңіз немесе мәтін енгізіңіз.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'long dictated text is retained and must be edited before submission',
    (tester) async {
      final longText = List.filled(510, 'а').join();
      final data = await mount(
        tester,
        handle: (_) async => jsonResponse({'text': longText}),
      );
      await tapVoice(tester, 'Продиктовать выполненные работы');
      await tapVoice(tester, 'Остановить и распознать');
      expect(
        tester.widget<TextFormField>(workField).controller!.text,
        longText,
      );
      await tester.tap(find.text('Отправить на проверку'));
      await tester.pumpAndSettle();
      expect(data.order.status, OrderStatus.working);
      expect(
        find.text('Выполненные работы — не больше 500 символов'),
        findsOneWidget,
      );
    },
  );
}
