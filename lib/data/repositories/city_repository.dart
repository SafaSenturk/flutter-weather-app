import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/weather_api.dart';
import '../models/city.dart';

/// Saved cities, city search and the device location.
class CityRepository {
  CityRepository(this._api, this._prefs);

  final WeatherApi _api;
  final SharedPreferences _prefs;

  static const _key = 'cities.v1';

  /// Shown on first launch so the app is never empty.
  static const defaults = [
    City(name: 'İstanbul', latitude: 41.0138, longitude: 28.9497, region: 'İstanbul', country: 'Türkiye', countryCode: 'TR'),
    City(name: 'London', latitude: 51.5085, longitude: -0.1257, region: 'England', country: 'United Kingdom', countryCode: 'GB'),
    City(name: 'Tokyo', latitude: 35.6895, longitude: 139.6917, region: 'Tokyo', country: 'Japan', countryCode: 'JP'),
  ];

  List<City> loadSaved() {
    final raw = _prefs.getString(_key);
    if (raw == null) return defaults;
    try {
      return (jsonDecode(raw) as List).map((e) => City.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return defaults;
    }
  }

  Future<void> save(List<City> cities) =>
      _prefs.setString(_key, jsonEncode(cities.map((c) => c.toJson()).toList()));

  Future<List<City>> search(String query, {required String language}) =>
      _api.searchCities(query, language: language);

  /// Asks for permission if needed and resolves the current position to a city.
  Future<City> currentLocation({required String language, required String fallbackName}) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const WeatherFailure(FailureKind.locationDisabled);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      throw const WeatherFailure(FailureKind.locationDenied);
    }
    final Position pos;
    try {
      pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (_) {
      throw const WeatherFailure(FailureKind.timeout);
    }
    final name = await _api.placeName(pos.latitude, pos.longitude, language: language);
    return City(
      name: name ?? fallbackName,
      latitude: pos.latitude,
      longitude: pos.longitude,
      isCurrentLocation: true,
    );
  }
}
