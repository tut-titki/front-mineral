import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

abstract interface class TokenStorage {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> delete();
}

class SecureTokenStorage implements TokenStorage {
  final _storage = const FlutterSecureStorage();
  static const _key = 'mineral.auth.token';
  @override
  Future<String?> read() => _storage.read(key: _key);
  @override
  Future<void> write(String token) => _storage.write(key: _key, value: token);
  @override
  Future<void> delete() => _storage.delete(key: _key);
}

// Web tokens stay in memory instead of localStorage.
class MemoryTokenStorage implements TokenStorage {
  String? _token;
  @override
  Future<String?> read() async => _token;
  @override
  Future<void> write(String token) async {
    _token = token;
  }

  @override
  Future<void> delete() async {
    _token = null;
  }
}

class AuthUser {
  AuthUser.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      fullName = json['fullName'] as String,
      role = json['role'] as String,
      phone = json['phone'] as String?,
      language = json['language'] as String? ?? 'ru',
      specialty = json['specialty'] as String? ?? '',
      grade = json['grade'] as int?,
      brigadeId = json['brigadeId'] as int?,
      isOnShift = json['isOnShift'] as bool? ?? false;
  final int id;
  final String fullName;
  final String role;
  final String? phone;
  final String language;
  final String specialty;
  final int? grade;
  final int? brigadeId;
  final bool isOnShift;
  String? get mobileRoute => switch (role) {
    'EXECUTOR' => '/executor',
    'MASTER' => '/master',
    _ => null,
  };
}

class ApiException implements Exception {
  const ApiException(
    this.status,
    this.message, {
    this.retryAfter,
    this.details,
  });
  final int status;
  final String message;
  final Duration? retryAfter;
  final Object? details;

  String? fieldMessage(String field) {
    Object? decoded = details;
    if (decoded is String) {
      try {
        decoded = jsonDecode(decoded);
      } on FormatException {
        /* Plain-text details are also supported. */
      }
    }
    if (decoded is List) {
      for (final issue in decoded) {
        if (issue is! Map) continue;
        final path = issue['path'];
        final matches = path == field || (path is List && path.contains(field));
        if (matches && issue['message'] is String) {
          return issue['message'] as String;
        }
      }
    }
    if (decoded is Map) {
      final direct = decoded[field];
      if (direct is String) return direct;
      if (direct is List && direct.isNotEmpty) return direct.first.toString();
      final path = decoded['path'];
      if ((path == field || (path is List && path.contains(field))) &&
          decoded['message'] is String) {
        return decoded['message'] as String;
      }
    }
    if (decoded is String) {
      final text = decoded.toLowerCase();
      if (field == 'phone' && text.contains('телефон')) return decoded;
      if (field == 'newPassword' && text.contains('парол')) return decoded;
    }
    return null;
  }
}

class AuthSession extends ChangeNotifier {
  AuthSession({
    http.Client? client,
    TokenStorage? storage,
    this.baseUrl = 'https://hackaton.fenixkst.kz',
  }) : _client = client ?? http.Client(),
       _storage =
           storage ?? (kIsWeb ? MemoryTokenStorage() : SecureTokenStorage());
  final http.Client _client;
  final TokenStorage _storage;
  final String baseUrl;
  String? _token;
  AuthUser? user;
  String? pushToken;
  DateTime? blockedUntil;
  bool get authenticated => _token != null && user != null;
  String? get token => _token;

  Future<Object?> _requestJson(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool protected = true,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final request = http.Request(method, Uri.parse('$baseUrl$path'));
    request.headers['Content-Type'] = 'application/json';
    if (protected && _token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }
    if (body != null) request.body = jsonEncode(body);
    final response = await http.Response.fromStream(
      await _client.send(request).timeout(timeout),
    ).timeout(timeout);
    if (protected && response.statusCode == 401) await expire();

    Object? decoded;
    try {
      if (response.bodyBytes.isNotEmpty) {
        decoded = jsonDecode(utf8.decode(response.bodyBytes));
      }
    } on FormatException {
      // прокси может вернуть ошибку не в json
    }
    final data = decoded is Map
        ? Map<String, dynamic>.from(decoded)
        : <String, dynamic>{};
    if (response.statusCode >= 200 && response.statusCode < 300) return decoded;
    final seconds = int.tryParse(response.headers['retry-after'] ?? '');
    throw ApiException(
      response.statusCode,
      data['error'] as String? ?? '',
      details: data['details'],
      retryAfter: seconds == null ? null : Duration(seconds: seconds),
    );
  }

  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool protected = true,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final result = await _requestJson(
      method,
      path,
      body: body,
      protected: protected,
      timeout: timeout,
    );
    if (result == null) return {};
    if (result is! Map) {
      throw const FormatException("Ожидался JSON-обьект");
    }
    return Map<String, dynamic>.from(result);
  }

  Future<List<Map<String, dynamic>>> requestList(String path) async {
    final result = await _requestJson("GET", path);
    if (result is! List) {
      throw const FormatException("Ожидался JSON-массив");
    }
    return result.map((item) {
      if (item is! Map) {
        throw const FormatException("Некорректный элемент списка");
      }
      return Map<String, dynamic>.from(item);
    }).toList();
  }

  Future<Map<String, dynamic>> uploadPhoto(String name, Uint8List bytes) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/uploads'),
    );
    if (_token != null) request.headers['Authorization'] = 'Bearer $_token';
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: name),
    );
    final response = await http.Response.fromStream(
      await _client.send(request).timeout(const Duration(seconds: 60)),
    ).timeout(const Duration(seconds: 60));
    if (response.statusCode == 401) await expire();
    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        response.statusCode,
        decoded['error'] as String? ?? '',
        details: decoded['details'],
      );
    }
    return decoded;
  }

  Future<Uint8List> downloadPhoto(String url) async {
    final uri = Uri.parse(baseUrl).resolve(url);
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 30));
    // Signed image URLs are independent of the application session.
    if (response.statusCode != 200) throw ApiException(response.statusCode, '');
    return response.bodyBytes;
  }

  Future<AuthUser> login(String phone, String password) async {
    final until = blockedUntil;
    if (until != null && until.isAfter(DateTime.now())) {
      throw ApiException(429, '', retryAfter: until.difference(DateTime.now()));
    }
    if (password.isEmpty) throw const ApiException(400, '');
    Map<String, dynamic> result;
    try {
      result = await request(
        'POST',
        '/api/auth/login',
        protected: false,
        body: {'phone': phone.trim(), 'password': password},
      );
    } on ApiException catch (error) {
      if (error.status == 429 && error.retryAfter != null) {
        blockedUntil = DateTime.now().add(error.retryAfter!);
      }
      rethrow;
    }
    final token = result['token'] as String;
    final loginUser = AuthUser.fromJson(
      Map<String, dynamic>.from(result['user'] as Map),
    );
    if (loginUser.mobileRoute == null) throw const ApiException(403, '');
    _token = token;
    try {
      final profile = await request('GET', '/api/auth/me');
      final fullUser = AuthUser.fromJson(profile);
      if (fullUser.mobileRoute == null) throw const ApiException(403, '');
      await _storage.write(token);
      user = fullUser;
      blockedUntil = null;
      notifyListeners();
      return fullUser;
    } catch (_) {
      _token = null;
      user = null;
      rethrow;
    }
  }

  Future<AuthUser?> restore() async {
    _token = await _storage.read();
    if (_token == null) return null;
    try {
      user = AuthUser.fromJson(await request('GET', '/api/auth/me'));
      if (user!.mobileRoute == null) {
        await expire();
        return null;
      }
      notifyListeners();
      return user;
    } on ApiException catch (error) {
      if (error.status == 401) return null;
      rethrow;
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    await request(
      'POST',
      '/api/auth/change-password',
      body: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }

  Future<void> logout() async {
    if (pushToken != null && _token != null) {
      await request(
        'DELETE',
        '/api/devices/${Uri.encodeComponent(pushToken!)}',
      );
    }
    await expire();
  }

  Future<void> expire() async {
    _token = null;
    user = null;
    pushToken = null;
    try {
      await _storage.delete();
    } finally {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }
}
