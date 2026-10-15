import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../api/weather_api.dart';
import '../models/city.dart';
import '../models/forecast.dart';

/// A forecast plus whether it came from the offline cache.
class ForecastResult {
  const ForecastResult(this.forecast, {this.isStale = false, this.failure});

  final Forecast forecast;

  /// True when the network failed and the last saved forecast is shown instead.
  final bool isStale;

  /// Why fresh data could not be loaded (only set when [isStale]).
  final WeatherFailure? failure;
}

/// Fetches forecasts and keeps the last good response of every city on disk,
/// so the app still has something to show without a connection.
class WeatherRepository {
  WeatherRepository(this._api, this._prefs, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final WeatherApi _api;
  final SharedPreferences _prefs;
  final DateTime Function() _clock;

  /// Memory cache so swiping between cities does not refetch every time.
  final _memory = <String, Forecast>{};
  static const _freshFor = Duration(minutes: 10);

  String _key(City c) => 'forecast.v1.${c.id}';

  Future<ForecastResult> load(City city, {bool force = false}) async {
    final cached = _memory[city.id];
    if (!force && cached != null && _clock().toUtc().difference(cached.fetchedAt) < _freshFor) {
      return ForecastResult(cached);
    }

    try {
      final fetchedAt = _clock().toUtc();
      final results = await Future.wait([
        _api.forecast(city),
        // Air quality is a nice extra; never fail the screen because of it.
        _api.airQuality(city).then<Map<String, dynamic>?>((v) => v).catchError((_) => null),
      ]);
      final forecastJson = results[0]!;
      final aqJson = results[1];
      final Forecast forecast;
      try {
        forecast = Forecast.fromJson(forecastJson, airQuality: aqJson, fetchedAt: fetchedAt);
      } catch (e) {
        throw WeatherFailure(FailureKind.unknown, 'Unexpected response: $e');
      }
      _memory[city.id] = forecast;
      await _prefs.setString(
        _key(city),
        jsonEncode({'forecast': forecastJson, 'aq': aqJson, 'fetchedAt': fetchedAt.toIso8601String()}),
      );
      return ForecastResult(forecast);
    } on WeatherFailure catch (failure) {
      final saved = _readSaved(city);
      if (saved == null) rethrow;
      return ForecastResult(saved, isStale: true, failure: failure);
    }
  }

  /// Whatever is already known about [city], instantly and without the network.
  Forecast? cached(City city) => _memory[city.id] ?? _readSaved(city);

  Forecast? _readSaved(City city) {
    final raw = _prefs.getString(_key(city));
    if (raw == null) return null;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      return Forecast.fromJson(
        j['forecast'] as Map<String, dynamic>,
        airQuality: j['aq'] as Map<String, dynamic>?,
        fetchedAt: DateTime.parse(j['fetchedAt'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  void forget(City city) {
    _memory.remove(city.id);
    _prefs.remove(_key(city));
  }
}
