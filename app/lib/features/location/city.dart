/// A city from the bundled GeoNames list.
class City {
  const City({
    required this.name,
    required this.region,
    required this.countryCode,
    required this.countryName,
    required this.latitude,
    required this.longitude,
    required this.timeZone,
    required this.population,
    this.searchKeys = const [],
  });

  final String name;
  final String region;
  final String countryCode;
  final String countryName;
  final double latitude;
  final double longitude;

  /// IANA time zone, e.g. `Australia/Sydney`.
  final String timeZone;
  final int population;

  /// Normalised names used for search (name, ASCII name, alternates).
  final List<String> searchKeys;

  /// Short label as in the prototype, e.g. "Sydney, AU".
  String get shortLabel => '$name, $countryCode';

  /// Disambiguating detail, e.g. "New South Wales, Australia".
  String get detail =>
      [region, countryName].where((s) => s.isNotEmpty).join(', ');
}

/// Where the user's location came from.
enum LocationSource { device, manual }

/// The location prayer times and qibla are calculated for.
class UserLocation {
  const UserLocation({
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.source,
  });

  /// Chosen city, or the nearest city to the device position.
  final City city;

  /// Exact coordinates used for calculation. For a manual city these are
  /// the city's coordinates.
  final double latitude;
  final double longitude;
  final LocationSource source;

  factory UserLocation.fromCity(City city) => UserLocation(
    city: city,
    latitude: city.latitude,
    longitude: city.longitude,
    source: LocationSource.manual,
  );
}
