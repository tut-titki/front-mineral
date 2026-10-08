import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'pin_storage.dart';

abstract interface class PinKeyStorage {
  Future<String?> read();
  Future<void> write(String key);
}

class SecurePinKeyStorage implements PinKeyStorage {
  static const _key = 'mineral.auth.pin.hmac-key';
  final _storage = const FlutterSecureStorage();

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String key) => _storage.write(key: _key, value: key);
}

enum PinVerificationStatus { matched, incorrect, blocked }

class PinVerification {
  const PinVerification(this.status, {this.lockedUntil});
  final PinVerificationStatus status;
  final DateTime? lockedUntil;
}

class PinRepository {
  PinRepository({
    required this.storage,
    required this.keyStorage,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final PinStorage storage;
  final PinKeyStorage keyStorage;
  final DateTime Function() _now;
  Future<void> _pending = Future.value();

  // Serializing also prevents a background lock racing with PIN creation.
  Future<T> _serial<T>(Future<T> Function() action) {
    final result = _pending.then((_) => action());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<PinRecord?> read(String account) =>
      _serial(() => storage.read(account));

  static bool isValid(String pin) =>
      pin.length == 4 && RegExp(r'^[0-9]{4}$').hasMatch(pin);

  static String _random(int length) {
    final random = Random.secure();
    return base64Encode(List.generate(length, (_) => random.nextInt(256)));
  }

  Future<List<int>> _key({bool create = false}) async {
    var value = await keyStorage.read();
    if (value == null && create) {
      value = _random(32);
      await keyStorage.write(value);
    }
    if (value == null) throw StateError('PIN key unavailable');
    final bytes = base64Decode(value);
    if (bytes.length != 32) throw const FormatException('Invalid PIN key');
    return bytes;
  }

  // The installation key stays in secure storage. Copying just the SQLite
  // database does not allow offline enumeration of the 10,000 possible PINs.
  List<int> _digest(List<int> key, String account, String salt, String pin) =>
      Hmac(
        sha256,
        key,
      ).convert(utf8.encode(jsonEncode([account, salt, pin]))).bytes;

  Future<void> create(String account, String pin) => _serial(() async {
    if (!isValid(pin)) throw ArgumentError('PIN must contain four digits');
    if (await storage.read(account) != null) {
      throw StateError('PIN already exists');
    }
    final key = await _key(create: true);
    final salt = _random(16);
    await storage.write(
      account,
      PinRecord(
        salt: salt,
        digest: base64Encode(_digest(key, account, salt, pin)),
      ),
    );
  });

  Future<PinVerification> verify(String account, String pin) =>
      _serial(() async {
        if (!isValid(pin)) throw ArgumentError('PIN must contain four digits');
        final record = await storage.read(account);
        if (record == null) throw StateError('PIN not configured');
        final now = _now();
        if (record.lockedUntil?.isAfter(now) ?? false) {
          return PinVerification(
            PinVerificationStatus.blocked,
            lockedUntil: record.lockedUntil,
          );
        }
        final expected = base64Decode(record.digest);
        final actual = _digest(await _key(), account, record.salt, pin);
        if (expected.length != actual.length) {
          throw const FormatException('Invalid PIN digest');
        }
        var difference = 0;
        for (var i = 0; i < actual.length; i++) {
          difference |= actual[i] ^ expected[i];
        }
        if (difference == 0) {
          await storage.write(
            account,
            PinRecord(salt: record.salt, digest: record.digest),
          );
          return const PinVerification(PinVerificationStatus.matched);
        }
        final attempts = record.failedAttempts + 1;
        final blocked = attempts >= 5;
        final until = blocked ? now.add(const Duration(minutes: 1)) : null;
        await storage.write(
          account,
          PinRecord(
            salt: record.salt,
            digest: record.digest,
            failedAttempts: blocked ? 0 : attempts,
            lockedUntil: until,
          ),
        );
        return PinVerification(
          blocked
              ? PinVerificationStatus.blocked
              : PinVerificationStatus.incorrect,
          lockedUntil: until,
        );
      });

  Future<void> delete(String account) => _serial(() => storage.delete(account));

  Future<void> close() => _serial(storage.close);
}
