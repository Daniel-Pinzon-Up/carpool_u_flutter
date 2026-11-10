import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../services/carpool_service.dart';
import '../services/local_carpool_store.dart';
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

  Future<void> _logout() async {
    try {
      await widget.service.logout();
    } catch (_) {}
    widget.service.clearSession();
    widget.onSessionEnded();
  }

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
    }
  }

  void _openRequests() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => _RequestsPage(user: widget.user, store: _store),
    ));
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
          if (widget.user.isDriver)
            IconButton(
              tooltip: 'Solicitudes',
              onPressed: _openRequests,
              icon: const Icon(Icons.notifications_none_rounded),
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
  const _SearchPage({required this.user, required this.store});
  final AppUser user;
  final LocalCarpoolStore store;

  @override
  State<_SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<_SearchPage> {
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

  @override
  void dispose() {
    _origin.dispose();
    _destination.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: _boxDecoration(),
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
    );
  }
}

class _PublishTripPage extends StatefulWidget {
  const _PublishTripPage({required this.user, required this.store, required this.onPublished});
  final AppUser user;
  final LocalCarpoolStore store;
  final VoidCallback onPublished;

  @override
  State<_PublishTripPage> createState() => _PublishTripPageState();
}

class _PublishTripPageState extends State<_PublishTripPage> {
  final _formKey = GlobalKey<FormState>();
  final _origin = TextEditingController(text: 'Barrio El Carmen');
  final _destination = TextEditingController(text: 'Ciudad Universitaria');
  final _contribution = TextEditingController(text: '2000');
  int _seats = 3;
  bool _busy = false;

  @override
  void dispose() {
    _origin.dispose();
    _destination.dispose();
    _contribution.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        const Text('Publicar viaje', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
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
      ],
    );
  }
}

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
    );
  }
}

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

  @override
  State<_ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<_ChatPage> {
  final _controller = TextEditingController();
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        ],
      ),
    );
  }
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
  void initState() { super.initState(); _loadSavedPhoto(); }

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
      builder: (sheetContext) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: const Icon(Icons.photo_library_outlined), title: const Text('Elegir de la galería'), onTap: () => Navigator.pop(sheetContext, ImageSource.gallery)),
        ListTile(leading: const Icon(Icons.photo_camera_outlined), title: const Text('Tomar una foto'), onTap: () => Navigator.pop(sheetContext, ImageSource.camera)),
      ])),
    );
    if (source != null) await _pickAndSavePhoto(source);
  }

  Future<void> _pickAndSavePhoto(ImageSource source) async {
    if (_savingPhoto) return;
    setState(() => _savingPhoto = true);
    try {
      final image = await _picker.pickImage(source: source, imageQuality: 82, maxWidth: 1200);
      if (image == null) return;
      final directory = await getApplicationDocumentsDirectory();
      final savedFile = File('${directory.path}/profile_${widget.user.id}.jpg');
      await File(image.path).copy(savedFile.path);
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_storageKey, savedFile.path);
      if (mounted) setState(() => _photoPath = savedFile.path);
    } finally {
      if (mounted) setState(() => _savingPhoto = false);
    }
  }

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
      ],
    );
  }
}

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
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
      const SizedBox(height: 3),
      Row(children: [Icon(icon, size: 16), const SizedBox(width: 5), Expanded(child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis))]),
    ]),
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
BoxDecoration _boxDecoration() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFC9D3E1)));
