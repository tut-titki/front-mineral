import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// One socket per API session; REST screens reload instead of trusting payloads.
class MasterRealtimeService {
  MasterRealtimeService(this.baseUrl);
  final String baseUrl;
  void Function(String token)? onUnauthorized;
  final _changes = StreamController<void>.broadcast();
  final connected = ValueNotifier<bool>(false);
  Stream<void> get changes => _changes.stream;
  io.Socket? _socket;
  String? _token;
  bool _disposed = false;

  void setToken(String? token) {
    if (_disposed || token == _token) return;
    _token = token;
    _socket?.dispose();
    _socket = null;
    connected.value = false;
    if (token == null || token.isEmpty) return;
    final socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableForceNew()
          .disableAutoConnect()
          .build(),
    );
    _socket = socket;
    socket.onConnect((_) {
      if (_disposed || _socket != socket) return;
      connected.value = true;
      // Includes reconnect: missed events are never replayed by the server.
      _changes.add(null);
    });
    socket.onDisconnect((_) {
      if (!_disposed && _socket == socket) connected.value = false;
    });
    socket.onConnectError((error) {
      if (_disposed || _socket != socket) return;
      connected.value = false;
      final message = error is Map ? error['message'] : error.toString();
      if (message == 'unauthorized') onUnauthorized?.call(token);
    });
    for (final event in ['work-order:changed', 'notification:new']) {
      socket.on(event, (_) {
        if (!_disposed && _socket == socket) _changes.add(null);
      });
    }
    socket.connect();
  }

  void invalidate() {
    if (!_disposed) _changes.add(null);
  }

  void dispose() {
    _disposed = true;
    _socket?.dispose();
    connected.dispose();
    unawaited(_changes.close());
  }
}
