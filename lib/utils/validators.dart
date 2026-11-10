class Validators {
  const Validators._();

  static String? email(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Escribe tu correo institucional.';
    if (email.length > 254 ||
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Escribe un correo válido, por ejemplo nombre@universidad.edu.co.';
    }
    return null;
  }

  static String? fullName(String? value) {
    final name = (value ?? '').trim();
    if (name.length < 3) return 'Escribe tu nombre completo.';
    if (name.length > 120) return 'El nombre supera los 120 caracteres.';
    return null;
  }

  static String? institutionalEmail(String? value) {
    final baseError = email(value);
    if (baseError != null) return baseError;
    if (!(value ?? '').trim().toLowerCase().endsWith('.edu.co')) {
      return 'Usa tu correo institucional terminado en .edu.co.';
    }
    return null;
  }

  static String? newPassword(String? value) {
    final password = value ?? '';
    if (password.length < 10) return 'Usa mínimo 10 caracteres.';
    if (password.runes.length > 128) return 'La contraseña supera los 128 caracteres.';
    return null;
  }

  static String? program(String? value) {
    final program = (value ?? '').trim();
    if (program.isNotEmpty && program.length < 2) return 'Escribe al menos 2 caracteres.';
    if (program.length > 120) return 'El programa supera los 120 caracteres.';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Escribe tu contraseña.';
    if (value.runes.length > 128) {
      return 'La contraseña supera los 128 caracteres.';
    }
    return null;
  }

  static String? code(String? value) {
    if (!RegExp(r'^\d{6}$').hasMatch(value ?? '')) {
      return 'Escribe los seis números del código.';
    }
    return null;
  }
}
