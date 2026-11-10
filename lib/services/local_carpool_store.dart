import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';

class LocalTrip {
  const LocalTrip({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.origin,
    required this.destination,
    required this.date,
    required this.time,
    required this.contribution,
    required this.seats,
    required this.status,
  });

  final String id;
  final String driverId;
  final String driverName;
  final String origin;
  final String destination;
  final String date;
  final String time;
  final int contribution;
  final int seats;
  final String status;

  bool get isOpen => status == 'published';
  bool get isInProgress => status == 'started';

  LocalTrip copyWith({String? status}) => LocalTrip(
        id: id,
        driverId: driverId,
        driverName: driverName,
        origin: origin,
        destination: destination,
        date: date,
        time: time,
        contribution: contribution,
        seats: seats,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'driver_id': driverId,
        'driver_name': driverName,
        'origin': origin,
        'destination': destination,
        'date': date,
        'time': time,
        'contribution': contribution,
        'seats': seats,
        'status': status,
      };

  factory LocalTrip.fromJson(Map<String, dynamic> json) => LocalTrip(
        id: json['id'] as String,
        driverId: json['driver_id'] as String,
        driverName: json['driver_name'] as String,
        origin: json['origin'] as String,
        destination: json['destination'] as String,
        date: json['date'] as String,
        time: json['time'] as String,
        contribution: (json['contribution'] as num).toInt(),
        seats: (json['seats'] as num).toInt(),
        status: json['status'] as String,
      );
}

class LocalBooking {
  const LocalBooking({
    required this.id,
    required this.tripId,
    required this.passengerId,
    required this.passengerName,
    required this.seats,
    required this.status,
  });

  final String id;
  final String tripId;
  final String passengerId;
  final String passengerName;
  final int seats;
  final String status;

  LocalBooking copyWith({String? status}) => LocalBooking(
        id: id,
        tripId: tripId,
        passengerId: passengerId,
        passengerName: passengerName,
        seats: seats,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'trip_id': tripId,
        'passenger_id': passengerId,
        'passenger_name': passengerName,
        'seats': seats,
        'status': status,
      };

  factory LocalBooking.fromJson(Map<String, dynamic> json) => LocalBooking(
        id: json['id'] as String,
        tripId: json['trip_id'] as String,
        passengerId: json['passenger_id'] as String,
        passengerName: json['passenger_name'] as String,
        seats: (json['seats'] as num).toInt(),
        status: json['status'] as String,
      );
}

class LocalMessage {
  const LocalMessage({
    required this.id,
    required this.bookingId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.sentAt,
  });

  final String id;
  final String bookingId;
  final String senderId;
  final String senderName;
  final String text;
  final String sentAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'booking_id': bookingId,
        'sender_id': senderId,
        'sender_name': senderName,
        'text': text,
        'sent_at': sentAt,
      };

  factory LocalMessage.fromJson(Map<String, dynamic> json) => LocalMessage(
        id: json['id'] as String,
        bookingId: json['booking_id'] as String,
        senderId: json['sender_id'] as String,
        senderName: json['sender_name'] as String,
        text: json['text'] as String,
        sentAt: json['sent_at'] as String,
      );
}

class LocalConversation {
  const LocalConversation({
    required this.booking,
    required this.trip,
    required this.otherName,
  });

  final LocalBooking booking;
  final LocalTrip trip;
  final String otherName;
}

class LocalCarpoolStore {
  static const _tripsKey = 'carpool_shared_trips_v2';
  static const _bookingsKey = 'carpool_shared_bookings_v2';
  static const _messagesKey = 'carpool_shared_messages_v2';

  Future<List<LocalTrip>> getTrips() async {
    final prefs = await SharedPreferences.getInstance();
    return _decodeList(prefs.getString(_tripsKey))
        .map(LocalTrip.fromJson)
        .toList(growable: false);
  }

  Future<List<LocalBooking>> getBookings() async {
    final prefs = await SharedPreferences.getInstance();
    return _decodeList(prefs.getString(_bookingsKey))
        .map(LocalBooking.fromJson)
        .toList(growable: false);
  }

  Future<List<LocalMessage>> getMessages() async {
    final prefs = await SharedPreferences.getInstance();
    return _decodeList(prefs.getString(_messagesKey))
        .map(LocalMessage.fromJson)
        .toList(growable: false);
  }

  Future<LocalTrip> publishTrip({
    required AppUser driver,
    required String origin,
    required String destination,
    required String date,
    required String time,
    required int contribution,
    required int seats,
  }) async {
    final trips = (await getTrips()).toList();
    final trip = LocalTrip(
      id: 'trip-${DateTime.now().microsecondsSinceEpoch}',
      driverId: driver.id,
      driverName: driver.fullName,
      origin: origin.trim(),
      destination: destination.trim(),
      date: date,
      time: time,
      contribution: contribution,
      seats: seats,
      status: 'published',
    );
    trips.insert(0, trip);
    await _saveTrips(trips);
    return trip;
  }

  Future<LocalBooking> requestTrip({
    required AppUser passenger,
    required LocalTrip trip,
    required int seats,
  }) async {
    final bookings = (await getBookings()).toList();
    final existing = bookings.where(
      (b) => b.tripId == trip.id && b.passengerId == passenger.id && b.status != 'rejected',
    );
    if (existing.isNotEmpty) return existing.first;
    final booking = LocalBooking(
      id: 'booking-${DateTime.now().microsecondsSinceEpoch}',
      tripId: trip.id,
      passengerId: passenger.id,
      passengerName: passenger.fullName,
      seats: seats,
      status: 'requested',
    );
    bookings.insert(0, booking);
    await _saveBookings(bookings);
    return booking;
  }

  Future<void> answerBooking(String bookingId, bool accepted) async {
    final bookings = (await getBookings()).toList();
    final index = bookings.indexWhere((b) => b.id == bookingId);
    if (index < 0) return;
    bookings[index] = bookings[index].copyWith(status: accepted ? 'accepted' : 'rejected');
    await _saveBookings(bookings);
  }

  Future<void> startTrip(String tripId) async {
    final trips = (await getTrips()).toList();
    final index = trips.indexWhere((t) => t.id == tripId);
    if (index < 0) return;
    trips[index] = trips[index].copyWith(status: 'started');
    await _saveTrips(trips);
  }

  Future<void> finishTrip(String tripId) async {
    final trips = (await getTrips()).toList();
    final index = trips.indexWhere((t) => t.id == tripId);
    if (index < 0) return;
    trips[index] = trips[index].copyWith(status: 'completed');
    await _saveTrips(trips);
  }

  Future<List<LocalTrip>> availableTrips({String? excludeDriverId}) async {
    final trips = await getTrips();
    return trips
        .where((t) => t.isOpen && t.driverId != excludeDriverId)
        .toList(growable: false);
  }

  Future<List<LocalTrip>> tripsForDriver(String driverId) async {
    final trips = await getTrips();
    return trips.where((t) => t.driverId == driverId).toList(growable: false);
  }

  Future<List<LocalBooking>> bookingsForDriver(String driverId) async {
    final trips = await tripsForDriver(driverId);
    final ids = trips.map((t) => t.id).toSet();
    final bookings = await getBookings();
    return bookings.where((b) => ids.contains(b.tripId)).toList(growable: false);
  }

  Future<List<LocalBooking>> bookingsForPassenger(String passengerId) async {
    final bookings = await getBookings();
    return bookings.where((b) => b.passengerId == passengerId).toList(growable: false);
  }

  Future<List<LocalConversation>> conversationsFor(AppUser user) async {
    final trips = await getTrips();
    final bookings = await getBookings();
    final tripById = {for (final t in trips) t.id: t};
    final conversations = <LocalConversation>[];
    for (final booking in bookings) {
      if (booking.status != 'accepted') continue;
      final trip = tripById[booking.tripId];
      if (trip == null) continue;
      if (user.id == booking.passengerId) {
        conversations.add(LocalConversation(
          booking: booking,
          trip: trip,
          otherName: trip.driverName,
        ));
      } else if (user.id == trip.driverId) {
        conversations.add(LocalConversation(
          booking: booking,
          trip: trip,
          otherName: booking.passengerName,
        ));
      }
    }
    return conversations;
  }

  Future<List<LocalMessage>> messagesFor(String bookingId) async {
    final messages = await getMessages();
    return messages.where((m) => m.bookingId == bookingId).toList(growable: false);
  }

  Future<void> sendMessage({
    required String bookingId,
    required AppUser sender,
    required String text,
  }) async {
    final clean = text.trim();
    if (clean.isEmpty) return;
    final messages = (await getMessages()).toList();
    messages.add(LocalMessage(
      id: 'message-${DateTime.now().microsecondsSinceEpoch}',
      bookingId: bookingId,
      senderId: sender.id,
      senderName: sender.fullName,
      text: clean,
      sentAt: DateTime.now().toIso8601String(),
    ));
    await _saveMessages(messages);
  }

  Future<void> _saveTrips(List<LocalTrip> trips) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tripsKey, jsonEncode(trips.map((e) => e.toJson()).toList()));
  }

  Future<void> _saveBookings(List<LocalBooking> bookings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bookingsKey, jsonEncode(bookings.map((e) => e.toJson()).toList()));
  }

  Future<void> _saveMessages(List<LocalMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_messagesKey, jsonEncode(messages.map((e) => e.toJson()).toList()));
  }

  static List<Map<String, dynamic>> _decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }
}
