import 'dart:async';

import 'package:flutter/foundation.dart';

import 'auth_session.dart';
import 'pin_repository.dart';

enum PinLockStatus {
  signedOut,
  loading,
  create,
  unlock,
  unlocked,
  storageError,
}

class PinLockController extends ChangeNotifier {
  PinLockController({
    required this.session,
    required this.repository,
    this.enabled = true,
  }) {
    if (enabled) {
      session.addListener(_sessionChanged);
      _sessionChanged();
    }
  }

  final AuthSession session;
  final PinRepository repository;
  final bool enabled;
  PinLockStatus status = PinLockStatus.signedOut;
  bool busy = false;
  bool incorrect = false;
  DateTime? lockedUntil;
  String? _account;
  String? _token;
  String? _resetAfterLogin;
  int _generation = 0;
  bool _disposed = false;

  bool get canAccess => !enabled || status == PinLockStatus.unlocked;
  bool get blocking => enabled && session.authenticated && !canAccess;

  void _sessionChanged() {
    final user = session.user;
    final account = session.authenticated && user != null
        ? '${session.baseUrl}|${user.id}'
        : null;
    if (account == _account && session.accessToken == _token) return;
    _account = account;
    _token = session.accessToken;
    if (account == null) {
      _generation++;
      status = PinLockStatus.signedOut;
      busy = false;
      incorrect = false;
      lockedUntil = null;
      notifyListeners();
    } else {
      unawaited(_prepare(reset: _resetAfterLogin == account));
    }
  }

  Future<void> _prepare({bool reset = false}) async {
    final account = _account;
    if (!enabled || account == null || _disposed) return;
    final generation = ++_generation;
    status = PinLockStatus.loading;
    busy = false;
    incorrect = false;
    lockedUntil = null;
    notifyListeners();
    try {
      // A reset is permitted only after a successful password login.
      if (reset) {
        await repository.delete(account);
        _resetAfterLogin = null;
      }
      final record = await repository.read(account);
      if (!_current(generation)) return;
      status = record == null ? PinLockStatus.create : PinLockStatus.unlock;
      lockedUntil = record?.lockedUntil;
    } catch (_) {
      if (!_current(generation)) return;
      status = PinLockStatus.storageError;
    }
    notifyListeners();
  }

  bool _current(int generation) => !_disposed && generation == _generation;

  void lock() {
    if (enabled && session.authenticated) unawaited(_prepare());
  }

  Future<void> retry() => _prepare();

  Future<bool> submit(String pin) async {
    if (busy || !PinRepository.isValid(pin)) return false;
    final account = _account;
    if (account == null ||
        !{PinLockStatus.create, PinLockStatus.unlock}.contains(status)) {
      return false;
    }
    final generation = _generation;
    final creating = status == PinLockStatus.create;
    busy = true;
    incorrect = false;
    notifyListeners();
    var success = false;
    try {
      if (creating) {
        await repository.create(account, pin);
        success = true;
      } else {
        final result = await repository.verify(account, pin);
        if (!_current(generation)) return false;
        lockedUntil = result.lockedUntil;
        success = result.status == PinVerificationStatus.matched;
        incorrect = !success;
      }
      if (!_current(generation)) return false;
      status = success ? PinLockStatus.unlocked : PinLockStatus.unlock;
    } catch (_) {
      if (!_current(generation)) return false;
      status = PinLockStatus.storageError;
    }
    if (_current(generation)) {
      busy = false;
      notifyListeners();
    }
    return success && _current(generation);
  }

  Future<void> forgotPin() async {
    if (busy || _account == null) return;
    _resetAfterLogin = _account;
    busy = true;
    notifyListeners();
    try {
      await session.logout();
    } catch (_) {
      // Logout expires the local session even if the device is offline.
      if (session.authenticated) await session.expire();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    if (enabled) session.removeListener(_sessionChanged);
    super.dispose();
  }
}
