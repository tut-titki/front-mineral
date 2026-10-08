import 'dart:async';
import 'dart:typed_data';

import 'package:record/record.dart';

class TestRecorderPlatform extends RecordPlatform {
  final states = StreamController<RecordState>.broadcast();
  final audio = StreamController<Uint8List>();
  RecordConfig? config;
  bool permission = true;
  Object? startError;

  @override
  Future<void> create(String recorderId) async {}
  @override
  Future<bool> hasPermission(String recorderId, {bool request = true}) async =>
      permission;
  @override
  Stream<RecordState> onStateChanged(String recorderId) => states.stream;
  @override
  Future<Stream<Uint8List>> startStream(
    String recorderId,
    RecordConfig value,
  ) async {
    if (startError != null) throw startError!;
    config = value;
    return audio.stream;
  }

  @override
  Future<String?> stop(String recorderId) async {
    // The final audio chunk must reach the request even when stop is called.
    audio.add(Uint8List.fromList([0, 0, 255, 127]));
    await audio.close();
    return null;
  }

  @override
  Future<void> cancel(String recorderId) async {}
  @override
  Future<void> dispose(String recorderId) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
