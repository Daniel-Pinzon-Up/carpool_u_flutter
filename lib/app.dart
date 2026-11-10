import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'models/app_user.dart';
import 'pages/dashboard_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/welcome_page.dart';
import 'services/carpool_service.dart';
import 'utils/app_config.dart';
import 'utils/app_theme.dart';

class CarpoolApp extends StatefulWidget {
  const CarpoolApp({super.key, this.service});

  final CarpoolService? service;

  @override
  State<CarpoolApp> createState() => _CarpoolAppState();
}

class _CarpoolAppState extends State<CarpoolApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final CarpoolService _service;

  @override
  void initState() {
    super.initState();
    _service =
        widget.service ??
        CarpoolService(
          isLocal: AppConfig.localMode,
          apiBaseUrl: AppConfig.apiBaseUrl,
        );
  }

  void _openLogin() {
    _navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => LoginPage(
          service: _service,
          onAuthenticated: _openDashboard,
          onRegister: _openRegister,
        ),
      ),
    );
  }


  void _openRegister() {
    _navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => RegisterPage(
          service: _service,
          onAuthenticated: _openDashboard,
        ),
      ),
    );
  }

  void _openDashboard(AppUser user) {
    _navigatorKey.currentState!.pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => DashboardPage(
          service: _service,
          user: user,
          onSessionEnded: _goHome,
        ),
      ),
      (_) => false,
    );
  }

  void _goHome() {
    _service.clearSession();
    _navigatorKey.currentState!.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => _welcome()),
      (_) => false,
    );
  }

  Widget _welcome() =>
      WelcomePage(onLogin: _openLogin);

  @override
  void dispose() {
    if (widget.service == null) _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carpool UP',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      theme: AppTheme.light,
      locale: const Locale('es', 'CO'),
      supportedLocales: const [Locale('es', 'CO')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: _welcome(),
    );
  }
}
