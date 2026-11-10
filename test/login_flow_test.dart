import 'package:carpool_up_movil/app.dart';
import 'package:carpool_up_movil/services/carpool_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> openLogin(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('welcome_login')));
  await tester.pumpAndSettle();
}

Future<void> login(
  WidgetTester tester,
  String email,
  String password,
) async {
  await tester.enterText(find.byKey(const Key('login_email')), email);
  await tester.enterText(find.byKey(const Key('login_password')), password);
  await tester.tap(find.byKey(const Key('login_submit')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('abre la pantalla de inicio de sesión', (tester) async {
    final service = CarpoolService();
    addTearDown(service.dispose);
    await tester.pumpWidget(CarpoolApp(service: service));
    await tester.pumpAndSettle();
    await openLogin(tester);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.byKey(const Key('login_email')), findsOneWidget);
          });

  testWidgets('pasajero abre navegación móvil completa', (tester) async {
    final service = CarpoolService();
    addTearDown(service.dispose);
    await service.register(email: 'usuario1@unipamplona.edu.co', password: 'ClaveSegura2026!', fullName: 'Pasajero Prueba', sex: 'female', program: 'Ingeniería de Sistemas', role: 'passenger', acceptTerms: true, acceptDataPolicy: true);
    service.clearSession();
    await tester.pumpWidget(CarpoolApp(service: service));
    await tester.pumpAndSettle();
    await openLogin(tester);
    await login(tester, 'usuario1@unipamplona.edu.co', 'ClaveSegura2026!');
    expect(service.currentUser?.role, 'passenger');
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Buscar viaje'), findsOneWidget);
  });

  testWidgets('conductor abre su panel y opciones de publicación', (tester) async {
    final service = CarpoolService();
    addTearDown(service.dispose);
    await service.register(email: 'usuario2@unipamplona.edu.co', password: 'ClaveSegura2026!', fullName: 'Conductor Prueba', sex: 'male', program: 'Ingeniería de Sistemas', role: 'driver', acceptTerms: true, acceptDataPolicy: true);
    service.clearSession();
    await tester.pumpWidget(CarpoolApp(service: service));
    await tester.pumpAndSettle();
    await openLogin(tester);
    await login(tester, 'usuario2@unipamplona.edu.co', 'ClaveSegura2026!');
    expect(service.currentUser?.isDriver, isTrue);
    expect(find.text('Tu panel de conductor'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
