import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../services/carpool_service.dart';
import '../utils/app_theme.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    required this.service,
    required this.user,
    required this.onSessionEnded,
  });

  final CarpoolService service;
  final AppUser user;
  final VoidCallback onSessionEnded;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  late AppUser _user;
  final List<_Ride> _passengerTrips = [];
  final List<_Ride> _driverTrips = [];
  final List<_DriverRequest> _requests = [
    _DriverRequest('Laura Gómez', 'Parque Principal', '1 puesto', 4.9),
    _DriverRequest('Jhonatan Vera', 'Punto en la ruta', '1 puesto', 4.6),
  ];

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _passengerTrips.add(
      const _Ride(
        id: 'p1',
        origin: 'Barrio El Carmen',
        destination: 'Ciudad Universitaria',
        time: '6:30',
        date: 'Jue 15 oct',
        driver: 'Linda Rodríguez',
        contribution: 2000,
        seats: 2,
        status: 'Aceptada',
      ),
    );
    _driverTrips.add(
      const _Ride(
        id: 'd1',
        origin: 'Barrio El Carmen',
        destination: 'Ciudad Universitaria',
        time: '6:30',
        date: 'Jue 15 oct',
        driver: 'Tú',
        contribution: 2000,
        seats: 3,
        status: 'Programado',
      ),
    );
  }

  List<NavigationDestination> get _destinations => _user.isDriver
      ? const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.add_box_outlined), selectedIcon: Icon(Icons.add_box), label: 'Publicar'),
          NavigationDestination(icon: Icon(Icons.directions_car_outlined), selectedIcon: Icon(Icons.directions_car), label: 'Mis viajes'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Mensajes'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ]
      : const [
          NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Mis viajes'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Mensajes'),
          NavigationDestination(icon: Icon(Icons.notifications_none), selectedIcon: Icon(Icons.notifications), label: 'Avisos'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ];

  Future<void> _logout() async {
    try {
      await widget.service.logout();
    } catch (_) {}
    widget.service.clearSession();
    widget.onSessionEnded();
  }

  void _bookRide(_Ride ride) {
    if (_passengerTrips.any((item) => item.id == ride.id)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Este viaje ya está en Mis viajes.')));
      return;
    }
    setState(() {
      _passengerTrips.add(ride.copyWith(status: 'Solicitada'));
      _selectedIndex = 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud enviada al conductor.')));
  }

  void _publishRide(_Ride ride) {
    setState(() {
      _driverTrips.insert(0, ride);
      _selectedIndex = 2;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Viaje publicado correctamente.')));
  }

  Widget _currentPage() {
    if (_user.isDriver) {
      switch (_selectedIndex) {
        case 0:
          return _DriverHomePage(user: _user, requests: _requests, onOpenRequests: _openRequests);
        case 1:
          return _PublishTripPage(onPublish: _publishRide);
        case 2:
          return _MyTripsPage(rides: _driverTrips, driverMode: true);
        case 3:
          return const _MessagesPage();
        default:
          return _ProfilePage(user: _user, onLogout: _logout);
      }
    }
    switch (_selectedIndex) {
      case 0:
        return _SearchPage(onBook: _bookRide);
      case 1:
        return _MyTripsPage(rides: _passengerTrips, driverMode: false);
      case 2:
        return const _MessagesPage();
      case 3:
        return const _NotificationsPage();
      default:
        return _ProfilePage(user: _user, onLogout: _logout);
    }
  }

  void _openRequests() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _RequestsPage(
          requests: _requests,
          onChanged: () => setState(() {}),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset('assets/images/logo-small.webp', height: 34),
            const SizedBox(width: 10),
            const Text('Carpool UP', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          if (_user.isDriver)
            IconButton(
              tooltip: 'Solicitudes',
              onPressed: _openRequests,
              icon: Badge(
                isLabelVisible: _requests.any((r) => r.pending),
                label: Text('${_requests.where((r) => r.pending).length}'),
                child: const Icon(Icons.notifications_none_rounded),
              ),
            ),
        ],
      ),
      body: SafeArea(top: false, child: _currentPage()),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) => setState(() => _selectedIndex = value),
        destinations: _destinations,
      ),
    );
  }
}

class _SearchPage extends StatefulWidget {
  const _SearchPage({required this.onBook});
  final ValueChanged<_Ride> onBook;

  @override
  State<_SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<_SearchPage> {
  final _origin = TextEditingController(text: 'Barrio El Carmen');
  final _destination = TextEditingController(text: 'Ciudad Universitaria');
  bool _searched = true;
  int _seats = 1;
  final Set<String> _preferences = {'Sin humo'};

  final _rides = const [
    _Ride(id: 'r1', origin: 'Barrio El Carmen', destination: 'Ciudad Universitaria', time: '6:36', date: 'Jue 15 oct', driver: 'Linda Rodríguez', contribution: 2000, seats: 2, status: 'Disponible'),
    _Ride(id: 'r2', origin: 'Barrio El Carmen', destination: 'Ciudad Universitaria', time: '6:58', date: 'Jue 15 oct', driver: 'Carlos Méndez', contribution: 1500, seats: 3, status: 'Disponible'),
  ];

  @override
  void dispose() {
    _origin.dispose();
    _destination.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        const Text('Buscar viaje', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        const Text('Encuentra quién pasa cerca de ti a la hora que necesitas.', style: TextStyle(color: AppTheme.muted)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(controller: _origin, decoration: const InputDecoration(labelText: '¿Dónde te recogen?', prefixIcon: Icon(Icons.location_on_outlined))),
                const SizedBox(height: 12),
                TextField(controller: _destination, decoration: const InputDecoration(labelText: '¿A dónde vas?', prefixIcon: Icon(Icons.flag_outlined))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Expanded(child: _StaticField(icon: Icons.calendar_today_outlined, label: 'Fecha', value: 'Jue 15 oct')),
                    const SizedBox(width: 10),
                    const Expanded(child: _StaticField(icon: Icons.access_time, label: 'Hora', value: '06:30')),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: _boxDecoration(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(onPressed: _seats > 1 ? () => setState(() => _seats--) : null, icon: const Icon(Icons.remove, size: 18)),
                            Text('$_seats', style: const TextStyle(fontWeight: FontWeight.w700)),
                            IconButton(onPressed: _seats < 4 ? () => setState(() => _seats++) : null, icon: const Icon(Icons.add, size: 18)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: ['Sin humo', 'Con música', 'Solo mujeres', 'Mascota'].map((label) {
                      final selected = _preferences.contains(label);
                      return FilterChip(
                        label: Text(label),
                        selected: selected,
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              _preferences.add(label);
                            } else {
                              _preferences.remove(label);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => setState(() => _searched = true),
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar'),
                ),
              ],
            ),
          ),
        ),
        if (_searched) ...[
          const SizedBox(height: 20),
          Text('Viajes encontrados: ${_rides.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          ..._rides.map((ride) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RideCard(ride: ride, actionLabel: 'Ver viaje', onTap: () => _openTrip(context, ride)),
              )),
        ],
      ],
    );
  }

  void _openTrip(BuildContext context, _Ride ride) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _TripDetailPage(ride: ride, onBook: () {
      Navigator.of(context).pop();
      widget.onBook(ride);
    })));
  }
}

class _DriverHomePage extends StatelessWidget {
  const _DriverHomePage({required this.user, required this.requests, required this.onOpenRequests});
  final AppUser user;
  final List<_DriverRequest> requests;
  final VoidCallback onOpenRequests;

  @override
  Widget build(BuildContext context) {
    final pending = requests.where((r) => r.pending).length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        Text('Hola, ${user.firstName}', style: const TextStyle(color: AppTheme.muted)),
        const Text('Tu panel de conductor', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Listo para publicar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                const _RequirementRow(icon: Icons.badge_outlined, title: 'Licencia de conducción', status: 'Lista'),
                const Divider(),
                const _RequirementRow(icon: Icons.directions_car_outlined, title: 'Vehículo', status: 'Activo'),
                const Divider(),
                const _RequirementRow(icon: Icons.verified_user_outlined, title: 'Cuenta', status: 'Activa'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const CircleAvatar(child: Icon(Icons.assignment_outlined)),
            title: Text('$pending solicitudes pendientes', style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: const Text('Revisa quién quiere viajar contigo.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onOpenRequests,
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Tu vehículo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                SizedBox(height: 12),
                Row(children: [Icon(Icons.directions_car, color: AppTheme.primary), SizedBox(width: 12), Expanded(child: Text('Renault 9 · ABC123\nRojo · 4 puestos', style: TextStyle(height: 1.4))), Chip(label: Text('Activo'))]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PublishTripPage extends StatefulWidget {
  const _PublishTripPage({required this.onPublish});
  final ValueChanged<_Ride> onPublish;

  @override
  State<_PublishTripPage> createState() => _PublishTripPageState();
}

class _PublishTripPageState extends State<_PublishTripPage> {
  final _formKey = GlobalKey<FormState>();
  final _origin = TextEditingController(text: 'Barrio El Carmen');
  final _destination = TextEditingController(text: 'Ciudad Universitaria');
  final _contribution = TextEditingController(text: '2000');
  int _seats = 3;
  bool _smokeFree = true;
  bool _music = true;

  @override
  void dispose() {
    _origin.dispose();
    _destination.dispose();
    _contribution.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        const Text('Publicar viaje', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        const Text('Versión simplificada: toda la información se registra en un solo formulario.', style: TextStyle(color: AppTheme.muted)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(controller: _origin, decoration: const InputDecoration(labelText: 'Origen', prefixIcon: Icon(Icons.trip_origin)), validator: _required),
                  const SizedBox(height: 12),
                  TextFormField(controller: _destination, decoration: const InputDecoration(labelText: 'Destino', prefixIcon: Icon(Icons.flag_outlined)), validator: _required),
                  const SizedBox(height: 12),
                  const Row(children: [Expanded(child: _StaticField(icon: Icons.calendar_today_outlined, label: 'Fecha', value: 'Jue 15 oct')), SizedBox(width: 10), Expanded(child: _StaticField(icon: Icons.access_time, label: 'Hora', value: '06:30'))]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: TextFormField(controller: _contribution, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Aporte por puesto', prefixText: r'$ '), validator: _required)),
                    const SizedBox(width: 10),
                    Expanded(child: DropdownButtonFormField<int>(initialValue: _seats, decoration: const InputDecoration(labelText: 'Cupos'), items: [1,2,3].map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(), onChanged: (v) => setState(() => _seats = v ?? _seats))),
                  ]),
                  const SizedBox(height: 8),
                  SwitchListTile(contentPadding: EdgeInsets.zero, value: _smokeFree, onChanged: (v) => setState(() => _smokeFree = v), title: const Text('Sin humo')),
                  SwitchListTile(contentPadding: EdgeInsets.zero, value: _music, onChanged: (v) => setState(() => _music = v), title: const Text('Música permitida')),
                  const SizedBox(height: 8),
                  FilledButton.icon(onPressed: _submit, icon: const Icon(Icons.send_outlined), label: const Text('Publicar viaje')),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String? _required(String? value) => value == null || value.trim().isEmpty ? 'Este campo es obligatorio.' : null;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = int.tryParse(_contribution.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    widget.onPublish(_Ride(
      id: 'new-${DateTime.now().millisecondsSinceEpoch}',
      origin: _origin.text.trim(),
      destination: _destination.text.trim(),
      time: '6:30',
      date: 'Jue 15 oct',
      driver: 'Tú',
      contribution: amount,
      seats: _seats,
      status: 'Programado',
    ));
  }
}

class _MyTripsPage extends StatelessWidget {
  const _MyTripsPage({required this.rides, required this.driverMode});
  final List<_Ride> rides;
  final bool driverMode;

  @override
  Widget build(BuildContext context) {
    if (rides.isEmpty) {
      return const _EmptyPage(icon: Icons.route_outlined, title: 'Todavía no hay viajes', message: 'Cuando tengas un viaje aparecerá aquí.');
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        const Text('Mis viajes', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        Text(driverMode ? 'Tus viajes publicados.' : 'Tus reservas y solicitudes.', style: const TextStyle(color: AppTheme.muted)),
        const SizedBox(height: 14),
        ...rides.map((ride) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _RideCard(ride: ride, actionLabel: 'Ver detalle', onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _TripDetailPage(ride: ride)))),
        )),
        const SizedBox(height: 10),
        const Text('Historial', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        const _HistoryCard(),
      ],
    );
  }
}

class _MessagesPage extends StatelessWidget {
  const _MessagesPage();

  @override
  Widget build(BuildContext context) {
    final conversations = const [
      ('Viaje · jue 15 oct, 6:30', 'Linda: Salgo en 5 min', '6:22'),
      ('El Carmen → Ciudad Universitaria', 'Jhonatan: Estoy cerca del puente', '6:10'),
      ('Serie Barrio Cariongo', 'Linda: Mañana salgo 6:15', 'Ayer'),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        const Text('Conversaciones', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        ...conversations.map((item) => Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: const CircleAvatar(child: Icon(Icons.group_outlined)),
            title: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(item.$2),
            trailing: Text(item.$3, style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const _ChatPage())),
          ),
        )),
      ],
    );
  }
}

class _ChatPage extends StatefulWidget {
  const _ChatPage();
  @override
  State<_ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<_ChatPage> {
  final _controller = TextEditingController();
  final List<(String, bool)> _messages = [
    ('Buenos días. Salimos puntuales de El Carmen.', false),
    ('Perfecto, te espero en el Parque Principal.', true),
    ('Yo estoy en la ruta, cerca del puente.', false),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat del viaje')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.$2 ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: const BoxConstraints(maxWidth: 300),
                    decoration: BoxDecoration(color: message.$2 ? const Color(0xFFE3EEFF) : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFDCE3EE))),
                    child: Text(message.$1),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(children: [
                Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Escribe un mensaje...'))),
                const SizedBox(width: 8),
                IconButton.filled(onPressed: _send, icon: const Icon(Icons.send)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _messages.add((text, true)));
    _controller.clear();
  }
}

class _NotificationsPage extends StatelessWidget {
  const _NotificationsPage();
  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.check_circle_outline, '¡Tu reserva fue aceptada!', 'Hace 2 min'),
      (Icons.chat_bubble_outline, 'Linda Rodríguez te escribió en el chat.', 'Hace 5 min'),
      (Icons.access_time, 'Tu viaje sale en 30 minutos.', 'Hace 20 min'),
      (Icons.star_outline, 'Tu viaje terminó. Ya puedes calificar.', 'Ayer'),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        const Text('Notificaciones', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        ...items.map((item) => Card(child: ListTile(contentPadding: const EdgeInsets.all(14), leading: CircleAvatar(child: Icon(item.$1)), title: Text(item.$2, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(item.$3)))),
      ],
    );
  }
}

class _ProfilePage extends StatefulWidget {
  const _ProfilePage({required this.user, required this.onLogout});
  final AppUser user;
  final VoidCallback onLogout;

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  String? _photoPath;
  bool _savingPhoto = false;

  String get _storageKey => 'profile_photo_${widget.user.id}';

  @override
  void initState() {
    super.initState();
    _loadSavedPhoto();
  }

  Future<void> _loadSavedPhoto() async {
    final preferences = await SharedPreferences.getInstance();
    final path = preferences.getString(_storageKey);
    if (!mounted || path == null || !File(path).existsSync()) return;
    setState(() => _photoPath = path);
  }

  Future<void> _choosePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Foto de perfil',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Elegir de la galería'),
                onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Tomar una foto'),
                onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );
    if (source != null) await _pickAndSavePhoto(source);
  }

  Future<void> _pickAndSavePhoto(ImageSource source) async {
    if (_savingPhoto) return;
    setState(() => _savingPhoto = true);
    try {
      final image = await _picker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1200,
      );
      if (image == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final extension = image.name.contains('.')
          ? image.name.split('.').last.toLowerCase()
          : 'jpg';
      final safeExtension = RegExp(r'^[a-z0-9]{2,5}$').hasMatch(extension)
          ? extension
          : 'jpg';
      final savedFile = File(
        '${directory.path}/profile_${widget.user.id}.$safeExtension',
      );
      await File(image.path).copy(savedFile.path);

      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_storageKey, savedFile.path);
      if (!mounted) return;
      setState(() => _photoPath = savedFile.path);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil actualizada.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No fue posible seleccionar la foto. Intenta nuevamente.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _savingPhoto = false);
    }
  }

  Future<void> _removePhoto() async {
    final path = _photoPath;
    if (path != null) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
    if (!mounted) return;
    setState(() => _photoPath = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Foto de perfil eliminada.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photoProvider = _photoPath == null
        ? null
        : FileImage(File(_photoPath!)) as ImageProvider;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundImage: photoProvider,
                  child: photoProvider == null
                      ? Text(
                          widget.user.firstName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: IconButton.filled(
                    tooltip: 'Cambiar foto',
                    onPressed: _savingPhoto ? null : _choosePhoto,
                    icon: _savingPhoto
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.camera_alt_outlined, size: 19),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.fullName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    widget.user.email,
                    style: const TextStyle(color: AppTheme.muted),
                  ),
                  Text(
                    widget.user.roleLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _savingPhoto ? null : _choosePhoto,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: Text(_photoPath == null ? 'Agregar foto' : 'Cambiar foto'),
              ),
            ),
            if (_photoPath != null) ...[
              const SizedBox(width: 10),
              IconButton.outlined(
                tooltip: 'Eliminar foto',
                onPressed: _savingPhoto ? null : _removePhoto,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.school_outlined),
                title: Text('Programa o dependencia'),
                subtitle: Text('Ingeniería de Sistemas'),
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.language),
                title: Text('Idioma'),
                subtitle: Text('Español'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Ayuda'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'Carpool UP',
                  applicationVersion: '1.1.0',
                  children: const [
                    Text('Aplicación móvil universitaria para compartir viajes.'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: widget.onLogout,
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar sesión'),
        ),
        const SizedBox(height: 8),
        const Text(
          'La foto se guarda localmente en este dispositivo. En una versión conectada al backend puede sincronizarse con la cuenta.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.muted, fontSize: 12),
        ),
      ],
    );
  }
}

class _RequestsPage extends StatefulWidget {
  const _RequestsPage({required this.requests, required this.onChanged});
  final List<_DriverRequest> requests;
  final VoidCallback onChanged;
  @override
  State<_RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<_RequestsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitudes')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('Reservas por aprobar', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          ...widget.requests.map((request) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [CircleAvatar(child: Text(request.name.substring(0, 1))), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(request.name, style: const TextStyle(fontWeight: FontWeight.w800)), Text('★ ${request.rating} · ${request.seats}')]))]),
                  const SizedBox(height: 10),
                  Text('Recogida: ${request.pickup}'),
                  const SizedBox(height: 12),
                  if (request.pending)
                    Row(children: [Expanded(child: OutlinedButton(onPressed: () => _answer(request, false), child: const Text('Rechazar'))), const SizedBox(width: 10), Expanded(child: FilledButton(onPressed: () => _answer(request, true), child: const Text('Aceptar')))])
                  else
                    Chip(label: Text(request.accepted ? 'Aceptada' : 'Rechazada')),
                ]),
              ),
            ),
          )),
        ],
      ),
    );
  }

  void _answer(_DriverRequest request, bool accepted) {
    setState(() {
      request.pending = false;
      request.accepted = accepted;
    });
    widget.onChanged();
  }
}

class _TripDetailPage extends StatelessWidget {
  const _TripDetailPage({required this.ride, this.onBook});
  final _Ride ride;
  final VoidCallback? onBook;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del viaje')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text('${ride.origin} → ${ride.destination}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          Text('${ride.date} · ${ride.time}', style: const TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 16),
          Container(
            height: 190,
            decoration: BoxDecoration(color: const Color(0xFFE8EEF6), borderRadius: BorderRadius.circular(18)),
            child: const Stack(children: [
              Positioned(left: 28, top: 120, child: Icon(Icons.location_on, color: AppTheme.primary, size: 34)),
              Positioned(right: 32, top: 44, child: Icon(Icons.flag, color: AppTheme.primary, size: 34)),
              Center(child: Icon(Icons.route, color: AppTheme.primary, size: 90)),
            ]),
          ),
          const SizedBox(height: 14),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            _InfoRow(label: 'Recogida', value: '${ride.origin} · ${ride.time}'),
            const Divider(),
            _InfoRow(label: 'Destino', value: ride.destination),
            const Divider(),
            _InfoRow(label: 'Conductor', value: ride.driver),
            const Divider(),
            _InfoRow(label: 'Aporte', value: '\$ ${ride.contribution} COP'),
            const Divider(),
            _InfoRow(label: 'Cupos disponibles', value: '${ride.seats}'),
          ]))),
          if (onBook != null) ...[
            const SizedBox(height: 14),
            FilledButton.icon(onPressed: onBook, icon: const Icon(Icons.confirmation_number_outlined), label: const Text('Solicitar cupo')),
            const SizedBox(height: 8),
            const Text('El conductor aprueba cada solicitud. El aporte ayuda a cubrir gastos del viaje.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.muted, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

class _RideCard extends StatelessWidget {
  const _RideCard({required this.ride, required this.actionLabel, required this.onTap});
  final _Ride ride;
  final String actionLabel;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Chip(label: Text(ride.status)), const Spacer(), Text('\$ ${ride.contribution}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800))]),
            const SizedBox(height: 8),
            Text('${ride.time} · ${ride.origin} → ${ride.destination}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Row(children: [const CircleAvatar(radius: 18, child: Icon(Icons.person, size: 18)), const SizedBox(width: 8), Expanded(child: Text(ride.driver)), Text('${ride.seats} cupos', style: const TextStyle(color: AppTheme.muted))]),
            const SizedBox(height: 10),
            Align(alignment: Alignment.centerRight, child: Text(actionLabel, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700))),
          ]),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard();
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Chip(label: Text('Completada')),
          const SizedBox(height: 6),
          const Text('Barrio El Carmen → Ciudad Universitaria', style: TextStyle(fontWeight: FontWeight.w800)),
          const Text('Jue 8 oct · 6:30', style: TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 10),
          OutlinedButton.icon(onPressed: () => _showRating(context), icon: const Icon(Icons.star_outline), label: const Text('Calificar')),
        ]),
      ),
    );
  }

  void _showRating(BuildContext context) {
    int stars = 5;
    showDialog<void>(context: context, builder: (dialogContext) => StatefulBuilder(builder: (context, setState) => AlertDialog(
      title: const Text('Calificar viaje'),
      content: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (index) => IconButton(onPressed: () => setState(() => stars = index + 1), icon: Icon(index < stars ? Icons.star : Icons.star_border, color: Colors.amber)))),
      actions: [FilledButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Enviar'))],
    )));
  }
}

class _StaticField extends StatelessWidget {
  const _StaticField({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
    decoration: _boxDecoration(),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.muted)), const SizedBox(height: 3), Row(children: [Icon(icon, size: 16), const SizedBox(width: 5), Expanded(child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis))])]),
  );
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.icon, required this.title, required this.status});
  final IconData icon;
  final String title;
  final String status;
  @override
  Widget build(BuildContext context) => ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(child: Icon(icon)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), trailing: Chip(label: Text(status)));
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 105, child: Text(label, style: const TextStyle(color: AppTheme.muted))), Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700)))]);
}

class _EmptyPage extends StatelessWidget {
  const _EmptyPage({required this.icon, required this.title, required this.message});
  final IconData icon;
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 64, color: AppTheme.primary), const SizedBox(height: 14), Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.muted))])));
}

class _Ride {
  const _Ride({required this.id, required this.origin, required this.destination, required this.time, required this.date, required this.driver, required this.contribution, required this.seats, required this.status});
  final String id;
  final String origin;
  final String destination;
  final String time;
  final String date;
  final String driver;
  final int contribution;
  final int seats;
  final String status;

  _Ride copyWith({String? status}) => _Ride(id: id, origin: origin, destination: destination, time: time, date: date, driver: driver, contribution: contribution, seats: seats, status: status ?? this.status);
}

class _DriverRequest {
  _DriverRequest(this.name, this.pickup, this.seats, this.rating);
  final String name;
  final String pickup;
  final String seats;
  final double rating;
  bool pending = true;
  bool accepted = false;
}

BoxDecoration _boxDecoration() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFC9D3E1)));
