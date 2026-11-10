class TripSummary {
  const TripSummary({
    required this.id,
    required this.origin,
    required this.destination,
    required this.departsAt,
    required this.seats,
    required this.amount,
    required this.status,
    this.counterpartName,
  });

  final String id;
  final String origin;
  final String destination;
  final DateTime departsAt;
  final int seats;
  final num amount;
  final String status;
  final String? counterpartName;

  factory TripSummary.fromPassengerJson(Map<String, dynamic> json) {
    final trip = json['trip'];
    if (trip is! Map<String, dynamic>) {
      throw const FormatException('Reserva incompleta.');
    }
    final driver = trip['driver'];
    return TripSummary(
      id: _string(json, 'id'),
      origin: _string(trip, 'origin'),
      destination: _string(trip, 'destination'),
      departsAt: DateTime.parse(_string(trip, 'departs_at')),
      seats: _number(json, 'seats').toInt(),
      amount: _number(json, 'amount'),
      status: _string(json, 'status'),
      counterpartName: driver is Map && driver['full_name'] is String
          ? driver['full_name'] as String
          : null,
    );
  }

  factory TripSummary.fromDriverJson(Map<String, dynamic> json) {
    return TripSummary(
      id: _string(json, 'id'),
      origin: _string(json, 'origin'),
      destination: _string(json, 'destination'),
      departsAt: DateTime.parse(_string(json, 'departs_at')),
      seats: _number(json, 'seats_available').toInt(),
      amount: _number(json, 'price_per_seat'),
      status: _string(json, 'status'),
    );
  }

  static String _string(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.isEmpty) {
      throw const FormatException('Datos de viaje incompletos.');
    }
    return value;
  }

  static num _number(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! num || !value.isFinite || value < 0) {
      throw const FormatException('Datos numéricos de viaje no válidos.');
    }
    return value;
  }
}
