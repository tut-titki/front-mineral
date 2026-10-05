import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'models.dart';

class NotificationSound {
  AudioPlayer? _player;
  bool _disposed = false;
  Future<void> _pending = Future.value();

  void play(OrderEventKind kind) {
    if (_disposed) return;
    _pending = _pending.then((_) async {
      if (_disposed) return;
      try {
        final player = _player ??= AudioPlayer();
        await player.stop();
        if (_disposed) return;
        await player.play(
          AssetSource(
            kind == OrderEventKind.issued
                ? 'order_created.wav'
                : 'order_changed.wav',
          ),
          volume: .6,
        );
      } on Exception catch (error) {
        debugPrint('Notification sound unavailable: $error');
      }
    });
  }

  Future<void> dispose() async {
    _disposed = true;
    await _pending;
    await _player?.dispose();
  }
}
