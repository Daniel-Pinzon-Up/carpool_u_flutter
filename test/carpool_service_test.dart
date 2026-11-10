import 'dart:async';
import 'dart:convert';

import 'package:carpool_up_movil/services/carpool_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _email = 'alumna@unipamplona.edu.co';
const _cookie =
    'cp_refresh=refresh-sintetico; Path=/api/v1/auth; HttpOnly; SameSite=lax';

Map<String, dynamic> _user({
  String role = 'passenger',
  String status = 'active',
  List<Map<String, String>> pendingLegal = const [],
}) => {
  'id': '00000000-0000-4000-8000-000000000001',
  'full_name': 'Persona de Prueba',
  'email': _email,
  'sex': 'female',
  'program': null,
  'role': role,
  'status': status,
  'payment_note': null,
  'preferred_language': 'es',
  'theme_preference': 'system',
  'last_login_at': null,
  'document': null,
  'license': null,
  'can_publish': role == 'driver',
  'publish_blockers': role == 'driver' ? [] : ['not_driver'],
  'pending_legal': pendingLegal,
};

Map<String, dynamic> _authenticated({Map<String, dynamic>? user}) => {
  'result': 'authenticated',
  'access_token': 'access-token-sintetico',
  'token_type': 'bearer',
  'expires_in': 900,
  'user': user ?? _user(),
  'challenge_id': null,
  'email_hint': null,
  'resend_after_seconds': null,
};

http.Response _json(
  Map<String, dynamic> body, {
  int status = 200,
  String? cookie,
}) => http.Response(
  jsonEncode(body),
  status,
  headers: {
    'content-type': 'application/json; charset=utf-8',
    if (cookie != null) 'set-cookie': cookie,
  },
);

CarpoolService _service(
  Future<http.Response> Function(http.Request) handler, {
  String baseUrl = 'http://10.0.2.2:8000/api/v1',
}) {
  final client = MockClient(handler);
  final service = CarpoolService(
    isLocal: false,
    apiBaseUrl: baseUrl,
    client: client,
  );
  addTearDown(service.dispose);
  addTearDown(client.close);
  return service;
}

TypeMatcher<ApiException> _apiError(String code) =>
    isA<ApiException>().having((error) => error.code, 'code', code);

void main() {
  group('Contrato de ingreso de FastAPI', () {
    for (final missing in ['result', 'access_token', 'user', 'cookie']) {
      test('Un HTTP 200 sin $missing no abre una sesión', () async {
        final body = _authenticated();
        if (missing != 'cookie') body.remove(missing);
        final service = _service((request) async {
          expect(request.url.path, '/api/v1/auth/login');
          return _json(body, cookie: missing == 'cookie' ? null : _cookie);
        });

        await expectLater(
          service.login(_email, 'contraseña de prueba'),
          throwsA(_apiError('INVALID_RESPONSE')),
        );
        expect(service.currentUser, isNull);
      });
    }

    test(
      'Preserva contraseña y envía la cookie solo al cerrar sesión',
      () async {
        final seen = <http.Request>[];
        final service = _service((request) async {
          seen.add(request);
          switch (request.url.path) {
            case '/api/v1/auth/login':
              expect(jsonDecode(request.body), {
                'email': _email,
                'password': '  clave con espacios  ',
                'device_label': 'Carpool UP móvil',
              });
              expect(request.headers['cookie'], isNull);
              return _json(_authenticated(), cookie: _cookie);
            case '/api/v1/users/me':
              expect(request.method, 'GET');
              expect(
                request.headers['authorization'],
                'Bearer access-token-sintetico',
              );
              expect(request.headers['cookie'], isNull);
              return _json(_user());
            case '/api/v1/auth/logout':
              expect(request.method, 'POST');
              expect(request.headers['cookie'], 'cp_refresh=refresh-sintetico');
              expect(request.headers['authorization'], isNull);
              return http.Response('', 204);
            default:
              fail('Ruta inesperada: ${request.url.path}');
          }
        });

        final result = await service.login(
          '  ALUMNA@UNIPAMPLONA.EDU.CO  ',
          '  clave con espacios  ',
        );
        expect(result.authenticated, isTrue);
        expect(service.currentUser?.emailVerified, isTrue);
        await service.refreshUser();
        expect(await service.logout(), isTrue);
        expect(service.currentUser, isNull);
        expect(seen.length, 3);
      },
    );

    test(
      'Rechaza una cookie Secure cuando el servidor se configuró por HTTP',
      () async {
        final service = _service(
          (request) async =>
              _json(_authenticated(), cookie: '$_cookie; Secure'),
        );
        await expectLater(
          service.login(_email, 'contraseña de prueba'),
          throwsA(_apiError('COOKIE_REQUIRES_HTTPS')),
        );
        expect(service.currentUser, isNull);
      },
    );

    test(
      'No restaura una sesión cuya respuesta llegó después de salir',
      () async {
        final pendingLogin = Completer<http.Response>();
        final service = _service((request) => pendingLogin.future);
        final login = service.login(_email, 'contraseña de prueba');
        service.clearSession();
        final expectation = expectLater(
          login,
          throwsA(isA<SessionExpiredException>()),
        );
        pendingLogin.complete(_json(_authenticated(), cookie: _cookie));
        await expectation;
        expect(service.currentUser, isNull);
      },
    );
  });

  group('Cierre de sesión', () {
    test(
      'Un fallo del servidor al salir limpia la sesión local y devuelve false',
      () async {
        final service = _service((request) async {
          if (request.url.path == '/api/v1/auth/login') {
            return _json(_authenticated(), cookie: _cookie);
          }
          expect(request.url.path, '/api/v1/auth/logout');
          expect(request.headers['cookie'], 'cp_refresh=refresh-sintetico');
          return _json({'code': 'INTERNAL_ERROR', 'details': {}}, status: 500);
        });
        await service.login(_email, 'contraseña de prueba');
        expect(await service.logout(), isFalse);
        expect(service.currentUser, isNull);
        await expectLater(
          service.refreshUser(),
          throwsA(isA<SessionExpiredException>()),
        );
      },
    );

    test(
      'Un 401 concurrente preserva la cookie y solo revoca cuando se pide logout',
      () async {
        var logoutCalls = 0;
        final service = _service((request) async {
          if (request.url.path == '/api/v1/auth/login') {
            return _json(_authenticated(), cookie: _cookie);
          }
          if (request.url.path == '/api/v1/auth/logout') {
            logoutCalls++;
            expect(request.headers['cookie'], 'cp_refresh=refresh-sintetico');
            return http.Response('', 204);
          }
          expect(request.headers['cookie'], isNull);
          return _json({'code': 'UNAUTHORIZED', 'details': {}}, status: 401);
        });
        await service.login(_email, 'contraseña de prueba');
        await expectLater(
          service.loadDashboard(),
          throwsA(isA<SessionExpiredException>()),
        );
        expect(service.currentUser, isNull);
        expect(logoutCalls, 0);
        expect(await service.logout(), isTrue);
        expect(logoutCalls, 1);
      },
    );
  });

  group('Panel de solo consulta', () {
    test(
      'Una carga parcial conserva datos reales y deja lo fallido en null',
      () async {
        final service = _service((request) async {
          switch (request.url.path) {
            case '/api/v1/auth/login':
              return _json(_authenticated(), cookie: _cookie);
            case '/api/v1/stats/passenger':
              return _json({
                'code': 'INTERNAL_ERROR',
                'details': {},
              }, status: 503);
            case '/api/v1/bookings/mine':
              expect(request.url.queryParameters, {
                'scope': 'upcoming',
                'limit': '3',
              });
              return _json({
                'items': [
                  {
                    'id': 'reserva-sintetica',
                    'status': 'accepted',
                    'seats': 2,
                    'amount': 6000,
                    'trip': {
                      'id': 'viaje-sintetico',
                      'origin': 'Origen de prueba',
                      'destination': 'Destino de prueba',
                      'departs_at': '2026-11-06T12:10:00Z',
                      'driver': {
                        'id': 'conductor-sintetico',
                        'full_name': 'Conductor de Prueba',
                      },
                    },
                  },
                ],
                'next_cursor': null,
              });
            case '/api/v1/notifications/unread-count':
              return _json({'unread': 0});
            default:
              fail('Ruta inesperada: ${request.url.path}');
          }
        });
        await service.login(_email, 'contraseña de prueba');
        final data = await service.loadDashboard();
        expect(data.completedTrips, isNull);
        expect(data.contribution, isNull);
        expect(data.rating, isNull);
        expect(data.ratingCount, isNull);
        expect(data.unavailableSections, ['Estadísticas']);
        expect(data.unreadNotifications, 0);
        expect(data.upcomingTrips.single.id, 'reserva-sintetica');
        expect(data.upcomingTrips.single.seats, 2);
        expect(data.upcomingTrips.single.amount, 6000);
        expect(
          data.upcomingTrips.single.counterpartName,
          'Conductor de Prueba',
        );
      },
    );

    test(
      'Sin datos disponibles no introduce cifras ni viajes de la modo local',
      () async {
        final service = _service((request) async {
          if (request.url.path == '/api/v1/auth/login') {
            return _json(_authenticated(), cookie: _cookie);
          }
          return _json({'code': 'INTERNAL_ERROR', 'details': {}}, status: 500);
        });
        await service.login(_email, 'contraseña de prueba');
        final data = await service.loadDashboard();
        expect(data.completedTrips, isNull);
        expect(data.contribution, isNull);
        expect(data.ratingCount, isNull);
        expect(data.unreadNotifications, isNull);
        expect(data.upcomingTrips, isEmpty);
        expect(data.unavailableSections, [
          'Estadísticas',
          'Próximos viajes',
          'Notificaciones',
        ]);
      },
    );

    test(
      'Usa estadísticas y próximos viajes del conductor con sus campos propios',
      () async {
        final service = _service((request) async {
          switch (request.url.path) {
            case '/api/v1/auth/login':
              return _json(
                _authenticated(user: _user(role: 'driver')),
                cookie: _cookie,
              );
            case '/api/v1/stats/driver':
              return _json({
                'trips': 0,
                'contributions': 0,
                'rating': {'average': null, 'count': 0, 'criteria': {}},
              });
            case '/api/v1/trips/mine':
              return _json({
                'items': [
                  {
                    'id': 'viaje-de-conductor',
                    'origin': 'Origen de prueba',
                    'destination': 'Destino de prueba',
                    'departs_at': '2026-11-06T12:10:00Z',
                    'seats_available': 3,
                    'price_per_seat': 2500,
                    'status': 'scheduled',
                  },
                ],
                'next_cursor': null,
              });
            case '/api/v1/notifications/unread-count':
              return _json({'unread': 1});
            default:
              fail('Ruta inesperada: ${request.url.path}');
          }
        });
        await service.login(_email, 'contraseña de prueba');
        final data = await service.loadDashboard();
        expect(data.completedTrips, 0);
        expect(data.contribution, 0);
        expect(data.rating, isNull);
        expect(data.ratingCount, 0);
        expect(data.upcomingTrips.single.seats, 3);
        expect(data.upcomingTrips.single.amount, 2500);
        expect(data.unavailableSections, isEmpty);
      },
    );

    for (final state in [
      'pending_email',
      'pending_approval',
      'suspended',
      'legal',
      'admin',
    ]) {
      test('No consulta estadísticas para la cuenta $state', () async {
        var requests = 0;
        final service = _service((request) async {
          requests++;
          expect(request.url.path, '/api/v1/auth/login');
          return _json(
            _authenticated(
              user: _user(
                role: state == 'admin' ? 'admin' : 'passenger',
                status: state == 'admin' || state == 'legal' ? 'active' : state,
                pendingLegal: state == 'legal'
                    ? [
                        {
                          'id': 'legal-sintetico',
                          'kind': 'terms',
                          'version': '2.0',
                          'language': 'es',
                        },
                      ]
                    : [],
              ),
            ),
            cookie: _cookie,
          );
        });
        await service.login(_email, 'contraseña de prueba');
        expect(service.currentUser?.emailVerified, state != 'pending_email');
        await expectLater(
          service.loadDashboard(),
          throwsA(
            _apiError(
              state == 'admin' ? 'ROLE_NOT_SUPPORTED' : 'ACCOUNT_NOT_ACTIVE',
            ),
          ),
        );
        expect(requests, 1);
      });
    }
  });
}
