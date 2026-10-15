import 'package:equatable/equatable.dart';

import 'weather_condition.dart';

/// Open-Meteo returns local wall-clock times without an offset ("2026-10-15T14:00").
/// They are parsed as UTC so they can be compared with [Forecast.cityNow]
/// regardless of the phone's own time zone.
DateTime _wall(String s) => DateTime.parse(s.length == 10 ? '${s}T00:00Z' : '${s}Z');

List<T> _list<T>(Map<String, dynamic> j, String key) => (j[key] as List).cast<T>();

double _d(num? v) => v?.toDouble() ?? 0;

class CurrentWeather extends Equatable {
  const CurrentWeather({
    required this.time,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.isDay,
    required this.precipitation,
    required this.condition,
    required this.pressure,
    required this.windSpeed,
    required this.windDirection,
  });

  final DateTime time;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final bool isDay;
  final double precipitation;
  final WeatherCondition condition;
  final double pressure;

  /// km/h
  final double windSpeed;

  /// Degrees, meteorological (direction the wind comes from).
  final int windDirection;

  factory CurrentWeather.fromJson(Map<String, dynamic> j) => CurrentWeather(
        time: _wall(j['time'] as String),
        temperature: _d(j['temperature_2m'] as num?),
        feelsLike: _d(j['apparent_temperature'] as num?),
        humidity: (j['relative_humidity_2m'] as num?)?.round() ?? 0,
        isDay: j['is_day'] == 1,
        precipitation: _d(j['precipitation'] as num?),
        condition: WeatherCondition.fromCode((j['weather_code'] as num?)?.toInt() ?? -1),
        pressure: _d(j['pressure_msl'] as num?),
        windSpeed: _d(j['wind_speed_10m'] as num?),
        windDirection: (j['wind_direction_10m'] as num?)?.round() ?? 0,
      );

  @override
  List<Object?> get props => [time, temperature, condition];
}

class HourlyForecast extends Equatable {
  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.precipitationChance,
    required this.condition,
    required this.isDay,
    required this.visibility,
  });

  final DateTime time;
  final double temperature;
  final int precipitationChance;
  final WeatherCondition condition;
  final bool isDay;

  /// Metres.
  final double visibility;

  @override
  List<Object?> get props => [time, temperature, condition];
}

class DailyForecast extends Equatable {
  const DailyForecast({
    required this.date,
    required this.condition,
    required this.max,
    required this.min,
    required this.sunrise,
    required this.sunset,
    required this.uvIndexMax,
    required this.precipitationChance,
  });

  final DateTime date;
  final WeatherCondition condition;
  final double max;
  final double min;
  final DateTime sunrise;
  final DateTime sunset;
  final double uvIndexMax;
  final int precipitationChance;

  @override
  List<Object?> get props => [date, max, min, condition];
}

class AirQuality extends Equatable {
  const AirQuality({required this.europeanAqi, required this.pm25, required this.pm10});

  final int europeanAqi;
  final double pm25;
  final double pm10;

  static AirQuality? fromJson(Map<String, dynamic>? json) {
    final c = json?['current'] as Map<String, dynamic>?;
    if (c == null || c['european_aqi'] == null) return null;
    return AirQuality(
      europeanAqi: (c['european_aqi'] as num).round(),
      pm25: _d(c['pm2_5'] as num?),
      pm10: _d(c['pm10'] as num?),
    );
  }

  /// 0 good … 5 extremely poor, following the European AQI bands.
  int get level => switch (europeanAqi) {
        <= 20 => 0,
        <= 40 => 1,
        <= 60 => 2,
        <= 80 => 3,
        <= 100 => 4,
        _ => 5,
      };

  @override
  List<Object?> get props => [europeanAqi, pm25, pm10];
}

class Forecast extends Equatable {
  const Forecast({
    required this.utcOffset,
    required this.timezone,
    required this.current,
    required this.hourly,
    required this.daily,
    required this.fetchedAt,
    this.airQuality,
  });

  final Duration utcOffset;
  final String timezone;
  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final AirQuality? airQuality;

  /// When the data was downloaded (UTC).
  final DateTime fetchedAt;

  /// The current wall-clock time in the forecast's city.
  DateTime cityNow([DateTime? nowUtc]) => (nowUtc ?? DateTime.now().toUtc()).add(utcOffset);

  /// The next [count] hours starting with the current one.
  List<HourlyForecast> upcomingHours({int count = 24, DateTime? nowUtc}) {
    final now = cityNow(nowUtc);
    final hourStart = DateTime.utc(now.year, now.month, now.day, now.hour);
    return hourly.where((h) => !h.time.isBefore(hourStart)).take(count).toList();
  }

  DailyForecast get today => daily.first;

  /// Coldest and warmest temperatures of the whole period, for range bars.
  (double, double) get temperatureBounds => (
        daily.map((d) => d.min).reduce((a, b) => a < b ? a : b),
        daily.map((d) => d.max).reduce((a, b) => a > b ? a : b),
      );

  /// Visibility for the current hour, in metres.
  double get currentVisibility {
    final hours = upcomingHours(count: 1);
    return hours.isEmpty ? 0 : hours.first.visibility;
  }

  factory Forecast.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? airQuality,
    required DateTime fetchedAt,
  }) {
    final h = json['hourly'] as Map<String, dynamic>;
    final hTimes = _list<String>(h, 'time');
    final d = json['daily'] as Map<String, dynamic>;
    final dTimes = _list<String>(d, 'time');

    return Forecast(
      utcOffset: Duration(seconds: (json['utc_offset_seconds'] as num).toInt()),
      timezone: json['timezone'] as String? ?? 'GMT',
      current: CurrentWeather.fromJson(json['current'] as Map<String, dynamic>),
      hourly: [
        for (var i = 0; i < hTimes.length; i++)
          HourlyForecast(
            time: _wall(hTimes[i]),
            temperature: _d(_list<num?>(h, 'temperature_2m')[i]),
            precipitationChance: _list<num?>(h, 'precipitation_probability')[i]?.round() ?? 0,
            condition: WeatherCondition.fromCode(_list<num?>(h, 'weather_code')[i]?.toInt() ?? -1),
            isDay: _list<num?>(h, 'is_day')[i] == 1,
            visibility: _d(_list<num?>(h, 'visibility')[i]),
          ),
      ],
      daily: [
        for (var i = 0; i < dTimes.length; i++)
          DailyForecast(
            date: _wall(dTimes[i]),
            condition: WeatherCondition.fromCode(_list<num?>(d, 'weather_code')[i]?.toInt() ?? -1),
            max: _d(_list<num?>(d, 'temperature_2m_max')[i]),
            min: _d(_list<num?>(d, 'temperature_2m_min')[i]),
            sunrise: _wall(_list<String>(d, 'sunrise')[i]),
            sunset: _wall(_list<String>(d, 'sunset')[i]),
            uvIndexMax: _d(_list<num?>(d, 'uv_index_max')[i]),
            precipitationChance: _list<num?>(d, 'precipitation_probability_max')[i]?.round() ?? 0,
          ),
      ],
      airQuality: AirQuality.fromJson(airQuality),
      fetchedAt: fetchedAt,
    );
  }

  @override
  List<Object?> get props => [fetchedAt, current, timezone];
}
