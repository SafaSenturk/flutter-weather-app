import 'package:equatable/equatable.dart';

class City extends Equatable {
  const City({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.region,
    this.country,
    this.countryCode,
    this.isCurrentLocation = false,
  });

  final String name;
  final double latitude;
  final double longitude;
  final String? region;
  final String? country;
  final String? countryCode;

  /// True for the entry created from the device's GPS position.
  final bool isCurrentLocation;

  /// Stable id built from rounded coordinates, so the same place found twice
  /// (e.g. by search and by GPS) is recognised as a duplicate.
  String get id => '${latitude.toStringAsFixed(2)},${longitude.toStringAsFixed(2)}';

  String get subtitle => [region, country].whereType<String>().where((s) => s.isNotEmpty).join(', ');

  /// Builds a city from an Open-Meteo geocoding result.
  factory City.fromGeocoding(Map<String, dynamic> j) => City(
        name: j['name'] as String,
        latitude: (j['latitude'] as num).toDouble(),
        longitude: (j['longitude'] as num).toDouble(),
        region: j['admin1'] as String?,
        country: j['country'] as String?,
        countryCode: j['country_code'] as String?,
      );

  factory City.fromJson(Map<String, dynamic> j) => City(
        name: j['name'] as String,
        latitude: (j['latitude'] as num).toDouble(),
        longitude: (j['longitude'] as num).toDouble(),
        region: j['region'] as String?,
        country: j['country'] as String?,
        countryCode: j['countryCode'] as String?,
        isCurrentLocation: j['isCurrentLocation'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'region': region,
        'country': country,
        'countryCode': countryCode,
        'isCurrentLocation': isCurrentLocation,
      };

  @override
  List<Object?> get props => [id, name, isCurrentLocation];
}
