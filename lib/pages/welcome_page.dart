import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/logo.webp',
                    height: 118,
                    semanticLabel: 'Carpool UP',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Universidad de Pamplona',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.muted),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/images/pickup.webp',
                    height: 215,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Comparte el camino\na la universidad',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Encuentra tu comunidad en cada trayecto. '
                    'Viaja como pasajero o comparte tu vehículo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: AppTheme.muted,
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    key: const Key('welcome_login'),
                    onPressed: onLogin,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Iniciar sesión'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Carpool universitario',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
