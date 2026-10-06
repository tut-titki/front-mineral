import 'dart:async';
import "package:socket_io_client/socket_io_client.dart" as io;
import "package:mineral/features/auth/data/auth_session.dart";

class ExecutorRealtime {
  final AuthSession session;
  final Future<void> Function() onConnected;
  final Future<void> Function(Map<String, dynamic>) onOrderChanged;
  final void Function(Map<String, dynamic>) onNotification;

  ExecutorRealtime({
    required this.session,
    required this.onConnected,
    required this.onOrderChanged,
    required this.onNotification,
  });

  io.Socket? _socket;

  bool _disposed = false;

  void connect() {
    if (_disposed || !session.authenticated) return;
    disconnect();

    final socket = io.io(
      session.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': session.token})
          .disableAutoConnect()
          .enableForceNew()
          .build(),
    );

    _socket = socket;

    socket.onConnect((_) {
      unawaited(_run(onConnected));
    });

    socket.onConnectError((error) {
      final message = error is Map ? error['message'] : error.toString();

      if (message == "unauthorized") {
        disconnect();
        unawaited(_run(session.expire));
      }
    });

    socket.on('work-order:changed', (data) {
      final order = _asMap(data);
      if (order == null) return;
      unawaited(_run(() => onOrderChanged(order)));
    });
    socket.on('notification:new', (data) {
      final notification = _asMap(data);
      if (notification == null) return;

      onNotification(notification);
    });
    socket.connect();
  }

  Map<String, dynamic>? _asMap(dynamic data) {
    if (data is! Map) return null;
    return Map<String, dynamic>.from(data);
  }

  Future<void> _run(Future<void> Function() callback) async {
    if (_disposed) return;
    try {
      await callback();
    } catch (_) {
      // Ошибка обновления не должна остановить обработку следующих событий.
      // Репозиторий должен сохранить ошибку для отображения в интерфейсе.
    }
  }

  void disconnect() {
    final socket = _socket;
    _socket = null;
    socket?.dispose();
  }

  void dispose() {
    _disposed = true;
    disconnect();
  }
}
