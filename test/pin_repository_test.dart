import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/features/auth/data/pin_repository.dart';
import 'package:mineral/features/auth/data/pin_storage.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'support/pin_test_helpers.dart';

void main() {
  test(
    'accepts exactly four numeric digits including a leading zero',
    () async {
      final repo = testPinRepository();
      for (final pin in ['', '123', '12345', '12a4', ' 1234', '1234\n']) {
        await expectLater(repo.create('account', pin), throwsArgumentError);
      }
      await repo.create('account', '0123');
      expect(
        (await repo.verify('account', '0123')).status,
        PinVerificationStatus.matched,
      );
    },
  );

  test(
    'SQLite persists hashes, account separation and retry limits across reopen',
    () async {
      sqfliteFfiInit();
      final directory = await Directory.systemTemp.createTemp(
        'mineral-pin-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final databasePath = path.join(directory.path, 'pin.db');
      final keys = MemoryPinKeyStorage();
      var storage = SqlitePinStorage(
        factory: databaseFactoryFfiNoIsolate,
        databasePath: databasePath,
      );
      var now = DateTime(2026, 10, 8, 12);
      var repo = PinRepository(
        storage: storage,
        keyStorage: keys,
        now: () => now,
      );
      await repo.create('server|1', '0123');
      await repo.create('server|2', '9876');
      await expectLater(repo.create('server|1', '2222'), throwsStateError);
      for (var i = 0; i < 4; i++) {
        expect(
          (await repo.verify('server|1', '9999')).status,
          PinVerificationStatus.incorrect,
        );
      }
      final record = await repo.read('server|1');
      expect(record!.digest, isNot('0123'));
      expect(record.failedAttempts, 4);
      await repo.close();

      storage = SqlitePinStorage(
        factory: databaseFactoryFfiNoIsolate,
        databasePath: databasePath,
      );
      repo = PinRepository(storage: storage, keyStorage: keys, now: () => now);
      expect(
        (await repo.verify('server|1', '9999')).status,
        PinVerificationStatus.blocked,
      );
      await repo.close();
      storage = SqlitePinStorage(
        factory: databaseFactoryFfiNoIsolate,
        databasePath: databasePath,
      );
      repo = PinRepository(storage: storage, keyStorage: keys, now: () => now);
      expect(
        (await repo.verify('server|1', '0123')).status,
        PinVerificationStatus.blocked,
      );
      expect(
        (await repo.verify('server|2', '9876')).status,
        PinVerificationStatus.matched,
      );
      expect(
        (await repo.verify('server|2', '0123')).status,
        PinVerificationStatus.incorrect,
      );
      now = now.add(const Duration(minutes: 1));
      expect(
        (await repo.verify('server|1', '0123')).status,
        PinVerificationStatus.matched,
      );
      expect((await repo.read('server|1'))!.failedAttempts, 0);
      await repo.delete('server|1');
      expect(await repo.read('server|1'), isNull);
      expect(await repo.read('server|2'), isNotNull);
      await repo.close();
    },
  );

  test(
    'copied SQLite credentials cannot be checked without the secure key',
    () async {
      final storage = MemoryPinStorage();
      final repo = PinRepository(
        storage: storage,
        keyStorage: MemoryPinKeyStorage(),
      );
      await repo.create('account', '1234');
      final copy = PinRepository(
        storage: storage,
        keyStorage: MemoryPinKeyStorage(),
      );
      await expectLater(copy.verify('account', '1234'), throwsStateError);
    },
  );
}
