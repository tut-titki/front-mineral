import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/features/assistant/screens/master_chat_screen.dart';
import 'package:mineral/features/master/screens/master_shell.dart';
import 'package:mineral/l10n/app_localizations.dart';
import 'helpers/backend_api_fixture.dart';

Widget host(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

void main() {
  testWidgets(
    'chat orders history, preserves drafts on refresh and sends once with retry',
    (tester) async {
      var gets = 0;
      var posts = 0;
      final pending = Completer<void>();
      final api = testApi(
        handle: (request) async {
          if (request.url.path == '/api/assistant/history') {
            gets++;
            return jsonResponse([
              {
                'role': 'assistant',
                'content': 'Свободен электрик',
                'internal': 'hidden field',
              },
              {'role': 'user', 'content': 'Кто на смене?'},
            ]);
          }
          if (request.url.path == '/api/assistant/chat') {
            posts++;
            expect(jsonDecode(request.body), {'message': 'Что просрочено?'});
            if (posts == 1) {
              await pending.future;
              return jsonResponse({'message': 'Попробуйте снова'}, status: 503);
            }
            return jsonResponse({
              'answer': 'Просрочен наряд №147',
              'intent': {'intent': 'OVERDUE'},
              'data': [],
            });
          }
          return null;
        },
      );
      addTearDown(api.dispose);
      await tester.pumpWidget(host(Scaffold(body: MasterChatScreen(api: api))));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.text('Кто на смене?')).dy,
        lessThan(tester.getTopLeft(find.text('Свободен электрик')).dy),
      );
      expect(find.text('hidden field'), findsNothing);
      await tester.enterText(find.byType(TextFormField), 'Что просрочено?');
      final refresh = tester
          .state<RefreshIndicatorState>(find.byType(RefreshIndicator))
          .show();
      await tester.pumpAndSettle();
      await refresh;
      expect(gets, 2);
      expect(posts, 0);
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        'Что просрочено?',
      );
      final send = find.byKey(const ValueKey('chat-send'));
      await tester.ensureVisible(send);
      await tester.tap(send);
      await tester.pump();
      expect(tester.widget<IconButton>(send).onPressed, isNull);
      expect(posts, 1);
      expect(find.text('Ассистент печатает…'), findsOneWidget);
      pending.complete();
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        'Что просрочено?',
      );
      final retry = find.byKey(const ValueKey('chat-send'));
      expect(tester.widget<IconButton>(retry).tooltip, 'Повторить');
      await tester.ensureVisible(retry);
      await tester.tap(retry);
      await tester.pumpAndSettle();
      expect(posts, 2);
      expect(find.text('Просрочен наряд №147'), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        isEmpty,
      );
      expect(tester.takeException(), isNull);
    },
  );

  for (final width in [320.0, 1400.0]) {
    testWidgets('master opens chat without AI control at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = testApi();
      addTearDown(api.dispose);
      await tester.pumpWidget(host(MasterShell(api: api)));
      await tester.pumpAndSettle();
      final chat = width < 1000
          ? find.byType(NavigationDestination).at(3)
          : find.widgetWithText(ListTile, 'Чат');
      await tester.tap(chat);
      await tester.pumpAndSettle();
      expect(find.byType(MasterChatScreen), findsOneWidget);
      expect(find.text('Начните диалог с ассистентом'), findsOneWidget);
      expect(find.text('ИИ-контроль'), findsNothing);
      expect(find.text('Контроль нарядов'), findsNothing);
      expect(find.byIcon(Icons.refresh), findsNothing);
      await tester.enterText(find.byType(TextFormField), 'x');
      final send = find.byKey(const ValueKey('chat-send'));
      expect(
        find.descendant(of: find.byType(TextFormField), matching: send),
        findsOneWidget,
      );
      expect(tester.widget<IconButton>(send).color, const Color(0xFF01408B));
      await tester.ensureVisible(send);
      await tester.tap(send);
      await tester.pumpAndSettle();
      expect(find.text('Введите от 2 до 1000 символов'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
