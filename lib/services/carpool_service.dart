import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../models/auth_result.dart';
import '../models/dashboard_data.dart';
import '../models/trip_summary.dart';

class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.code,
    this.statusCode,
    this.retryAfterSeconds,
  });

  final String message;
  final String? code;
  final int? statusCode;
  final int? retryAfterSeconds;

  @override
  String toString() => message;
}

class SessionExpiredException extends ApiException {
  const SessionExpiredException()
    : super(
        'Tu sesión terminó. Inicia sesión nuevamente.',
        code: 'SESSION_EXPIRED',
        statusCode: 401,
      );
}

class CarpoolService {
  CarpoolService({
    this.isLocal = true,
    String apiBaseUrl = 'http://10.0.2.2:8000/api/v1',
    http.Client? client,
  }) : apiBaseUrl = apiBaseUrl.replaceAll(RegExp(r'/+$'), ''),
       _client = client ?? http.Client(),
       _ownsClient = client == null;

  final bool isLocal;
  final String apiBaseUrl;
  final http.Client _client;
  final bool _ownsClient;
  AppUser? _currentUser;
  String? _accessToken;
  String? _refreshCookie;
  bool _disposed = false;
  int _sessionRevision = 0;
  final Map<String, ({String passwordHash, AppUser user})> _localUsers = {};
  bool _localUsersLoaded = false;
  static const _localUsersKey = 'carpool_local_users_v1';

  AppUser? get currentUser => _currentUser;

  Future<AuthResult> login(String email, String password) async {
    _ensureOpen();
    final normalizedEmail = email.trim().toLowerCase();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(normalizedEmail)) {
      throw const ApiException('Escribe un correo válido.');
    }
    if (password.isEmpty || password.runes.length > 128) {
      throw const ApiException(
        'Escribe tu contraseña (máximo 128 caracteres).',
      );
    }

    clearSession();
    final revision = _sessionRevision;
    if (isLocal) {
      await _loadLocalUsers();
      await Future<void>.delayed(const Duration(milliseconds: 250));
      _ensureRevision(revision);
      final saved = _localUsers[normalizedEmail];
      if (saved == null || saved.passwordHash != _hashPassword(password)) {
        throw const ApiException(
          'El correo o la contraseña no son correctos.',
          code: 'INVALID_CREDENTIALS',
          statusCode: 401,
        );
      }
      _currentUser = saved.user;
      return AuthResult(result: 'authenticated', user: saved.user);
    }

    final response = await _send(
      'POST',
      '/auth/login',
      body: {
        'email': normalizedEmail,
        'password': password,
        'device_label': 'Carpool UP móvil',
      },
      revision: revision,
    );
    _ensureRevision(revision);
    return _applyAuth(response);
  }

  Future<AuthResult> register({
    required String email,
    required String password,
    required String fullName,
    required String sex,
    required String program,
    required String role,
    required bool acceptTerms,
    required bool acceptDataPolicy,
  }) async {
    _ensureOpen();
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedName = fullName.trim();
    final normalizedProgram = program.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(normalizedEmail) ||
        !normalizedEmail.endsWith('.edu.co')) {
      throw const ApiException('Usa tu correo institucional terminado en .edu.co.');
    }
    if (normalizedName.length < 3 || normalizedName.length > 120) {
      throw const ApiException('Escribe tu nombre completo.');
    }
    if (password.length < 10 || password.runes.length > 128) {
      throw const ApiException('La contraseña debe tener entre 10 y 128 caracteres.');
    }
    if (sex != 'female' && sex != 'male') {
      throw const ApiException('Selecciona tu sexo.');
    }
    if (role != 'passenger' && role != 'driver') {
      throw const ApiException('Selecciona pasajero o conductor.');
    }
    if (normalizedProgram.isNotEmpty &&
        (normalizedProgram.length < 2 || normalizedProgram.length > 120)) {
      throw const ApiException('Revisa el programa o dependencia.');
    }
    if (!acceptTerms || !acceptDataPolicy) {
      throw const ApiException('Debes aceptar los términos y la política de datos.');
    }
    clearSession();
    final revision = _sessionRevision;
    if (isLocal) {
      await _loadLocalUsers();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      _ensureRevision(revision);
      if (_localUsers.containsKey(normalizedEmail)) {
        throw const ApiException(
          'Ya existe una cuenta con este correo.',
          code: 'EMAIL_TAKEN',
          statusCode: 409,
        );
      }
      final user = AppUser(
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        fullName: normalizedName,
        email: normalizedEmail,
        role: role,
        status: 'active',
        emailVerified: true,
        canPublish: role == 'driver',
        publishBlockers: const [],
      );
      _localUsers[normalizedEmail] = (
        passwordHash: _hashPassword(password),
        user: user,
      );
      await _saveLocalUsers();
      _currentUser = user;
      return AuthResult(result: 'authenticated', user: user);
    }

    final response = await _send(
      'POST',
      '/auth/register',
      body: {
        'email': normalizedEmail,
        'password': password,
        'full_name': normalizedName,
        'sex': sex,
        'role': role,
        'preferred_language': 'es',
        'accept_terms': acceptTerms,
        'accept_data_policy': acceptDataPolicy,
        if (normalizedProgram.isNotEmpty) 'program': normalizedProgram,
      },
      revision: revision,
    );
    _ensureRevision(revision);
    return _applyAuth(response);
  }

  Future<AppUser> refreshUser() async {
    final user = _requireUser();
    if (isLocal) return user;
    final revision = _sessionRevision;
    final response = await _send(
      'GET',
      '/users/me',
      authenticated: true,
      revision: revision,
    );
    try {
      final updated = AppUser.fromJson(_jsonObject(response));
      _ensureRevision(revision);
      _currentUser = updated;
      return updated;
    } on FormatException {
      throw _invalidResponse;
    } on TypeError {
      throw _invalidResponse;
    }
  }

  Future<DashboardData> loadDashboard() async {
    final user = _requireUser();
    if (!user.canAccessDashboard) {
      throw const ApiException(
        'Revisa los pendientes de tu cuenta antes de consultar el panel.',
        code: 'ACCOUNT_NOT_ACTIVE',
        statusCode: 403,
      );
    }
    if (user.role != 'passenger' && user.role != 'driver') {
      throw const ApiException(
        'Esta primera versión incluye el panel de pasajero y conductor. '
        'Consulta la administración desde la aplicación web.',
        code: 'ROLE_NOT_SUPPORTED',
      );
    }
    if (isLocal) return _localDashboard(user);

    final revision = _sessionRevision;
    final responses = await Future.wait([
      _loadSection(
        '/stats/${user.isDriver ? 'driver' : 'passenger'}',
        revision,
      ),
      _loadSection(
        '${user.isDriver ? '/trips/mine' : '/bookings/mine'}'
        '?scope=upcoming&limit=3',
        revision,
      ),
      _loadSection('/notifications/unread-count', revision),
    ]);
    _ensureRevision(revision);

    int? completedTrips;
    num? contribution;
    num? rating;
    int? ratingCount;
    int? unreadNotifications;
    List<TripSummary> upcomingTrips = const [];
    final unavailable = <String>[];

    try {
      final stats = responses[0];
      if (stats == null) throw const FormatException();
      final parsedTrips = _integer(stats['trips']);
      final parsedContribution = _number(
        stats[user.isDriver ? 'contributions' : 'spent'],
      );
      final ratingBlock = stats['rating'];
      if (ratingBlock is! Map) throw const FormatException();
      final parsedRating = ratingBlock['average'] == null
          ? null
          : _number(ratingBlock['average']);
      if (parsedRating != null && parsedRating > 5) {
        throw const FormatException();
      }
      final parsedCount = _integer(ratingBlock['count']);
      completedTrips = parsedTrips;
      contribution = parsedContribution;
      rating = parsedRating;
      ratingCount = parsedCount;
    } on FormatException {
      unavailable.add('Estadísticas');
    }

    try {
      final items = responses[1]?['items'];
      if (items is! List) throw const FormatException();
      upcomingTrips = List.unmodifiable(
        items.map((item) {
          if (item is! Map<String, dynamic>) throw const FormatException();
          return user.isDriver
              ? TripSummary.fromDriverJson(item)
              : TripSummary.fromPassengerJson(item);
        }),
      );
    } on FormatException {
      unavailable.add('Próximos viajes');
    }

    try {
      unreadNotifications = _integer(responses[2]?['unread']);
    } on FormatException {
      unavailable.add('Notificaciones');
    }

    return DashboardData(
      completedTrips: completedTrips,
      contribution: contribution,
      rating: rating,
      ratingCount: ratingCount,
      unreadNotifications: unreadNotifications,
      upcomingTrips: upcomingTrips,
      unavailableSections: List.unmodifiable(unavailable),
    );
  }

  Future<bool> logout() async {
    final hadSession = _currentUser != null;
    final cookie = _refreshCookie;
    clearSession();
    if (isLocal) return true;
    if (cookie == null) return !hadSession;
    try {
      final response = await _send('POST', '/auth/logout', cookie: cookie);
      return response.statusCode == 204;
    } on ApiException {
      return false;
    }
  }

  void clearSession() {
    _sessionRevision++;
    _currentUser = null;
    _accessToken = null;
    _refreshCookie = null;
  }

  void dispose() {
    clearSession();
    _disposed = true;
    if (_ownsClient) _client.close();
  }

  AppUser _requireUser() {
    _ensureOpen();
    final user = _currentUser;
    if (user == null) throw const SessionExpiredException();
    return user;
  }

  void _ensureOpen() {
    if (_disposed) {
      throw const ApiException('La conexión de la aplicación está cerrada.');
    }
  }

  void _ensureRevision(int revision) {
    _ensureOpen();
    if (revision != _sessionRevision) throw const SessionExpiredException();
  }

  Future<http.Response> _sendMultipart(
    String path, {
    required Map<String, String> fields,
    required String fileField,
    required String fileName,
    required Uint8List fileBytes,
    int? revision,
  }) async {
    _ensureOpen();
    if (kIsWeb) {
      throw const ApiException(
        'La conexión real está preparada para la app móvil. En el navegador puedes utilizar la modo local.',
        code: 'UNSUPPORTED_PLATFORM',
      );
    }
    final base = Uri.tryParse(apiBaseUrl);
    if (base == null ||
        !base.hasAuthority ||
        (base.scheme != 'http' && base.scheme != 'https') ||
        base.userInfo.isNotEmpty ||
        base.hasQuery ||
        base.hasFragment) {
      throw const ApiException('La dirección configurada para el servidor no es válida.', code: 'INVALID_API_URL');
    }
    final request = http.MultipartRequest('POST', Uri.parse('$apiBaseUrl$path'))
      ..headers['Accept'] = 'application/json'
      ..fields.addAll(fields)
      ..files.add(http.MultipartFile.fromBytes(fileField, fileBytes, filename: fileName));
    http.Response response;
    try {
      response = await _client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 30));
    } on TimeoutException {
      throw const ApiException('El servidor tardó demasiado en responder. Inténtalo nuevamente.', code: 'TIMEOUT');
    } on http.ClientException {
      throw const ApiException('No fue posible conectar con el servidor. Revisa la conexión e inténtalo de nuevo.', code: 'NETWORK_ERROR');
    }
    if (revision != null) _ensureRevision(revision);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _responseError(response);
    }
    return response;
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
    String? cookie,
    int? revision,
  }) async {
    _ensureOpen();
    if (kIsWeb) {
      throw const ApiException(
        'La conexión real está preparada para la app móvil. '
        'En el navegador puedes utilizar la modo local.',
        code: 'UNSUPPORTED_PLATFORM',
      );
    }
    final base = Uri.tryParse(apiBaseUrl);
    if (base == null ||
        !base.hasAuthority ||
        (base.scheme != 'http' && base.scheme != 'https') ||
        base.userInfo.isNotEmpty ||
        base.hasQuery ||
        base.hasFragment) {
      throw const ApiException(
        'La dirección configurada para el servidor no es válida.',
        code: 'INVALID_API_URL',
      );
    }
    if (authenticated && _accessToken == null) {
      throw const SessionExpiredException();
    }
    final request = http.Request(method, Uri.parse('$apiBaseUrl$path'))
      ..followRedirects = false
      ..headers['Accept'] = 'application/json';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json; charset=utf-8';
      request.body = jsonEncode(body);
    }
    if (authenticated) {
      request.headers['Authorization'] = 'Bearer $_accessToken';
    }
    if (cookie != null) request.headers['Cookie'] = cookie;

    http.Response response;
    try {
      response = await _client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const ApiException(
        'El servidor tardó demasiado en responder. Inténtalo nuevamente.',
        code: 'TIMEOUT',
      );
    } on http.ClientException {
      throw const ApiException(
        'No fue posible conectar con el servidor. Revisa la conexión e inténtalo de nuevo.',
        code: 'NETWORK_ERROR',
      );
    }
    if (revision != null) _ensureRevision(revision);
    if (response.statusCode == 401 && authenticated) {
      // Se conserva la cookie para revocar la sesión cuando la pantalla salga.
      _sessionRevision++;
      _currentUser = null;
      _accessToken = null;
      throw const SessionExpiredException();
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _responseError(response);
    }
    return response;
  }

  AuthResult _applyAuth(http.Response response) {
    try {
      final data = _jsonObject(response);
      final result = AuthResult.fromJson(data);
      if (result.result == 'authenticated') {
        final token = data['access_token'];
        if (!result.authenticated || token is! String || token.isEmpty) {
          throw const FormatException();
        }
        // El servidor coloca el refresh en Set-Cookie; solo se usa al salir.
        final rawCookie = response.headers['set-cookie'];
        final match = rawCookie == null
            ? null
            : RegExp(r'(?:^|,\s*)cp_refresh=([^;,\s]+)').firstMatch(rawCookie);
        if (match == null) throw const FormatException();
        final secure = RegExp(
          r'(?:^|;)\s*secure(?:;|$)',
          caseSensitive: false,
        ).hasMatch(rawCookie!);
        if (secure && Uri.parse(apiBaseUrl).scheme != 'https') {
          throw const ApiException(
            'El servidor requiere una conexión HTTPS para la sesión. '
            'Revisa la configuración local indicada en la guía.',
            code: 'COOKIE_REQUIRES_HTTPS',
          );
        }
        _accessToken = token;
        _refreshCookie = 'cp_refresh=${match.group(1)}';
        _currentUser = result.user;
        return result;
      }
      if ((result.result == 'two_factor_required' ||
              result.result == 'email_verification_required') &&
          result.challengeId != null &&
          result.challengeId!.isNotEmpty) {
        return result;
      }
      throw const FormatException();
    } on FormatException {
      throw _invalidResponse;
    } on TypeError {
      throw _invalidResponse;
    }
  }

  Future<Map<String, dynamic>?> _loadSection(String path, int revision) async {
    try {
      return _jsonObject(
        await _send('GET', path, authenticated: true, revision: revision),
      );
    } on SessionExpiredException {
      rethrow;
    } on ApiException {
      return null;
    }
  }

  static const _invalidResponse = ApiException(
    'El servidor devolvió una respuesta incompleta. Inténtalo nuevamente.',
    code: 'INVALID_RESPONSE',
  );

  static Map<String, dynamic> _jsonObject(http.Response response) {
    try {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is! Map<String, dynamic>) throw const FormatException();
      return data;
    } on FormatException {
      throw _invalidResponse;
    }
  }

  static num _number(dynamic value) {
    if (value is! num || !value.isFinite || value < 0) {
      throw const FormatException();
    }
    return value;
  }

  static int _integer(dynamic value) {
    final number = _number(value);
    if (number != number.truncateToDouble()) throw const FormatException();
    return number.toInt();
  }

  static ApiException _responseError(http.Response response) {
    Map<String, dynamic> data;
    try {
      data = _jsonObject(response);
    } on ApiException {
      data = const {};
    }
    final code = data['code'] is String ? data['code'] as String : 'HTTP_ERROR';
    final details = data['details'];
    final retry = details is Map ? details['retry_after_seconds'] : null;
    final wait = retry is num && retry > 0
        ? ' Espera ${retry.ceil()} segundos antes de intentarlo de nuevo.'
        : ' Espera un momento antes de intentarlo de nuevo.';
    final message = switch (code) {
      'INVALID_CREDENTIALS' => 'El correo o la contraseña no son correctos.',
      'ACCOUNT_LOCKED' => 'La cuenta está bloqueada temporalmente.$wait',
      'ACCOUNT_BLOCKED' =>
        'Esta cuenta está bloqueada. Contacta con la administración.',
      'ACCOUNT_NOT_ACTIVE' =>
        'Tu cuenta todavía no tiene acceso a esta función.',
      'CODE_INVALID' =>
        'El código no es válido o ya venció. Revisa el correo o solicita otro.',
      'CHALLENGE_EXPIRED' =>
        'El proceso de verificación venció. Vuelve a iniciar sesión.',
      'CODE_RESEND_TOO_SOON' => 'Aún no puedes solicitar otro código.$wait',
      'RATE_LIMITED' => 'Se hicieron demasiados intentos.$wait',
      'VALIDATION_ERROR' => 'Revisa los datos del formulario.',
      'EMAIL_NOT_INSTITUTIONAL' => 'Usa tu correo institucional terminado en .edu.co.',
      'EMAIL_TAKEN' => 'Ya existe una cuenta con este correo.',
      'TERMS_NOT_ACCEPTED' => 'Debes aceptar los términos y la política de tratamiento de datos.',
      'PASSWORD_TOO_WEAK' => 'La contraseña no cumple los requisitos de seguridad.',
      'FILE_TYPE_NOT_ALLOWED' => 'El documento debe ser JPG, PNG, WebP o PDF.',
      'FILE_TOO_LARGE' => 'El documento supera el tamaño máximo permitido.',
      'FILE_EMPTY' => 'El documento seleccionado está vacío.',
      'FILE_INVALID' => 'No pudimos leer el documento seleccionado.',
      'FORBIDDEN' =>
        'Tu cuenta no tiene permiso para consultar esta información.',
      _ =>
        response.statusCode >= 500
            ? 'El servidor no está disponible en este momento. Inténtalo más tarde.'
            : 'No fue posible completar la solicitud. Inténtalo nuevamente.',
    };
    return ApiException(
      message,
      code: code,
      statusCode: response.statusCode,
      retryAfterSeconds: retry is num && retry > 0 ? retry.ceil() : null,
    );
  }

  String _hashPassword(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  Future<void> _loadLocalUsers() async {
    if (_localUsersLoaded) return;
    _localUsersLoaded = true;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localUsersKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return;
      for (final entry in decoded.entries) {
        final value = entry.value;
        if (value is! Map) continue;
        final map = Map<String, dynamic>.from(value);
        final hash = map['password_hash'];
        final userMap = map['user'];
        if (hash is! String || userMap is! Map) continue;
        final u = Map<String, dynamic>.from(userMap);
        final user = AppUser(
          id: u['id'] as String,
          fullName: u['full_name'] as String,
          email: u['email'] as String,
          role: u['role'] as String,
          status: u['status'] as String,
          emailVerified: u['email_verified'] == true,
          canPublish: u['can_publish'] == true,
          pendingLegal: List<String>.from(u['pending_legal'] as List? ?? const []),
          publishBlockers: List<String>.from(u['publish_blockers'] as List? ?? const []),
        );
        _localUsers[entry.key] = (passwordHash: hash, user: user);
      }
    } catch (_) {
      // Si los datos locales están dañados, se ignoran y el usuario puede registrarse de nuevo.
    }
  }

  Future<void> _saveLocalUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = <String, dynamic>{};
    for (final entry in _localUsers.entries) {
      final user = entry.value.user;
      data[entry.key] = {
        'password_hash': entry.value.passwordHash,
        'user': {
          'id': user.id,
          'full_name': user.fullName,
          'email': user.email,
          'role': user.role,
          'status': user.status,
          'email_verified': user.emailVerified,
          'can_publish': user.canPublish,
          'pending_legal': user.pendingLegal,
          'publish_blockers': user.publishBlockers,
        },
      };
    }
    await prefs.setString(_localUsersKey, jsonEncode(data));
  }

  static DashboardData _localDashboard(AppUser user) {
    final now = DateTime.now().toUtc().subtract(const Duration(hours: 5));
    // Las horas de Pamplona se guardan como instantes UTC, igual que en la API.
    final tomorrow = DateTime.utc(now.year, now.month, now.day + 1, 12, 10);
    return DashboardData(
      completedTrips: user.isDriver ? 18 : 12,
      contribution: user.isDriver ? 108000 : 36000,
      rating: user.isDriver ? 4.9 : 4.8,
      ratingCount: user.isDriver ? 15 : 8,
      unreadNotifications: 2,
      upcomingTrips: [
        TripSummary(
          id: 'local-trip-1',
          origin: 'Parque principal',
          destination: 'Campus principal',
          departsAt: tomorrow,
          seats: user.isDriver ? 3 : 1,
          amount: 3000,
          status: user.isDriver ? 'scheduled' : 'accepted',
          counterpartName: user.isDriver ? null : 'Camila Pérez',
        ),
        TripSummary(
          id: 'local-trip-2',
          origin: 'Campus principal',
          destination: 'Barrio El Carmen',
          departsAt: DateTime.utc(now.year, now.month, now.day + 2, 22, 30),
          seats: user.isDriver ? 2 : 1,
          amount: 2500,
          status: user.isDriver ? 'scheduled' : 'requested',
          counterpartName: user.isDriver ? null : 'Andrés Torres',
        ),
      ],
    );
  }
}
