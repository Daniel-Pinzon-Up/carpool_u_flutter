import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../services/carpool_service.dart';
<<<<<<< HEAD
import '../services/local_carpool_store.dart';
=======
>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78
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
<<<<<<< HEAD
  final LocalCarpoolStore _store = LocalCarpoolStore();
  int _selectedIndex = 0;

  List<NavigationDestination> get _destinations {
    if (widget.user.isAdmin) {
      return const [
        NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Resumen'),
        NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Usuarios'),
        NavigationDestination(icon: Icon(Icons.directions_car_outlined), selectedIcon: Icon(Icons.directions_car), label: 'Viajes'),
        NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Solicitudes'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
      ];
    }
    if (widget.user.isDriver) {
      return const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
        NavigationDestination(icon: Icon(Icons.add_box_outlined), selectedIcon: Icon(Icons.add_box), label: 'Publicar'),
        NavigationDestination(icon: Icon(Icons.directions_car_outlined), selectedIcon: Icon(Icons.directions_car), label: 'Mis viajes'),
        NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Mensajes'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
      ];
    }
    return const [
      NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
      NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Mis viajes'),
      NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Mensajes'),
      NavigationDestination(icon: Icon(Icons.notifications_none), selectedIcon: Icon(Icons.notifications), label: 'Avisos'),
      NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
    ];
  }

=======
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

>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78
  Future<void> _logout() async {
    try {
      await widget.service.logout();
    } catch (_) {}
    widget.service.clearSession();
    widget.onSessionEnded();
  }

<<<<<<< HEAD
  Widget _currentPage() {
    if (widget.user.isAdmin) {
      switch (_selectedIndex) {
        case 0:
          return _AdminSummaryPage(service: widget.service, store: _store);
        case 1:
          return _AdminUsersPage(service: widget.service);
        case 2:
          return _AdminTripsPage(store: _store);
        case 3:
          return _AdminBookingsPage(store: _store);
        default:
          return _ProfilePage(user: widget.user, onLogout: _logout);
      }
    }

    if (widget.user.isDriver) {
      switch (_selectedIndex) {
        case 0:
          return _DriverHomePage(user: widget.user, store: _store, onOpenRequests: _openRequests);
        case 1:
          return _PublishTripPage(user: widget.user, store: _store, onPublished: () => setState(() => _selectedIndex = 2));
        case 2:
          return _DriverTripsPage(user: widget.user, store: _store);
        case 3:
          return _MessagesPage(user: widget.user, store: _store);
        default:
          return _ProfilePage(user: widget.user, onLogout: _logout);
      }
    }

    switch (_selectedIndex) {
      case 0:
        return _SearchPage(user: widget.user, store: _store);
      case 1:
        return _PassengerTripsPage(user: widget.user, store: _store);
      case 2:
        return _MessagesPage(user: widget.user, store: _store);
      case 3:
        return _NotificationsPage(user: widget.user, store: _store);
      default:
        return _ProfilePage(user: widget.user, onLogout: _logout);
=======
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
>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78
    }
  }

  void _openRequests() {
<<<<<<< HEAD
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => _RequestsPage(user: widget.user, store: _store),
    ));
=======
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _RequestsPage(
          requests: _requests,
          onChanged: () => setState(() {}),
        ),
      ),
    );
>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78
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
<<<<<<< HEAD
          if (widget.user.isDriver)
            IconButton(
              tooltip: 'Solicitudes',
              onPressed: _openRequests,
              icon: const Icon(Icons.notifications_none_rounded),
=======
          if (_user.isDriver)
            IconButton(
              tooltip: 'Solicitudes',
              onPressed: _openRequests,
              icon: Badge(
                isLabelVisible: _requests.any((r) => r.pending),
                label: Text('${_requests.where((r) => r.pending).length}'),
                child: const Icon(Icons.notifications_none_rounded),
              ),
>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78
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
<<<<<<< HEAD
  const _SearchPage({required this.user, required this.store});
  final AppUser user;
  final LocalCarpoolStore store;
=======
  const _SearchPage({required this.onBook});
  final ValueChanged<_Ride> onBook;
>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78

  @override
  State<_SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<_SearchPage> {
<<<<<<< HEAD
  final _origin = TextEditingController();
  final _destination = TextEditingController();
  int _seats = 1;
  bool _loading = true;
  List<LocalTrip> _rides = const [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final rides = await widget.store.availableTrips();
    if (!mounted) return;
    setState(() {
      _rides = rides;
      _loading = false;
    });
  }

  List<LocalTrip> get _filtered {
    final origin = _origin.text.trim().toLowerCase();
    final destination = _destination.text.trim().toLowerCase();
    return _rides.where((ride) {
      final matchesOrigin = origin.isEmpty || ride.origin.toLowerCase().contains(origin);
      final matchesDestination = destination.isEmpty || ride.destination.toLowerCase().contains(destination);
      return matchesOrigin && matchesDestination && ride.seats >= _seats;
    }).toList(growable: false);
  }
=======
  final _origin = TextEditingController(text: 'Barrio El Carmen');
  final _destination = TextEditingController(text: 'Ciudad Universitaria');
  bool _searched = true;
  int _seats = 1;
  final Set<String> _preferences = {'Sin humo'};

  final _rides = const [
    _Ride(id: 'r1', origin: 'Barrio El Carmen', destination: 'Ciudad Universitaria', time: '6:36', date: 'Jue 15 oct', driver: 'Linda Rodríguez', contribution: 2000, seats: 2, status: 'Disponible'),
    _Ride(id: 'r2', origin: 'Barrio El Carmen', destination: 'Ciudad Universitaria', time: '6:58', date: 'Jue 15 oct', driver: 'Carlos Méndez', contribution: 1500, seats: 3, status: 'Disponible'),
  ];
>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78

  @override
  void dispose() {
    _origin.dispose();
    _destination.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final rides = _filtered;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        children: [
          const Text('Buscar viaje', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const Text('Los viajes publicados por conductores aparecen aquí.', style: TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(controller: _origin, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: '¿Dónde te recogen?', prefixIcon: Icon(Icons.location_on_outlined))),
                  const SizedBox(height: 12),
                  TextField(controller: _destination, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: '¿A dónde vas?', prefixIcon: Icon(Icons.flag_outlined))),
                  const SizedBox(height: 12),
                  Row(children: [
                    const Expanded(child: _StaticField(icon: Icons.calendar_today_outlined, label: 'Fecha', value: 'Próximo viaje')),
=======
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
>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: _boxDecoration(),
<<<<<<< HEAD
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          IconButton(onPressed: _seats > 1 ? () => setState(() => _seats--) : null, icon: const Icon(Icons.remove, size: 18)),
                          Text('$_seats puesto${_seats == 1 ? '' : 's'}', style: const TextStyle(fontWeight: FontWeight.w700)),
                          IconButton(onPressed: _seats < 4 ? () => setState(() => _seats++) : null, icon: const Icon(Icons.add, size: 18)),
                        ]),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  FilledButton.icon(onPressed: _refresh, icon: const Icon(Icons.search), label: const Text('Actualizar búsqueda')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(28), child: CircularProgressIndicator()))
          else if (rides.isEmpty)
            const _EmptyPage(icon: Icons.route_outlined, title: 'No hay viajes disponibles', message: 'Publica primero un viaje con una cuenta de conductor y luego vuelve como pasajero.')
          else ...[
            Text('Viajes encontrados: ${rides.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ...rides.map((ride) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TripCard(
                trip: ride,
                actionLabel: 'Ver y solicitar',
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => _TripDetailPage(user: widget.user, trip: ride, store: widget.store, requestedSeats: _seats),
                )).then((_) => _refresh()),
              ),
            )),
          ],
        ],
      ),
    );
  }
}

class _TripDetailPage extends StatefulWidget {
  const _TripDetailPage({required this.user, required this.trip, required this.store, required this.requestedSeats});
  final AppUser user;
  final LocalTrip trip;
  final LocalCarpoolStore store;
  final int requestedSeats;

  @override
  State<_TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<_TripDetailPage> {
  bool _busy = false;

  Future<void> _request() async {
    setState(() => _busy = true);
    await widget.store.requestTrip(passenger: widget.user, trip: widget.trip, seats: widget.requestedSeats);
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud enviada al conductor.')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del viaje')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text('${trip.origin} → ${trip.destination}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          Text('${trip.date} · ${trip.time}', style: const TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 16),
          Container(
            height: 180,
            decoration: BoxDecoration(color: const Color(0xFFE8EEF6), borderRadius: BorderRadius.circular(18)),
            child: const Stack(children: [
              Positioned(left: 28, top: 112, child: Icon(Icons.location_on, color: AppTheme.primary, size: 34)),
              Positioned(right: 32, top: 40, child: Icon(Icons.flag, color: AppTheme.primary, size: 34)),
              Center(child: Icon(Icons.route, color: AppTheme.primary, size: 90)),
            ]),
          ),
          const SizedBox(height: 14),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            _InfoRow(label: 'Conductor', value: trip.driverName),
            const Divider(),
            _InfoRow(label: 'Aporte', value: '\$ ${trip.contribution} COP'),
            const Divider(),
            _InfoRow(label: 'Cupos', value: '${trip.seats}'),
            const Divider(),
            _InfoRow(label: 'Estado', value: _tripStatus(trip.status)),
          ]))),
          const SizedBox(height: 14),
          FilledButton.icon(onPressed: _busy ? null : _request, icon: const Icon(Icons.confirmation_number_outlined), label: Text(_busy ? 'Enviando...' : 'Solicitar cupo')),
        ],
      ),
    );
  }
}

class _DriverHomePage extends StatefulWidget {
  const _DriverHomePage({required this.user, required this.store, required this.onOpenRequests});
  final AppUser user;
  final LocalCarpoolStore store;
  final VoidCallback onOpenRequests;

  @override
  State<_DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<_DriverHomePage> {
  int _pending = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final requests = await widget.store.bookingsForDriver(widget.user.id);
    if (!mounted) return;
    setState(() => _pending = requests.where((r) => r.status == 'requested').length);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        children: [
          Text('Hola, ${widget.user.firstName}', style: const TextStyle(color: AppTheme.muted)),
          const Text('Tu panel de conductor', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: const [
            Text('Todo listo para publicar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            SizedBox(height: 12),
            _RequirementRow(icon: Icons.badge_outlined, title: 'Licencia de conducción', status: 'Lista'),
            Divider(),
            _RequirementRow(icon: Icons.directions_car_outlined, title: 'Vehículo', status: 'Activo'),
          ]))),
          const SizedBox(height: 14),
          Card(child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const CircleAvatar(child: Icon(Icons.assignment_outlined)),
            title: Text('$_pending solicitudes pendientes', style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: const Text('Acepta al pasajero para habilitar el chat.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: widget.onOpenRequests,
          )),
        ],
      ),
=======
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
>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78
    );
  }
}

class _PublishTripPage extends StatefulWidget {
<<<<<<< HEAD
  const _PublishTripPage({required this.user, required this.store, required this.onPublished});
  final AppUser user;
  final LocalCarpoolStore store;
  final VoidCallback onPublished;
=======
  const _PublishTripPage({required this.onPublish});
  final ValueChanged<_Ride> onPublish;
>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78

  @override
  State<_PublishTripPage> createState() => _PublishTripPageState();
}

class _PublishTripPageState extends State<_PublishTripPage> {
  final _formKey = GlobalKey<FormState>();
  final _origin = TextEditingController(text: 'Barrio El Carmen');
  final _destination = TextEditingController(text: 'Ciudad Universitaria');
  final _contribution = TextEditingController(text: '2000');
  int _seats = 3;
<<<<<<< HEAD
  bool _busy = false;
=======
  bool _smokeFree = true;
  bool _music = true;
>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78

  @override
  void dispose() {
    _origin.dispose();
    _destination.dispose();
    _contribution.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  Future<void> _publish() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final amount = int.tryParse(_contribution.text.trim());
    if (amount == null) return;
    setState(() => _busy = true);
    await widget.store.publishTrip(
      driver: widget.user,
      origin: _origin.text,
      destination: _destination.text,
      date: 'Próximo viaje',
      time: TimeOfDay.now().format(context),
      contribution: amount,
      seats: _seats,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Viaje publicado. Ya puede verlo un pasajero.')));
    widget.onPublished();
  }

=======
>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        const Text('Publicar viaje', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
<<<<<<< HEAD
        const Text('El viaje se comparte con las cuentas de pasajero registradas en este dispositivo.', style: TextStyle(color: AppTheme.muted)),
        const SizedBox(height: 16),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(controller: _origin, decoration: const InputDecoration(labelText: 'Origen', prefixIcon: Icon(Icons.trip_origin)), validator: _required),
            const SizedBox(height: 12),
            TextFormField(controller: _destination, decoration: const InputDecoration(labelText: 'Destino', prefixIcon: Icon(Icons.flag_outlined)), validator: _required),
            const SizedBox(height: 12),
            TextFormField(controller: _contribution, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Aporte por puesto', prefixText: r'$ '), validator: _required),
            const SizedBox(height: 12),
            Row(children: [
              const Text('Cupos', style: TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(onPressed: _seats > 1 ? () => setState(() => _seats--) : null, icon: const Icon(Icons.remove)),
              Text('$_seats', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              IconButton(onPressed: _seats < 6 ? () => setState(() => _seats++) : null, icon: const Icon(Icons.add)),
            ]),
            const SizedBox(height: 12),
            FilledButton.icon(onPressed: _busy ? null : _publish, icon: const Icon(Icons.send_outlined), label: Text(_busy ? 'Publicando...' : 'Publicar viaje')),
          ]),
        ))),
=======
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
>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78
      ],
    );
  }
}

<<<<<<< HEAD
class _DriverTripsPage extends StatefulWidget {
  const _DriverTripsPage({required this.user, required this.store});
  final AppUser user;
  final LocalCarpoolStore store;

  @override
  State<_DriverTripsPage> createState() => _DriverTripsPageState();
}

class _DriverTripsPageState extends State<_DriverTripsPage> {
  bool _loading = true;
  List<LocalTrip> _trips = const [];
  List<LocalBooking> _bookings = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final trips = await widget.store.tripsForDriver(widget.user.id);
    final bookings = await widget.store.bookingsForDriver(widget.user.id);
    if (!mounted) return;
    setState(() {
      _trips = trips;
      _bookings = bookings;
      _loading = false;
    });
  }

  Future<void> _start(LocalTrip trip) async {
    await widget.store.startTrip(trip.id);
    await _load();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Viaje iniciado. El pasajero verá el estado En curso.')));
  }

  Future<void> _finish(LocalTrip trip) async {
    await widget.store.finishTrip(trip.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_trips.isEmpty) return const _EmptyPage(icon: Icons.directions_car_outlined, title: 'Aún no has publicado viajes', message: 'Ve a Publicar para crear tu primer viaje.');
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        children: [
          const Text('Mis viajes', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          ..._trips.map((trip) {
            final accepted = _bookings.where((b) => b.tripId == trip.id && b.status == 'accepted').length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [Chip(label: Text(_tripStatus(trip.status))), const Spacer(), Text('\$ ${trip.contribution}', style: const TextStyle(fontWeight: FontWeight.w800))]),
                Text('${trip.origin} → ${trip.destination}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('$accepted pasajero${accepted == 1 ? '' : 's'} aceptado${accepted == 1 ? '' : 's'}', style: const TextStyle(color: AppTheme.muted)),
                if (trip.status == 'published' && accepted > 0) ...[
                  const SizedBox(height: 12),
                  FilledButton.icon(onPressed: () => _start(trip), icon: const Icon(Icons.play_arrow), label: const Text('Iniciar viaje')),
                ],
                if (trip.status == 'started') ...[
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(onPressed: () => _finish(trip), icon: const Icon(Icons.flag_outlined), label: const Text('Finalizar viaje')),
                ],
              ]))),
            );
          }),
        ],
      ),
=======
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
>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78
    );
  }
}

<<<<<<< HEAD
class _PassengerTripsPage extends StatefulWidget {
  const _PassengerTripsPage({required this.user, required this.store});
  final AppUser user;
  final LocalCarpoolStore store;

  @override
  State<_PassengerTripsPage> createState() => _PassengerTripsPageState();
}

class _PassengerTripsPageState extends State<_PassengerTripsPage> {
  bool _loading = true;
  List<LocalBooking> _bookings = const [];
  Map<String, LocalTrip> _trips = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bookings = await widget.store.bookingsForPassenger(widget.user.id);
    final trips = await widget.store.getTrips();
    if (!mounted) return;
    setState(() {
      _bookings = bookings;
      _trips = {for (final trip in trips) trip.id: trip};
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        children: [
          const Text('Mis viajes', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          if (_bookings.isEmpty)
            const _EmptyPage(icon: Icons.calendar_month_outlined, title: 'No tienes viajes', message: 'Busca un viaje publicado por un conductor y solicita un cupo.')
          else
            ..._bookings.map((booking) {
              final trip = _trips[booking.tripId];
              if (trip == null) return const SizedBox.shrink();
              final status = trip.isInProgress ? 'En curso' : booking.status == 'accepted' ? 'Aceptada' : booking.status == 'rejected' ? 'Rechazada' : 'Solicitada';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Chip(label: Text(status)),
                  const SizedBox(height: 8),
                  Text('${trip.origin} → ${trip.destination}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                  Text('Conductor: ${trip.driverName}', style: const TextStyle(color: AppTheme.muted)),
                  if (booking.status == 'accepted') ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => _openChat(context, widget.user, widget.store, booking, trip, trip.driverName),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Abrir chat'),
                    ),
                  ],
                ]))),
              );
            }),
        ],
      ),
    );
  }
}

class _RequestsPage extends StatefulWidget {
  const _RequestsPage({required this.user, required this.store});
  final AppUser user;
  final LocalCarpoolStore store;

  @override
  State<_RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<_RequestsPage> {
  bool _loading = true;
  List<LocalBooking> _bookings = const [];
  Map<String, LocalTrip> _trips = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bookings = await widget.store.bookingsForDriver(widget.user.id);
    final trips = await widget.store.getTrips();
    if (!mounted) return;
    setState(() {
      _bookings = bookings;
      _trips = {for (final t in trips) t.id: t};
      _loading = false;
    });
  }

  Future<void> _answer(LocalBooking booking, bool accepted) async {
    await widget.store.answerBooking(booking.id, accepted);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(accepted ? 'Solicitud aceptada. El chat ya está habilitado.' : 'Solicitud rechazada.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitudes')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  const Text('Reservas recibidas', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  if (_bookings.isEmpty)
                    const _EmptyPage(icon: Icons.assignment_outlined, title: 'Sin solicitudes', message: 'Cuando un pasajero solicite tu viaje aparecerá aquí.')
                  else
                    ..._bookings.map((booking) {
                      final trip = _trips[booking.tripId];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(booking.passengerName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                          Text(trip == null ? 'Viaje' : '${trip.origin} → ${trip.destination}'),
                          Text('${booking.seats} puesto${booking.seats == 1 ? '' : 's'}', style: const TextStyle(color: AppTheme.muted)),
                          const SizedBox(height: 12),
                          if (booking.status == 'requested')
                            Row(children: [
                              Expanded(child: OutlinedButton(onPressed: () => _answer(booking, false), child: const Text('Rechazar'))),
                              const SizedBox(width: 10),
                              Expanded(child: FilledButton(onPressed: () => _answer(booking, true), child: const Text('Aceptar'))),
                            ])
                          else ...[
                            Chip(label: Text(booking.status == 'accepted' ? 'Aceptada' : 'Rechazada')),
                            if (booking.status == 'accepted' && trip != null)
                              OutlinedButton.icon(
                                onPressed: () => _openChat(context, widget.user, widget.store, booking, trip, booking.passengerName),
                                icon: const Icon(Icons.chat_bubble_outline),
                                label: const Text('Abrir chat'),
                              ),
                          ],
                        ]))),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}

class _MessagesPage extends StatefulWidget {
  const _MessagesPage({required this.user, required this.store});
  final AppUser user;
  final LocalCarpoolStore store;

  @override
  State<_MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<_MessagesPage> {
  bool _loading = true;
  List<LocalConversation> _conversations = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final conversations = await widget.store.conversationsFor(widget.user);
    if (!mounted) return;
    setState(() {
      _conversations = conversations;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        children: [
          const Text('Conversaciones', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const Text('El chat se habilita cuando el conductor acepta la solicitud.', style: TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 14),
          if (_conversations.isEmpty)
            const _EmptyPage(icon: Icons.chat_bubble_outline, title: 'Todavía no hay chats', message: 'Primero debe existir una reserva aceptada.')
          else
            ..._conversations.map((conversation) => Card(child: ListTile(
              leading: CircleAvatar(child: Text(conversation.otherName.substring(0, 1).toUpperCase())),
              title: Text(conversation.otherName, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text('${conversation.trip.origin} → ${conversation.trip.destination}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openChat(context, widget.user, widget.store, conversation.booking, conversation.trip, conversation.otherName).then((_) => _load()),
            ))),
        ],
      ),
    );
  }
}

Future<void> _openChat(BuildContext context, AppUser user, LocalCarpoolStore store, LocalBooking booking, LocalTrip trip, String otherName) {
  return Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => _ChatPage(user: user, store: store, booking: booking, trip: trip, otherName: otherName),
  ));
}

class _ChatPage extends StatefulWidget {
  const _ChatPage({required this.user, required this.store, required this.booking, required this.trip, required this.otherName});
  final AppUser user;
  final LocalCarpoolStore store;
  final LocalBooking booking;
  final LocalTrip trip;
  final String otherName;

=======
class _ChatPage extends StatefulWidget {
  const _ChatPage();
>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78
  @override
  State<_ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<_ChatPage> {
  final _controller = TextEditingController();
<<<<<<< HEAD
  List<LocalMessage> _messages = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final messages = await widget.store.messagesFor(widget.booking.id);
    if (!mounted) return;
    setState(() {
      _messages = messages;
      _loading = false;
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await widget.store.sendMessage(bookingId: widget.booking.id, sender: widget.user, text: text);
    await _load();
  }
=======
  final List<(String, bool)> _messages = [
    ('Buenos días. Salimos puntuales de El Carmen.', false),
    ('Perfecto, te espero en el Parque Principal.', true),
    ('Yo estoy en la ruta, cerca del puente.', false),
  ];
>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(title: Text(widget.otherName)),
      body: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: const Color(0xFFEAF2FF),
          child: Text('${widget.trip.origin} → ${widget.trip.destination}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final mine = message.senderId == widget.user.id;
                    return Align(
                      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 300),
                        margin: const EdgeInsets.only(bottom: 9),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: mine ? AppTheme.primary : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: mine ? null : Border.all(color: const Color(0xFFD7DFEA)),
                        ),
                        child: Text(message.text, style: TextStyle(color: mine ? Colors.white : Colors.black87)),
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
      ]),
    );
  }
}

class _NotificationsPage extends StatefulWidget {
  const _NotificationsPage({required this.user, required this.store});
  final AppUser user;
  final LocalCarpoolStore store;

  @override
  State<_NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<_NotificationsPage> {
  List<String> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bookings = await widget.store.bookingsForPassenger(widget.user.id);
    final trips = await widget.store.getTrips();
    final tripById = {for (final t in trips) t.id: t};
    final items = <String>[];
    for (final booking in bookings) {
      final trip = tripById[booking.tripId];
      if (trip == null) continue;
      if (trip.status == 'started') items.add('Tu viaje ${trip.origin} → ${trip.destination} está en curso.');
      if (booking.status == 'accepted') items.add('Tu solicitud con ${trip.driverName} fue aceptada. Ya puedes chatear.');
      if (booking.status == 'requested') items.add('Tu solicitud para ${trip.origin} → ${trip.destination} está pendiente.');
    }
    if (!mounted) return;
    setState(() => _items = items);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        children: [
          const Text('Notificaciones', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          if (_items.isEmpty)
            const _EmptyPage(icon: Icons.notifications_none, title: 'Sin avisos', message: 'Aquí aparecerán los cambios de tus solicitudes y viajes.')
          else
            ..._items.map((text) => Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.notifications_outlined)), title: Text(text)))),
=======
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
>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78
        ],
      ),
    );
  }
<<<<<<< HEAD
}

class _AdminSummaryPage extends StatefulWidget {
  const _AdminSummaryPage({required this.service, required this.store});
  final CarpoolService service;
  final LocalCarpoolStore store;

  @override
  State<_AdminSummaryPage> createState() => _AdminSummaryPageState();
}

class _AdminSummaryPageState extends State<_AdminSummaryPage> {
  int _users = 0;
  int _trips = 0;
  int _bookings = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final users = await widget.service.listLocalUsers();
    final trips = await widget.store.getTrips();
    final bookings = await widget.store.getBookings();
    if (!mounted) return;
    setState(() {
      _users = users.length;
      _trips = trips.length;
      _bookings = bookings.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        children: [
          const Text('Panel administrativo', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const Text('Resumen de los datos locales de esta demostración.', style: TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 18),
          _AdminStat(icon: Icons.people, label: 'Usuarios registrados', value: '$_users'),
          _AdminStat(icon: Icons.directions_car, label: 'Viajes publicados', value: '$_trips'),
          _AdminStat(icon: Icons.assignment, label: 'Solicitudes creadas', value: '$_bookings'),
        ],
      ),
    );
  }
}

class _AdminUsersPage extends StatefulWidget {
  const _AdminUsersPage({required this.service});
  final CarpoolService service;

  @override
  State<_AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<_AdminUsersPage> {
  List<AppUser> _users = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final users = await widget.service.listLocalUsers();
    if (mounted) setState(() => _users = users);
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: _load,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        const Text('Usuarios', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        ..._users.map((u) => Card(child: ListTile(
          leading: CircleAvatar(child: Text(u.firstName.substring(0, 1).toUpperCase())),
          title: Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text(u.email),
          trailing: Chip(label: Text(u.roleLabel)),
        ))),
      ],
    ),
  );
}

class _AdminTripsPage extends StatefulWidget {
  const _AdminTripsPage({required this.store});
  final LocalCarpoolStore store;

  @override
  State<_AdminTripsPage> createState() => _AdminTripsPageState();
}

class _AdminTripsPageState extends State<_AdminTripsPage> {
  List<LocalTrip> _trips = const [];
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { final data = await widget.store.getTrips(); if (mounted) setState(() => _trips = data); }
  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: _load,
    child: ListView(padding: const EdgeInsets.fromLTRB(18, 16, 18, 28), children: [
      const Text('Viajes', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
      const SizedBox(height: 14),
      if (_trips.isEmpty) const _EmptyPage(icon: Icons.directions_car_outlined, title: 'Sin viajes', message: 'Los viajes publicados aparecerán aquí.'),
      ..._trips.map((t) => Card(child: ListTile(
        title: Text('${t.origin} → ${t.destination}', style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text('Conductor: ${t.driverName} · ${t.date} ${t.time}'),
        trailing: Chip(label: Text(_tripStatus(t.status))),
      ))),
    ]),
  );
}

class _AdminBookingsPage extends StatefulWidget {
  const _AdminBookingsPage({required this.store});
  final LocalCarpoolStore store;
  @override
  State<_AdminBookingsPage> createState() => _AdminBookingsPageState();
}

class _AdminBookingsPageState extends State<_AdminBookingsPage> {
  List<LocalBooking> _bookings = const [];
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { final data = await widget.store.getBookings(); if (mounted) setState(() => _bookings = data); }
  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: _load,
    child: ListView(padding: const EdgeInsets.fromLTRB(18, 16, 18, 28), children: [
      const Text('Solicitudes', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
      const SizedBox(height: 14),
      if (_bookings.isEmpty) const _EmptyPage(icon: Icons.assignment_outlined, title: 'Sin solicitudes', message: 'Las solicitudes de cupo aparecerán aquí.'),
      ..._bookings.map((b) => Card(child: ListTile(
        title: Text(b.passengerName, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text('${b.seats} puesto${b.seats == 1 ? '' : 's'}'),
        trailing: Chip(label: Text(_bookingStatus(b.status))),
      ))),
    ]),
  );
}

class _AdminStat extends StatelessWidget {
  const _AdminStat({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [
    CircleAvatar(child: Icon(icon)), const SizedBox(width: 14), Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))), Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
  ])));
=======

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
>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78
}

class _ProfilePage extends StatefulWidget {
  const _ProfilePage({required this.user, required this.onLogout});
  final AppUser user;
  final VoidCallback onLogout;
<<<<<<< HEAD
=======

>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78
  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  String? _photoPath;
  bool _savingPhoto = false;
<<<<<<< HEAD
  String get _storageKey => 'profile_photo_${widget.user.id}';

  @override
  void initState() { super.initState(); _loadSavedPhoto(); }
=======

  String get _storageKey => 'profile_photo_${widget.user.id}';

  @override
  void initState() {
    super.initState();
    _loadSavedPhoto();
  }
>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78

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
<<<<<<< HEAD
      builder: (sheetContext) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: const Icon(Icons.photo_library_outlined), title: const Text('Elegir de la galería'), onTap: () => Navigator.pop(sheetContext, ImageSource.gallery)),
        ListTile(leading: const Icon(Icons.photo_camera_outlined), title: const Text('Tomar una foto'), onTap: () => Navigator.pop(sheetContext, ImageSource.camera)),
      ])),
=======
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
>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78
    );
    if (source != null) await _pickAndSavePhoto(source);
  }

  Future<void> _pickAndSavePhoto(ImageSource source) async {
    if (_savingPhoto) return;
    setState(() => _savingPhoto = true);
    try {
<<<<<<< HEAD
      final image = await _picker.pickImage(source: source, imageQuality: 82, maxWidth: 1200);
      if (image == null) return;
      final directory = await getApplicationDocumentsDirectory();
      final savedFile = File('${directory.path}/profile_${widget.user.id}.jpg');
      await File(image.path).copy(savedFile.path);
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_storageKey, savedFile.path);
      if (mounted) setState(() => _photoPath = savedFile.path);
=======
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
>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78
    } finally {
      if (mounted) setState(() => _savingPhoto = false);
    }
  }

<<<<<<< HEAD
  @override
  Widget build(BuildContext context) {
    final photoProvider = _photoPath == null ? null : FileImage(File(_photoPath!)) as ImageProvider;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        Row(children: [
          CircleAvatar(radius: 38, backgroundImage: photoProvider, child: photoProvider == null ? Text(widget.user.firstName.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)) : null),
          const SizedBox(width: 18),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.user.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            Text(widget.user.email, style: const TextStyle(color: AppTheme.muted)),
            Text(widget.user.roleLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
          ])),
        ]),
        const SizedBox(height: 14),
        OutlinedButton.icon(onPressed: _savingPhoto ? null : _choosePhoto, icon: const Icon(Icons.add_a_photo_outlined), label: Text(_photoPath == null ? 'Agregar foto' : 'Cambiar foto')),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.person_outline),
                  SizedBox(width: 10),
                  Text('Datos personales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 18),
                _InfoRow(label: 'Nombre', value: widget.user.fullName),
                const Divider(height: 24),
                _InfoRow(label: 'Correo', value: widget.user.email),
                const Divider(height: 24),
                _InfoRow(label: 'Rol', value: widget.user.roleLabel),
                const Divider(height: 24),
                _InfoRow(
                  label: 'Sexo',
                  value: switch (widget.user.sex) {
                    'female' => 'Mujer',
                    'male' => 'Hombre',
                    _ => 'No registrado',
                  },
                ),
                const Divider(height: 24),
                _InfoRow(
                  label: 'Programa',
                  value: (widget.user.program?.trim().isNotEmpty ?? false)
                      ? widget.user.program!.trim()
                      : 'No registrado',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.verified_user_outlined)),
            title: const Text('Estado de cuenta', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(widget.user.isAdmin ? 'Cuenta administrativa activa' : 'Cuenta activa'),
            trailing: const Chip(label: Text('Activa')),
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(onPressed: widget.onLogout, icon: const Icon(Icons.logout), label: const Text('Cerrar sesión')),
=======
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
>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78
      ],
    );
  }
}

<<<<<<< HEAD
class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip, required this.actionLabel, required this.onTap});
  final LocalTrip trip;
  final String actionLabel;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(child: InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: onTap,
    child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Chip(label: Text(_tripStatus(trip.status))), const Spacer(), Text('\$ ${trip.contribution}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800))]),
      const SizedBox(height: 8),
      Text('${trip.time} · ${trip.origin} → ${trip.destination}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Row(children: [const CircleAvatar(radius: 18, child: Icon(Icons.person, size: 18)), const SizedBox(width: 8), Expanded(child: Text(trip.driverName)), Text('${trip.seats} cupos', style: const TextStyle(color: AppTheme.muted))]),
      const SizedBox(height: 10),
      Align(alignment: Alignment.centerRight, child: Text(actionLabel, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700))),
    ])),
  ));
=======
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
>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78
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
<<<<<<< HEAD
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
      const SizedBox(height: 3),
      Row(children: [Icon(icon, size: 16), const SizedBox(width: 5), Expanded(child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis))]),
    ]),
=======
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.muted)), const SizedBox(height: 3), Row(children: [Icon(icon, size: 16), const SizedBox(width: 5), Expanded(child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis))])]),
>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78
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
<<<<<<< HEAD
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 64, color: AppTheme.primary),
    const SizedBox(height: 14),
    Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
    const SizedBox(height: 6),
    Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.muted)),
  ])));
}

String? _required(String? value) => value == null || value.trim().isEmpty ? 'Campo obligatorio.' : null;
String _tripStatus(String value) => switch (value) {
  'published' => 'Publicado',
  'started' => 'En curso',
  'completed' => 'Finalizado',
  _ => value,
};
String _bookingStatus(String value) => switch (value) {
  'requested' => 'Pendiente',
  'accepted' => 'Aceptada',
  'rejected' => 'Rechazada',
  _ => value,
};
=======
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

>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78
BoxDecoration _boxDecoration() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFC9D3E1)));
