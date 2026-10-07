import 'dart:async';
import 'package:mineral/core/services/push_notification_service.dart';
import 'package:mineral/features/executor/screens/executor_order_loader.dart';
import 'package:mineral/features/executor/models/executor_order_dto.dart';

import 'package:flutter/material.dart';

import 'package:mineral/core/api/api_services.dart';
import 'package:mineral/core/services/notification_sound.dart';
import 'package:mineral/core/services/photo_picker_service.dart';
import 'package:mineral/core/theme/app_theme.dart';

import 'package:mineral/features/auth/data/auth_session.dart';
import 'package:mineral/features/auth/screens/login_screen.dart';
import 'package:mineral/features/auth/screens/session_gate.dart';
import 'package:mineral/features/auth/widgets/auth_scope.dart';

import 'package:mineral/features/executor/data/execution_draft_storage.dart';
import 'package:mineral/features/executor/data/api_executor_repository.dart';
import 'package:mineral/features/executor/data/executor_api.dart';
import 'package:mineral/features/executor/screens/executor_screen.dart';

import 'package:mineral/features/master/screens/master_shell.dart';

import 'package:mineral/features/splash/screens/splash_screen.dart';

import 'package:mineral/l10n/app_locale.dart';
import 'package:mineral/l10n/app_localizations.dart';

import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key, this.demoMode = false, this.session});

  final bool demoMode;
  final AuthSession? session;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  // MARK: - Services

  final notificationSound = NotificationSound();

  final _navigatorKey = GlobalKey<NavigatorState>();

  late final AuthSession _session = widget.session ?? AuthSession();

  late final ApiServices api = ApiServices(baseUrl: _session.baseUrl);

  late final store = DemoStore(
    onOrderChanged: notificationSound.play,
    draftStorage: createExecutionDraftStorage(),
  );

  bool _wasAuthenticated = false;
  ApiExecutorRepository? _executorStore;
  int? _executorUserId;
  PushNotificationService? _push;
  int? _pendingPushOrderId;
  bool _openingPush = false;

  void _pushOrderTapped(int id) {
    _pendingPushOrderId = id;
    unawaited(_openPushOrder());
  }

  Future<void> _openPushOrder() async {
    if (_openingPush || !mounted || !_session.authenticated) return;
    if (_session.user?.role != 'EXECUTOR') {
      _pendingPushOrderId = null;
      return;
    }
    final id = _pendingPushOrderId;
    if (id == null) return;
    _openingPush = true;
    _pendingPushOrderId = null;
    final userId = _session.user!.id;
    try {
      // Login/session restoration must finish its own navigation first.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted || _session.user?.id != userId) return;
      final repository = _apiExecutorStore();
      final dto = await repository.api.loadOrder(id);
      if (dto.assigneeId != userId) {
        throw const ApiException(403, 'Это не ваш наряд');
      }
      if (!mounted || _session.user?.id != userId) return;
      final navigator = _navigatorKey.currentState;
      if (navigator == null) {
        _pendingPushOrderId = id;
        return;
      }
      unawaited(
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => ExecutorOrderLoader(
              store: repository,
              employeeId: userId,
              order: dto.toWorkOrder(),
            ),
          ),
        ),
      );
    } catch (error) {
      if (mounted && _session.user?.id == userId) {
        final context = _navigatorKey.currentContext;
        if (context != null && context.mounted) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(
              content: Text(
                error is ApiException
                    ? error.message
                    : 'Не удалось открыть наряд',
              ),
            ),
          );
        }
      }
    } finally {
      _openingPush = false;
      if (_pendingPushOrderId != null && mounted && _session.authenticated) {
        unawaited(_openPushOrder());
      }
    }
  }

  ApiExecutorRepository _apiExecutorStore() {
    final userId = _session.user!.id;
    if (_executorStore != null && _executorUserId == userId) {
      return _executorStore!;
    }
    _executorStore?.dispose();
    _executorUserId = userId;
    return _executorStore = ApiExecutorRepository(api: ExecutorApi(_session))
      ..startRealtime();
  }

  void _sessionChanged() {
    final authenticated = _session.authenticated;

    final user = _session.user;

    // Синхронизируем JWT существующей
    // AuthSession с новым ApiClient.
    final token = _session.accessToken;

    if (authenticated && token != null && token.trim().isNotEmpty) {
      api.setAccessToken(token);
    } else {
      api.clearAccessToken();
    }

    // DemoStore используется только в деморежиме.
    if (widget.demoMode && user != null) {
      store.sessionEmployee = Employee(
        id: user.id,
        name: user.fullName,
        specialty: user.specialty,
        grade: user.grade,
        brigade: user.brigadeId == null ? '' : '${user.brigadeId}',
        rating: 0,
        onShift: user.isOnShift,
      );
    }

    // Если пользователь был авторизован,
    // но сессия закончилась — возвращаем
    // на страницу входа.
    if (_wasAuthenticated && !authenticated) {
      final previous = _executorStore;
      _executorStore = null;
      _executorUserId = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => previous?.dispose());
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (_) => false,
      );
    }

    _wasAuthenticated = authenticated;
    if (authenticated && _pendingPushOrderId != null) {
      unawaited(_openPushOrder());
    }
  }

  // MARK: - Lifecycle

  @override
  void initState() {
    super.initState();
    if (widget.demoMode) store.addScreenshotOrders();
    _session.addListener(_sessionChanged);
    if (!widget.demoMode) {
      _push = PushNotificationService(
        session: _session,
        onOrderTap: _pushOrderTapped,
      );
      unawaited(_push!.initialize());
    }
    PhotoPickerService.instance.recoverLostPhotos();

    // Важно для случая, когда MainApp
    // получил уже восстановленную/готовую
    // AuthSession.
    _sessionChanged();
  }

  @override
  void dispose() {
    _session.removeListener(_sessionChanged);
    _push?.dispose();

    if (widget.session == null) {
      _session.dispose();
    }

    api.dispose();

    _executorStore?.dispose();

    store.dispose();

    unawaited(notificationSound.dispose());

    super.dispose();
  }

  // MARK: - Build

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: appLocale,
      builder: (context, locale, _) {
        final app = MaterialApp(
          navigatorKey: _navigatorKey,

          locale: locale ?? const Locale('ru'),

          localizationsDelegates: AppLocalizations.localizationsDelegates,

          supportedLocales: AppLocalizations.supportedLocales,

          debugShowCheckedModeBanner: false,

          onGenerateTitle: (context) => 'Костанайские минералы',

          theme: buildAppTheme(),

          // MARK: Routes
          routes: {
            '/login': (_) => const LoginScreen(),

            // MARK: Master
            '/master': (_) {
              if (!widget.demoMode &&
                  (!_session.authenticated ||
                      _session.user?.role != 'MASTER')) {
                return const LoginScreen();
              }

              return MasterShell(api: api);
            },

            // MARK: Executor
            '/executor': (context) {
              if (!widget.demoMode &&
                  (!_session.authenticated ||
                      _session.user?.role != 'EXECUTOR')) {
                return const LoginScreen();
              }

              return ExecutorScreen(
                store: widget.demoMode ? store : _apiExecutorStore(),
                employeeId: widget.demoMode
                    ? (ModalRoute.of(context)?.settings.arguments as int? ?? 1)
                    : _session.user!.id,
              );
            },
          },

          // MARK: Initial screen
          home: SplashScreen(
            nextScreen: widget.demoMode
                ? const LoginScreen()
                : SessionGate(session: _session),
          ),
        );

        if (widget.demoMode) {
          return app;
        }

        return AuthScope(session: _session, child: app);
      },
    );
  }
}
