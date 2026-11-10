import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/auth_result.dart';
import '../services/carpool_service.dart';
import '../utils/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/notice_card.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
    required this.service,
    required this.onAuthenticated,
  });

  final CarpoolService service;
  final ValueChanged<AppUser> onAuthenticated;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _dataFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _programController = TextEditingController();

  int _step = 0;
  bool _busy = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;
  bool _acceptDataPolicy = false;
  String _sex = 'female';
  String _role = 'passenger';
  String? _error;

  static const _stepTitles = ['Tus datos', 'Tu rol', 'Confirmación'];

  void _next() {
    setState(() => _error = null);
    if (_step == 0 && !(_dataFormKey.currentState?.validate() ?? false)) return;
    if (_step < 2) setState(() => _step++);
  }

  void _back() {
    if (_busy || _step == 0) return;
    setState(() {
      _error = null;
      _step--;
    });
  }

  Future<void> _register() async {
    if (_busy) return;
    if (!_acceptTerms || !_acceptDataPolicy) {
      setState(() => _error = 'Debes aceptar los términos y la política de tratamiento de datos.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await widget.service.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        sex: _sex,
        program: _programController.text.trim(),
        role: _role,
        acceptTerms: _acceptTerms,
        acceptDataPolicy: _acceptDataPolicy,
      );
      if (!mounted) return;
      _acceptResult(result);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'No pudimos crear la cuenta. Intenta nuevamente.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _acceptResult(AuthResult result) {
    if (result.authenticated && result.user != null) {
      widget.onAuthenticated(result.user!);
      return;
    }

    setState(() => _error = 'No pudimos completar el registro.');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _programController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(title: const Text('Crear cuenta')),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: _registrationContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _registrationContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.asset('assets/images/logo.webp', height: 78, semanticLabel: 'Carpool UP'),
        const SizedBox(height: 18),
        Text(
          _stepTitles[_step],
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text('Paso ${_step + 1} de 3', style: const TextStyle(color: AppTheme.muted)),
        const SizedBox(height: 10),
        LinearProgressIndicator(value: (_step + 1) / 3),
        const SizedBox(height: 22),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: switch (_step) {
              0 => _dataStep(),
              1 => _roleStep(),
              _ => _confirmationStep(),
            },
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 14),
          NoticeCard(message: _error!, isError: true),
        ],
        const SizedBox(height: 18),
        Row(
          children: [
            if (_step > 0)
              Expanded(
                child: OutlinedButton(onPressed: _busy ? null : _back, child: const Text('Atrás')),
              ),
            if (_step > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                key: Key(_step == 2 ? 'register_submit' : 'register_next'),
                onPressed: _busy ? null : (_step == 2 ? _register : _next),
                child: _busy
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_step == 2 ? 'Crear cuenta' : 'Continuar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dataStep() {
    return Form(
      key: _dataFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Usa tu nombre real y tu correo institucional.', style: TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 18),
          TextFormField(
            key: const Key('register_name'),
            controller: _nameController,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            decoration: const InputDecoration(labelText: 'Nombre completo', prefixIcon: Icon(Icons.person_outline)),
            validator: Validators.fullName,
          ),
          const SizedBox(height: 14),
          TextFormField(
            key: const Key('register_email'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            autocorrect: false,
            decoration: const InputDecoration(labelText: 'Correo institucional', prefixIcon: Icon(Icons.mail_outline)),
            validator: Validators.institutionalEmail,
          ),
          const SizedBox(height: 14),
          TextFormField(
            key: const Key('register_password'),
            controller: _passwordController,
            obscureText: _obscurePassword,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              ),
            ),
            validator: Validators.newPassword,
          ),
          const SizedBox(height: 14),
          TextFormField(
            key: const Key('register_confirm'),
            controller: _confirmController,
            obscureText: _obscureConfirm,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Repite la contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              ),
            ),
            validator: (value) {
              final passwordError = Validators.password(value);
              if (passwordError != null) return passwordError;
              if (value != _passwordController.text) return 'Las contraseñas no coinciden.';
              return null;
            },
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _sex,
            decoration: const InputDecoration(labelText: 'Sexo', prefixIcon: Icon(Icons.badge_outlined)),
            items: const [
              DropdownMenuItem(value: 'female', child: Text('Mujer')),
              DropdownMenuItem(value: 'male', child: Text('Hombre')),
            ],
            onChanged: (value) => setState(() => _sex = value ?? _sex),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _programController,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(labelText: 'Programa o dependencia (opcional)', prefixIcon: Icon(Icons.school_outlined)),
            validator: Validators.program,
          ),
        ],
      ),
    );
  }

  Widget _roleStep() {
    Widget choice({required String value, required IconData icon, required String title, required String description}) {
      final selected = _role == value;
      return InkWell(
        onTap: _busy ? null : () => setState(() => _role = value),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: selected ? const Color(0xFFE7F0FF) : Colors.white,
            border: Border.all(color: selected ? AppTheme.primary : const Color(0xFFD7DFEA), width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              Radio<String>(value: value, groupValue: _role, onChanged: (v) => setState(() => _role = v ?? _role)),
              Icon(icon, color: AppTheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(description, style: const TextStyle(color: AppTheme.muted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('¿Cómo vas a usar la app?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        choice(value: 'passenger', icon: Icons.people_outline, title: 'Pasajero', description: 'Busco viajes y solicito cupo a los conductores.'),
        const SizedBox(height: 12),
        choice(value: 'driver', icon: Icons.directions_car_outlined, title: 'Conductor', description: 'Ofrezco puestos en mi carro o moto.'),
        if (_role == 'driver') ...[
          const SizedBox(height: 16),
          const NoticeCard(message: 'Después de activar la cuenta deberás completar los requisitos de conductor, como licencia y vehículo.'),
        ],
      ],
    );
  }

  Widget _confirmationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Revisa tus datos antes de terminar.', style: TextStyle(color: AppTheme.muted)),
        const SizedBox(height: 16),
        _summaryRow('Nombre', _nameController.text.trim()),
        _summaryRow('Correo', _emailController.text.trim()),
        _summaryRow('Sexo', _sex == 'female' ? 'Mujer' : 'Hombre'),
        _summaryRow('Rol', _role == 'driver' ? 'Conductor' : 'Pasajero'),
        const Divider(height: 30),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: _acceptTerms,
          onChanged: _busy ? null : (value) => setState(() => _acceptTerms = value ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('Leí y acepto los Términos y condiciones.'),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: _acceptDataPolicy,
          onChanged: _busy ? null : (value) => setState(() => _acceptDataPolicy = value ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('Autorizo el tratamiento de mis datos según la política de tratamiento de datos.'),
        ),
        const SizedBox(height: 8),
        const NoticeCard(message: 'El valor de cada viaje es un aporte para cubrir gastos, no un pago comercial. La app no cobra ni recibe dinero.'),
      ],
    );
  }

  Widget _summaryRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 105, child: Text(label, style: const TextStyle(color: AppTheme.muted))),
            Expanded(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
      );
}
