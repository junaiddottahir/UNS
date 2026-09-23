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

  Map<String, Object?> toJson() => {
    'name': name,
    'region': region,
    'cc': countryCode,
    'country': countryName,
    'lat': latitude,
    'lng': longitude,
    'tz': timeZone,
    'pop': population,
  };

  /// Null when [json] isn't a stored city.
  static City? fromJson(Map<String, Object?> json) {
    final (name, region, cc, country, lat, lng, tz, pop) = (
      json['name'],
      json['region'],
      json['cc'],
      json['country'],
      json['lat'],
      json['lng'],
      json['tz'],
      json['pop'],
    );
    if (name is! String ||
        region is! String ||
        cc is! String ||
        country is! String ||
        lat is! num ||
        lng is! num ||
        tz is! String ||
        pop is! int) {
      return null;
    }
    return City(
      name: name,
      region: region,
      countryCode: cc,
      countryName: country,
      latitude: lat.toDouble(),
      longitude: lng.toDouble(),
      timeZone: tz,
      population: pop,
    );
  }
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

  Map<String, Object?> toJson() => {
    'city': city.toJson(),
    'lat': latitude,
    'lng': longitude,
    'source': source.name,
  };

  /// Null when [json] isn't a stored location.
  static UserLocation? fromJson(Map<String, Object?> json) {
    final (cityJson, lat, lng, source) = (
      json['city'],
      json['lat'],
      json['lng'],
      json['source'],
    );
    final city = cityJson is Map<String, Object?>
        ? City.fromJson(cityJson)
        : null;
    final src = LocationSource.values.asNameMap()[source];
    if (city == null || lat is! num || lng is! num || src == null) {
      return null;
    }
    return UserLocation(
      city: city,
      latitude: lat.toDouble(),
      longitude: lng.toDouble(),
      source: src,
    );
  }
}
