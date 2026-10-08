import '../features/references/data/reference_cache.dart';
import '../features/references/data/reference_storage.dart';
import 'dart:async';
import '../features/orders/screens/order_detail_screen.dart';
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
import 'package:mineral/features/executor/data/executor_repository.dart';
import 'package:mineral/features/executor/screens/executor_screen.dart';

import 'package:mineral/features/master/screens/master_shell.dart';

import 'package:mineral/features/splash/screens/splash_screen.dart';

import 'package:mineral/l10n/app_locale.dart';
import 'package:mineral/l10n/app_localizations.dart';
import 'package:mineral/l10n/ui_localization.dart';

import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';

class MainApp extends StatefulWidget {
  const MainApp({
    super.key,
    this.demoMode = false,
    this.session,
    this.referenceStorage,
    this.apiServices,
  });

  final bool demoMode;
  final AuthSession? session;
  final ReferenceStorage? referenceStorage;
  final ApiServices? apiServices;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  // MARK: - Services

  final notificationSound = NotificationSound();

  final _navigatorKey = GlobalKey<NavigatorState>();

  late final AuthSession _session = widget.session ?? AuthSession();

  late final ApiServices api =
      widget.apiServices ??
      ApiServices(
        baseUrl: _session.baseUrl,
        referenceCache: ReferenceCache(
          scope: _session.baseUrl,
          fetch: _session.requestList,
          storage: widget.referenceStorage,
        ),
      );

  late final store = DemoStore(
    onOrderChanged: notificationSound.play,
    draftStorage: createExecutionDraftStorage(),
  );

  bool _wasAuthenticated = false;
  ApiExecutorRepository? _executorStore;
  int? _executorUserId;
  PushNotificationService? _push;
  int? _pendingPushOrderId;
  int? _pendingSuggestedExecutorId;
  bool _openingPush = false;
  bool _startupActive = true;
  Future<AuthUser?>? _startupSession;

  Future<AuthUser?> _prepareStartup() async {
    final user = await _session.restore();
    if (!mounted || user == null) return user;
    appLocale.value = Locale(user.language == 'kk' ? 'kk' : 'ru');
    if (user.role == 'EXECUTOR') {
      final repository = _apiExecutorStore();
      unawaited(repository.refreshExecutor(user.id).catchError((Object _) {}));
    }
    return user;
  }

  void _pushOrderTapped(int id, {int? suggestedExecutorId}) {
    _pendingPushOrderId = id;
    _pendingSuggestedExecutorId = suggestedExecutorId;
    unawaited(_openPushOrder());
  }

  Future<void> _openPushOrder() async {
    if (_startupActive || _openingPush || !mounted || !_session.authenticated) {
      return;
    }
    if (!{'EXECUTOR', 'MASTER'}.contains(_session.user?.role)) {
      _pendingPushOrderId = null;
      _pendingSuggestedExecutorId = null;
      return;
    }
    final id = _pendingPushOrderId;
    if (id == null) return;
    _openingPush = true;
    _pendingPushOrderId = null;
    final suggestedId = _pendingSuggestedExecutorId;
    _pendingSuggestedExecutorId = null;
    final userId = _session.user!.id;
    try {
      // Login/session restoration must finish its own navigation first.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted || _session.user?.id != userId) return;
      if (_session.user?.role == 'MASTER') {
        final navigator = _navigatorKey.currentState;
        if (navigator == null) {
          _pendingPushOrderId = id;
          _pendingSuggestedExecutorId = suggestedId;
          return;
        }
        unawaited(
          navigator.push(
            MaterialPageRoute<void>(
              builder: (_) => OrderDetailScreen(
                api: api,
                orderId: id,
                suggestedExecutorId: suggestedId,
              ),
            ),
          ),
        );
        return;
      }
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
                    ? uiText(context, error.message)
                    : AppLocalizations.of(context).pushOrderOpenFailed,
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
    return _executorStore = ApiExecutorRepository(
      api: ExecutorApi(_session, referencesCache: api.references.cache),
    )..startRealtime();
  }

  String? _referenceToken;

  void _sessionChanged() {
    final authenticated = _session.authenticated;

    final user = _session.user;

    // Синхронизируем JWT существующей
    // AuthSession с новым ApiClient.
    final token = _session.accessToken;

    if (authenticated && token != null && token.trim().isNotEmpty) {
      api.setAccessToken(token);
      if (!widget.demoMode && _referenceToken != token && user != null) {
        _referenceToken = token;
        api.references.cache.setScope('${api.baseUrl}|${user.id}');
        unawaited(
          api.references.refreshAll().catchError((Object error) {
            debugPrint('Reference refresh failed: $error');
          }),
        );
      }
    } else {
      api.clearAccessToken();
      _referenceToken = null;
      api.references.cache.setScope('${api.baseUrl}|signed-out');
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
    api.client.onUnauthorized = _apiUnauthorized;
    api.realtime.onUnauthorized = _apiUnauthorized;
    if (widget.demoMode) store.addScreenshotOrders();
    _session.addListener(_sessionChanged);
    if (!widget.demoMode) {
      _push = PushNotificationService(
        session: _session,
        onOrderTap: _pushOrderTapped,
        onOrderSuggestion: (orderId, executorId) =>
            _pushOrderTapped(orderId, suggestedExecutorId: executorId),
      );
      unawaited(_push!.initialize());
    }
    PhotoPickerService.instance.recoverLostPhotos();
    _sessionChanged();
    if (!widget.demoMode) {
      _startupSession = _prepareStartup();
      // Keep startup failures for SessionGate without an unhandled error while
      // the splash animation is still visible.
      unawaited(_startupSession!.then<void>((_) {}, onError: (Object _) {}));
    }
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

  void _apiUnauthorized(String token) {
    if (!mounted || _session.accessToken != token) return;
    unawaited(
      _session.expire().catchError((Object error) {
        debugPrint('Session expiration failed: $error');
      }),
    );
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

          onGenerateTitle: (context) =>
              AppLocalizations.of(context).companyName,

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

              final ExecutorRepository repository = widget.demoMode
                  ? store
                  : _apiExecutorStore();
              return ExecutorScreen(
                store: repository,
                refreshOnOpen:
                    widget.demoMode ||
                    (!(repository as ApiExecutorRepository).hasLoaded &&
                        !repository.isLoading),
                employeeId: widget.demoMode
                    ? (ModalRoute.of(context)?.settings.arguments as int? ?? 1)
                    : _session.user!.id,
              );
            },
          },

          // MARK: Initial screen
          home: SplashScreen(
            onFinished: () {
              _startupActive = false;
              if (_pendingPushOrderId != null) unawaited(_openPushOrder());
            },
            nextScreen: widget.demoMode
                ? const LoginScreen()
                : SessionGate(session: _session, restoration: _startupSession),
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
