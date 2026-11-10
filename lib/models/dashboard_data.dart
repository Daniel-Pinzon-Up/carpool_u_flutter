import 'trip_summary.dart';

class DashboardData {
  const DashboardData({
    this.completedTrips,
    this.contribution,
    this.rating,
    this.ratingCount,
    this.unreadNotifications,
    this.upcomingTrips = const [],
    this.unavailableSections = const [],
  });

  final int? completedTrips;
  final num? contribution;
  final num? rating;
  final int? ratingCount;
  final int? unreadNotifications;
  final List<TripSummary> upcomingTrips;
  final List<String> unavailableSections;
}
