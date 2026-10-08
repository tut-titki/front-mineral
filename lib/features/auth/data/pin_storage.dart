import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class PinRecord {
  const PinRecord({
    required this.salt,
    required this.digest,
    this.failedAttempts = 0,
    this.lockedUntil,
  });

  final String salt;
  final String digest;
  final int failedAttempts;
  final DateTime? lockedUntil;
}

abstract interface class PinStorage {
  Future<PinRecord?> read(String account);
  Future<void> write(String account, PinRecord record);
  Future<void> delete(String account);
  Future<void> close();
}

/// Stores credentials and retry limits in SQLite, never the four digit PIN.
class SqlitePinStorage implements PinStorage {
  SqlitePinStorage({DatabaseFactory? factory, String? databasePath})
    : _factory = factory ?? databaseFactory,
      _databasePath = databasePath;

  final DatabaseFactory _factory;
  final String? _databasePath;
  Future<Database>? _opening;

  Future<Database> _database() =>
      _opening ??= _open().catchError((Object error) {
        _opening = null;
        throw error;
      });

  Future<Database> _open() async => _factory.openDatabase(
    _databasePath ??
        path.join(await _factory.getDatabasesPath(), 'mineral_pin.db'),
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE app_pins (
          account TEXT PRIMARY KEY,
          salt TEXT NOT NULL,
          digest TEXT NOT NULL,
          failed_attempts INTEGER NOT NULL DEFAULT 0,
          locked_until INTEGER
        )
      '''),
    ),
  );

  @override
  Future<PinRecord?> read(String account) async {
    final rows = await (await _database()).query(
      'app_pins',
      where: 'account = ?',
      whereArgs: [account],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.single;
    final until = row['locked_until'] as int?;
    return PinRecord(
      salt: row['salt'] as String,
      digest: row['digest'] as String,
      failedAttempts: row['failed_attempts'] as int,
      lockedUntil: until == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(until),
    );
  }

  @override
  Future<void> write(String account, PinRecord record) async {
    await (await _database()).insert('app_pins', {
      'account': account,
      'salt': record.salt,
      'digest': record.digest,
      'failed_attempts': record.failedAttempts,
      'locked_until': record.lockedUntil?.millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> delete(String account) async {
    await (await _database()).delete(
      'app_pins',
      where: 'account = ?',
      whereArgs: [account],
    );
  }

  @override
  Future<void> close() async {
    final opening = _opening;
    _opening = null;
    if (opening != null) await (await opening).close();
  }
}
