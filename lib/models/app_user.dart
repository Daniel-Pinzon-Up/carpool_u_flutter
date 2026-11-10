class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.status,
    required this.emailVerified,
    this.canPublish = false,
    this.pendingLegal = const [],
    this.publishBlockers = const [],
  });

  final String id;
  final String fullName;
  final String email;
  final String role;
  final String status;
  final bool emailVerified;
  final bool canPublish;
  final List<String> pendingLegal;
  final List<String> publishBlockers;

  String get firstName => fullName.trim().split(RegExp(r'\s+')).first;

  bool get isDriver => role == 'driver';
  bool get isAdmin => role == 'admin' || role == 'superadmin';

  bool get canAccessDashboard =>
      status == 'active' && emailVerified && pendingLegal.isEmpty;

  String get roleLabel => switch (role) {
    'passenger' => 'Pasajero',
    'driver' => 'Conductor',
    'admin' => 'Administrador',
    'superadmin' => 'Superadministrador',
    _ => 'Usuario',
  };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    String readString(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw const FormatException('Perfil de usuario incompleto.');
      }
      return value;
    }

    final status = readString('status');
    final legal = json['pending_legal'];
    final blockers = json['publish_blockers'];
    if (legal is! List || blockers is! List) {
      throw const FormatException('Estado de cuenta incompleto.');
    }

    final pendingLegal = legal
        .map((entry) {
          if (entry is! Map || entry['kind'] is! String) {
            throw const FormatException('Documento pendiente no válido.');
          }
          final kind = switch (entry['kind']) {
            'terms' => 'Términos y condiciones',
            'data_policy' => 'Política de tratamiento de datos',
            _ => 'Documento de la cuenta',
          };
          final version = entry['version'];
          return version is String && version.isNotEmpty
              ? '$kind (versión $version)'
              : kind;
        })
        .toList(growable: false);

    return AppUser(
      id: readString('id'),
      fullName: readString('full_name'),
      email: readString('email'),
      role: readString('role'),
      status: status,
      // MeOut no envía email_verified; el estado indica si falta verificarlo.
      emailVerified: status != 'pending_email',
      canPublish: json['can_publish'] == true,
      pendingLegal: List.unmodifiable(pendingLegal),
      publishBlockers: List.unmodifiable(
        blockers.map((value) {
          if (value is! String) {
            throw const FormatException('Requisito de cuenta no válido.');
          }
          return value;
        }),
      ),
    );
  }
}
