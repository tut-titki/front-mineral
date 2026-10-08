import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/features/auth/data/pin_repository.dart';
import 'package:mineral/features/auth/data/pin_storage.dart';

class MemoryPinStorage implements PinStorage {
  final records = <String, PinRecord>{};
  @override
  Future<PinRecord?> read(String account) async => records[account];
  @override
  Future<void> write(String account, PinRecord record) async =>
      records[account] = record;
  @override
  Future<void> delete(String account) async => records.remove(account);
  @override
  Future<void> close() async {}
}

class MemoryPinKeyStorage implements PinKeyStorage {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String key) async => value = key;
}

PinRepository testPinRepository() => PinRepository(
  storage: MemoryPinStorage(),
  keyStorage: MemoryPinKeyStorage(),
);

Future<void> enterPin(WidgetTester tester, String pin) async {
  for (final digit in pin.split('')) {
    final key = find.byKey(ValueKey('pin-key-$digit'));
    await tester.ensureVisible(key);
    await tester.tap(key);
    await tester.pump();
  }
  await tester.pumpAndSettle();
}
