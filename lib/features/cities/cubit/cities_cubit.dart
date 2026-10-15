import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/api/weather_api.dart';
import '../../../data/models/city.dart';
import '../../../data/repositories/city_repository.dart';
import '../../../data/repositories/weather_repository.dart';

class CitiesState extends Equatable {
  const CitiesState({
    required this.cities,
    this.selectedIndex = 0,
    this.isLocating = false,
    this.locationFailure,
  });

  final List<City> cities;
  final int selectedIndex;
  final bool isLocating;
  final WeatherFailure? locationFailure;

  City? get selected => cities.isEmpty ? null : cities[selectedIndex.clamp(0, cities.length - 1)];

  CitiesState copyWith({
    List<City>? cities,
    int? selectedIndex,
    bool? isLocating,
    WeatherFailure? Function()? locationFailure,
  }) =>
      CitiesState(
        cities: cities ?? this.cities,
        selectedIndex: selectedIndex ?? this.selectedIndex,
        isLocating: isLocating ?? this.isLocating,
        locationFailure: locationFailure != null ? locationFailure() : this.locationFailure,
      );

  @override
  List<Object?> get props => [cities, selectedIndex, isLocating, locationFailure?.kind];
}

/// The user's saved cities and which one the home carousel shows.
class CitiesCubit extends Cubit<CitiesState> {
  CitiesCubit(this._cities, this._weather) : super(CitiesState(cities: _cities.loadSaved()));

  final CityRepository _cities;
  final WeatherRepository _weather;

  static const maxCities = 12;

  void select(int index) => emit(state.copyWith(selectedIndex: index));

  /// Adds a city (or jumps to it if it is already saved) and selects it.
  Future<void> add(City city) async {
    final existing = state.cities.indexWhere((c) => c.id == city.id);
    if (existing != -1) {
      emit(state.copyWith(selectedIndex: existing));
      return;
    }
    if (state.cities.length >= maxCities) return;
    final cities = [...state.cities, city];
    emit(state.copyWith(cities: cities, selectedIndex: cities.length - 1));
    await _cities.save(cities);
  }

  Future<void> remove(City city) async {
    if (state.cities.length <= 1) return;
    final cities = state.cities.where((c) => c.id != city.id).toList();
    _weather.forget(city);
    emit(state.copyWith(
      cities: cities,
      selectedIndex: state.selectedIndex.clamp(0, cities.length - 1),
    ));
    await _cities.save(cities);
  }

  /// [newIndex] is the final position, already adjusted for the removed item.
  Future<void> reorder(int oldIndex, int newIndex) async {
    final selectedId = state.selected?.id;
    final cities = [...state.cities];
    cities.insert(newIndex, cities.removeAt(oldIndex));
    // Keep showing the same city even though its position changed.
    final selected = cities.indexWhere((c) => c.id == selectedId);
    emit(state.copyWith(cities: cities, selectedIndex: selected == -1 ? 0 : selected));
    await _cities.save(cities);
  }

  /// Puts the GPS city first, replacing an older GPS entry.
  Future<void> useCurrentLocation({required String language, required String fallbackName}) async {
    emit(state.copyWith(isLocating: true, locationFailure: () => null));
    try {
      final here = await _cities.currentLocation(language: language, fallbackName: fallbackName);
      final cities = [
        here,
        ...state.cities.where((c) => !c.isCurrentLocation && c.id != here.id),
      ];
      emit(state.copyWith(cities: cities, selectedIndex: 0, isLocating: false));
      await _cities.save(cities);
    } on WeatherFailure catch (f) {
      emit(state.copyWith(isLocating: false, locationFailure: () => f));
    }
  }
}
