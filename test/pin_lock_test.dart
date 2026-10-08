import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mineral/features/auth/data/auth_session.dart';
import 'package:mineral/features/auth/data/pin_lock_controller.dart';
import 'package:mineral/features/auth/data/pin_repository.dart';
import 'package:mineral/features/auth/data/pin_storage.dart';
import 'package:mineral/features/auth/widgets/pin_lock_gate.dart';
import 'package:mineral/l10n/app_localizations.dart';

import 'support/pin_test_helpers.dart';

AuthSession testSession() => AuthSession(
  baseUrl: 'https://backend.test',
  storage: MemoryTokenStorage(),
  client: MockClient((request) async {
    final profile = {'id': 1, 'fullName': 'Мастер', 'role': 'MASTER'};
    return http.Response(
      jsonEncode(
        request.url.path.endsWith('/login')
            ? {'token': 'jwt', 'user': profile}
            : profile,
      ),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }),
);

Future<void> settleController(PinLockController controller) async {
  for (var i = 0; i < 20 && controller.status == PinLockStatus.loading; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

Widget app(PinLockController controller) => MaterialApp(
  locale: const Locale('ru'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (_, child) => PinLockGate(controller: controller, child: child!),
  home: const Scaffold(body: TextField(key: ValueKey('private-field'))),
);

void main() {
  testWidgets(
    'password login requires PIN creation and matching confirmation',
    (tester) async {
      final session = testSession();
      final repo = testPinRepository();
      final controller = PinLockController(session: session, repository: repo);
      await tester.pumpWidget(app(controller));
      expect(find.byKey(const ValueKey('private-field')), findsOneWidget);
      await session.login('+77012345678', 'password');
      await tester.pumpAndSettle();
      expect(find.text('Создайте ПИН-код'), findsOneWidget);
      expect(find.byKey(const ValueKey('private-field')), findsNothing);
      await enterPin(tester, '0123');
      expect(find.text('Повторите ПИН-код'), findsOneWidget);
      expect(await repo.read('https://backend.test|1'), isNull);
      await enterPin(tester, '0124');
      expect(
        find.text('ПИН-коды не совпадают. Создайте код заново'),
        findsOneWidget,
      );
      expect(controller.canAccess, isFalse);
      await enterPin(tester, '0123');
      await enterPin(tester, '0123');
      expect(controller.canAccess, isTrue);
      expect(find.byKey(const ValueKey('private-field')), findsOneWidget);
      expect(await repo.read('https://backend.test|1'), isNotNull);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      session.dispose();
    },
  );

  testWidgets(
    'restart and background require PIN while preserving the open form',
    (tester) async {
      final session = testSession();
      final repo = testPinRepository();
      await repo.create('https://backend.test|1', '1234');
      await session.login('+77012345678', 'password');
      var controller = PinLockController(session: session, repository: repo);
      await tester.pumpWidget(app(controller));
      await tester.pumpAndSettle();
      expect(find.text('Введите ПИН-код'), findsOneWidget);
      await enterPin(tester, '9999');
      expect(find.text('Неверный ПИН-код'), findsOneWidget);
      expect(find.byKey(const ValueKey('private-field')), findsNothing);
      await enterPin(tester, '1234');
      await tester.enterText(
        find.byKey(const ValueKey('private-field')),
        'Черновик наряда',
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.byKey(const ValueKey('pin-privacy-cover')), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(controller.canAccess, isTrue);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text('Введите ПИН-код'), findsOneWidget);
      expect(find.text('Черновик наряда'), findsNothing);
      await enterPin(tester, '1234');
      expect(find.text('Черновик наряда'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      controller = PinLockController(session: session, repository: repo);
      await tester.pumpWidget(app(controller));
      await tester.pumpAndSettle();
      expect(find.text('Введите ПИН-код'), findsOneWidget);
      expect(controller.canAccess, isFalse);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      session.dispose();
    },
  );

  test('forgot PIN keeps it until a successful new password login', () async {
    final session = testSession();
    final repo = testPinRepository();
    await repo.create('https://backend.test|1', '1234');
    await session.login('+77012345678', 'password');
    final controller = PinLockController(session: session, repository: repo);
    await settleController(controller);
    await controller.forgotPin();
    expect(session.authenticated, isFalse);
    expect(await repo.read('https://backend.test|1'), isNotNull);
    await session.login('+77012345678', 'password');
    await settleController(controller);
    expect(controller.status, PinLockStatus.create);
    expect(await repo.read('https://backend.test|1'), isNull);
    expect(await controller.submit('4321'), isTrue);
    expect(
      (await repo.verify('https://backend.test|1', '1234')).status,
      PinVerificationStatus.incorrect,
    );
    controller.dispose();
    session.dispose();
  });

  test(
    'refreshing user profile does not unlock or repeatedly lock a session',
    () async {
      final session = testSession();
      final repo = testPinRepository();
      await session.login('+77012345678', 'password');
      final controller = PinLockController(session: session, repository: repo);
      await settleController(controller);
      await session.refreshUser();
      expect(controller.canAccess, isFalse);
      await controller.submit('1234');
      await session.refreshUser();
      expect(controller.canAccess, isTrue);
      controller.dispose();
      session.dispose();
    },
  );

  test(
    'late verification cannot unlock an app locked again in the background',
    () async {
      final session = testSession();
      final storage = DelayedPinStorage();
      final repo = PinRepository(
        storage: storage,
        keyStorage: MemoryPinKeyStorage(),
      );
      await repo.create('https://backend.test|1', '1234');
      await session.login('+77012345678', 'password');
      final controller = PinLockController(session: session, repository: repo);
      await settleController(controller);
      storage.delay = Completer<void>();
      final result = controller.submit('1234');
      await Future<void>.delayed(Duration.zero);
      controller.lock();
      storage.delay!.complete();
      expect(await result, isFalse);
      await settleController(controller);
      expect(controller.status, PinLockStatus.unlock);
      expect(controller.canAccess, isFalse);
      controller.dispose();
      session.dispose();
    },
  );

  testWidgets(
    'storage failure blocks protected routes and offers retry or password login',
    (tester) async {
      final session = testSession();
      await session.login('+77012345678', 'password');
      final controller = PinLockController(
        session: session,
        repository: PinRepository(
          storage: BrokenPinStorage(),
          keyStorage: MemoryPinKeyStorage(),
        ),
      );
      await tester.pumpWidget(app(controller));
      await tester.pumpAndSettle();
      expect(controller.status, PinLockStatus.storageError);
      expect(find.byKey(const ValueKey('private-field')), findsNothing);
      expect(find.text('Забыли ПИН-код?'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      session.dispose();
    },
  );
}

class DelayedPinStorage extends MemoryPinStorage {
  Completer<void>? delay;
  @override
  Future<PinRecord?> read(String account) async {
    await delay?.future;
    return super.read(account);
  }
}

class BrokenPinStorage extends MemoryPinStorage {
  @override
  Future<PinRecord?> read(String account) async =>
      throw StateError('database unavailable');
}
