import 'package:dio/dio.dart';

import '../models/city.dart';

enum FailureKind { offline, timeout, server, locationDenied, locationDisabled, unknown }

/// The only error type that leaves the data layer.
class WeatherFailure implements Exception {
  const WeatherFailure(this.kind, [this.detail]);

  final FailureKind kind;
  final String? detail;

  factory WeatherFailure.from(Object e) {
    if (e is WeatherFailure) return e;
    if (e is DioException) {
      return switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          const WeatherFailure(FailureKind.timeout),
        DioExceptionType.connectionError => const WeatherFailure(FailureKind.offline),
        DioExceptionType.badResponse =>
          WeatherFailure(FailureKind.server, 'HTTP ${e.response?.statusCode}'),
        _ => WeatherFailure(FailureKind.unknown, e.message),
      };
    }
    return WeatherFailure(FailureKind.unknown, e.toString());
  }

  @override
  String toString() => 'WeatherFailure($kind, $detail)';
}

/// Thin wrapper over the free Open-Meteo endpoints (no API key needed).
class WeatherApi {
  WeatherApi(this._dio);

  final Dio _dio;

  static const _current = 'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,'
      'precipitation,weather_code,pressure_msl,wind_speed_10m,wind_direction_10m';
  static const _hourly = 'temperature_2m,precipitation_probability,weather_code,is_day,visibility';
  static const _daily = 'weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,'
      'uv_index_max,precipitation_probability_max';

  Future<Map<String, dynamic>> forecast(City city) => _get(
        'https://api.open-meteo.com/v1/forecast',
        {
          'latitude': city.latitude,
          'longitude': city.longitude,
          'current': _current,
          'hourly': _hourly,
          'daily': _daily,
          'timezone': 'auto',
          'forecast_days': 10,
        },
      );

  Future<Map<String, dynamic>> airQuality(City city) => _get(
        'https://air-quality-api.open-meteo.com/v1/air-quality',
        {'latitude': city.latitude, 'longitude': city.longitude, 'current': 'european_aqi,pm2_5,pm10'},
      );

  Future<List<City>> searchCities(String query, {required String language}) async {
    final json = await _get('https://geocoding-api.open-meteo.com/v1/search', {
      'name': query,
      'count': 12,
      'language': language,
      'format': 'json',
    });
    return ((json['results'] as List?) ?? const [])
        .map((e) => City.fromGeocoding(e as Map<String, dynamic>))
        .toList();
  }

  /// Best-effort place name for GPS coordinates (BigDataCloud's free client endpoint).
  Future<String?> placeName(double lat, double lon, {required String language}) async {
    try {
      final json = await _get('https://api.bigdatacloud.net/data/reverse-geocode-client', {
        'latitude': lat,
        'longitude': lon,
        'localityLanguage': language,
      });
      final city = json['city'] as String?;
      final locality = json['locality'] as String?;
      final region = json['principalSubdivision'] as String?;
      return [city, locality, region].firstWhere((s) => s != null && s.isNotEmpty, orElse: () => null);
    } on WeatherFailure {
      return null;
    }
  }

  Future<Map<String, dynamic>> _get(String url, Map<String, dynamic> params) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(url, queryParameters: params);
      return res.data!;
    } catch (e) {
      throw WeatherFailure.from(e);
    }
  }
}
