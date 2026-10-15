import 'dart:convert';
import 'dart:io';

import 'package:atmos/core/format.dart';
import 'package:atmos/data/models/forecast.dart';
import 'package:atmos/data/models/weather_condition.dart';
import 'package:atmos/features/settings/settings_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/fixtures/$name').readAsStringSync()) as Map<String, dynamic>;

void main() {
  final json = fixture('forecast_istanbul.json');
  final forecast = Forecast.fromJson(
    json,
    airQuality: fixture('air_quality.json'),
    fetchedAt: DateTime.utc(2026, 10, 15, 12),
  );

  test('parses a real Open-Meteo response', () {
    expect(forecast.daily, hasLength(10));
    expect(forecast.hourly, hasLength(240));
    expect(forecast.utcOffset, const Duration(hours: 3));
    expect(forecast.daily.first.date.hour, 0);
    expect(forecast.daily.first.sunrise.isBefore(forecast.daily.first.sunset), isTrue);
    expect(forecast.airQuality, isNotNull);
  });

  test('upcoming hours start at the current hour in the city', () {
    final first = forecast.hourly.first.time;
    // 09:30 UTC is 12:30 in Istanbul, so the list should start at 12:00 local.
    final nowUtc = DateTime.utc(first.year, first.month, first.day, 9, 30);
    final hours = forecast.upcomingHours(nowUtc: nowUtc);
    expect(hours, hasLength(24));
    expect(hours.first.time.hour, 12);
  });

  test('temperature bounds cover every day', () {
    final (lo, hi) = forecast.temperatureBounds;
    for (final d in forecast.daily) {
      expect(d.min, greaterThanOrEqualTo(lo));
      expect(d.max, lessThanOrEqualTo(hi));
    }
  });

  test('maps WMO codes to conditions', () {
    expect(WeatherCondition.fromCode(0), WeatherCondition.clear);
    expect(WeatherCondition.fromCode(3).sky, Sky.cloudy);
    expect(WeatherCondition.fromCode(63), WeatherCondition.rain);
    expect(WeatherCondition.fromCode(75), WeatherCondition.heavySnow);
    expect(WeatherCondition.fromCode(99).sky, Sky.thunder);
    expect(WeatherCondition.fromCode(1234), WeatherCondition.unknown);
  });

  test('air quality levels follow the European AQI bands', () {
    expect(const AirQuality(europeanAqi: 15, pm25: 0, pm10: 0).level, 0);
    expect(const AirQuality(europeanAqi: 55, pm25: 0, pm10: 0).level, 2);
    expect(const AirQuality(europeanAqi: 140, pm25: 0, pm10: 0).level, 5);
  });

  group('Units', () {
    test('converts temperature and wind', () {
      expect(Units.temperature(0, TemperatureUnit.fahrenheit), 32);
      expect(Units.temperature(100, TemperatureUnit.fahrenheit), 212);
      expect(Units.wind(36, WindUnit.ms), 10);
      expect(Units.wind(16.09344, WindUnit.mph), closeTo(10, 1e-9));
    });

    test('finds the compass point', () {
      expect(Units.compassIndex(0), 0);
      expect(Units.compassIndex(350), 0);
      expect(Units.compassIndex(90), 2);
      expect(Units.compassIndex(225), 5);
    });
  });
}
