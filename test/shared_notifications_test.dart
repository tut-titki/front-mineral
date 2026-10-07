import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/features/auth/data/auth_session.dart' as auth;
import 'package:mineral/features/notifications/data/notifications_api.dart';
import 'package:mineral/features/notifications/screens/notifications_screen.dart';
import 'package:mineral/l10n/app_localizations.dart';
import 'helpers/backend_api_fixture.dart';

NotificationApiModel notice(
  int id, {
  String type = 'NEW_ORDER',
  int? orderId,
  bool read = false,
}) => NotificationApiModel(
  id: id,
  userId: 5,
  workOrderId: orderId,
  type: type,
  title: 'Наряд $id',
  message: 'Сервер: просрочен на 45 мин. Статус в работе с 09:20.',
  isRead: read,
  createdAt: DateTime.utc(2026, 10, 5, 17, id),
);
Widget host(Widget child) => MaterialApp(
  locale: const Locale('kk'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

class NotificationSource extends ChangeNotifier {
  List<NotificationApiModel> items = [];
  void update(List<NotificationApiModel> next) {
    items = next;
    notifyListeners();
  }
}

void main() {
  test(
    'master API rejects an unconfirmed read instead of reporting success',
    () async {
      final api = testApi(handle: (_) async => jsonResponse({'updated': 0}));
      addTearDown(api.dispose);
      await expectLater(api.notifications.markRead(2), throwsException);
    },
  );
  testWidgets(
    'standalone sorts latest first, groups prefixes and preserves server text',
    (tester) async {
      await tester.pumpWidget(
        host(
          NotificationsScreen(
            standalone: true,
            load: () async => [notice(1), notice(2, type: 'LONG_OVERDUE_4')],
            markRead: (_) async {},
            onOrder: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.text('Наряд 2')).dy,
        lessThan(tester.getTopLeft(find.text('Наряд 1')).dy),
      );
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.text(notice(1).message), findsNWidgets(2));
      expect(find.byTooltip('Жаңарту'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('read without work order works; unknown types remain visible', (
    tester,
  ) async {
    var reads = 0;
    var opens = 0;
    var item = notice(1, type: 'FUTURE_TYPE');
    await tester.pumpWidget(
      host(
        NotificationsScreen(
          standalone: true,
          load: () async => [item],
          markRead: (id) async {
            reads++;
            item = item.asRead();
          },
          onOrder: (_) => opens++,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(item.title));
    await tester.pumpAndSettle();
    await tester.tap(find.text(item.title));
    await tester.pumpAndSettle();
    expect(reads, 1);
    expect(opens, 0);
    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'duplicate tap cannot duplicate PATCH or opening; role callback gets API ID',
    (tester) async {
      final completion = Completer<void>();
      var reads = 0;
      final opened = <int>[];
      await tester.pumpWidget(
        host(
          NotificationsScreen(
            standalone: true,
            load: () async => [notice(2, orderId: 773)],
            markRead: (_) {
              reads++;
              return completion.future;
            },
            onOrder: (id) => opened.add(id),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Наряд 2'));
      await tester.pump();
      await tester.tap(find.text('Наряд 2'));
      expect(reads, 1);
      completion.complete();
      await tester.pumpAndSettle();
      expect(opened, [773]);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('failed read preserves unread state and still opens order', (
    tester,
  ) async {
    final opened = <int>[];
    await tester.pumpWidget(
      host(
        NotificationsScreen(
          standalone: true,
          load: () async => [notice(2, orderId: 773)],
          markRead: (_) async =>
              throw const auth.ApiException(503, 'Нет связи'),
          onOrder: (id) => opened.add(id),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Наряд 2'));
    await tester.pumpAndSettle();
    expect(opened, [773]);
    expect(find.text('Нет связи'), findsOneWidget);
    final card = tester.widget<Material>(
      find
          .ancestor(of: find.byType(ListTile), matching: find.byType(Material))
          .first,
    );
    expect(card.color, const Color(0xFFEAF3FC));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'live source survives stale GET; cached notifications survive network failure',
    (tester) async {
      final source = NotificationSource()..items = [notice(1)];
      final fetch = Completer<List<NotificationApiModel>>();
      var loads = 0;
      addTearDown(source.dispose);
      await tester.pumpWidget(
        host(
          NotificationsScreen(
            standalone: true,
            source: source,
            snapshot: () => source.items,
            load: () {
              loads++;
              return fetch.future;
            },
            markRead: (_) async {},
            onOrder: (_) {},
          ),
        ),
      );
      await tester.pump();
      source.update([notice(2), notice(1)]);
      await tester.pump();
      fetch.complete([notice(1)]);
      await tester.pumpAndSettle();
      expect(find.text('Наряд 2'), findsOneWidget);
      expect(loads, 1);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        host(
          NotificationsScreen(
            standalone: true,
            source: source,
            snapshot: () => source.items,
            load: () async => throw const auth.ApiException(503, 'Нет связи'),
            markRead: (_) async {},
            onOrder: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Наряд 2'), findsOneWidget);
      expect(find.text('Нет связи'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
