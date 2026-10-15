import 'dart:convert';
import 'dart:io';

import 'package:atmos/data/api/weather_api.dart';
import 'package:atmos/data/models/city.dart';
import 'package:atmos/data/models/forecast.dart';
import 'package:atmos/data/repositories/city_repository.dart';
import 'package:atmos/data/repositories/weather_repository.dart';
import 'package:atmos/features/cities/bloc/city_search_bloc.dart';
import 'package:atmos/features/cities/cubit/cities_cubit.dart';
import 'package:atmos/features/weather/bloc/weather_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

class MockCityRepository extends Mock implements CityRepository {}

class MockWeatherApi extends Mock implements WeatherApi {}

Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/fixtures/$name').readAsStringSync()) as Map<String, dynamic>;

const istanbul = City(name: 'İstanbul', latitude: 41.01, longitude: 28.95);
const ankara = City(name: 'Ankara', latitude: 39.92, longitude: 32.85);
const izmir = City(name: 'İzmir', latitude: 38.42, longitude: 27.14);

void main() {
  final forecast = Forecast.fromJson(fixture('forecast_istanbul.json'), fetchedAt: DateTime.utc(2026));
  setUpAll(() => registerFallbackValue(istanbul));

  group('WeatherBloc', () {
    late MockWeatherRepository repo;
    setUp(() {
      repo = MockWeatherRepository();
      when(() => repo.cached(any())).thenReturn(null);
    });

    blocTest<WeatherBloc, WeatherState>(
      'shows the saved forecast first, then the fresh one',
      setUp: () {
        when(() => repo.cached(any())).thenReturn(forecast);
        when(() => repo.load(any(), force: any(named: 'force')))
            .thenAnswer((_) async => ForecastResult(forecast));
      },
      build: () => WeatherBloc(city: istanbul, repository: repo),
      act: (b) => b.add(const WeatherStarted()),
      expect: () => [
        WeatherState(status: WeatherStatus.success, forecast: forecast),
        WeatherState(status: WeatherStatus.success, forecast: forecast, isRefreshing: true),
        WeatherState(status: WeatherStatus.success, forecast: forecast),
      ],
    );

    blocTest<WeatherBloc, WeatherState>(
      'loads the forecast',
      setUp: () => when(() => repo.load(any(), force: any(named: 'force')))
          .thenAnswer((_) async => ForecastResult(forecast)),
      build: () => WeatherBloc(city: istanbul, repository: repo),
      act: (b) => b.add(const WeatherStarted()),
      expect: () => [
        const WeatherState(status: WeatherStatus.loading),
        WeatherState(status: WeatherStatus.success, forecast: forecast),
      ],
    );

    blocTest<WeatherBloc, WeatherState>(
      'shows the cached forecast as stale when offline',
      setUp: () => when(() => repo.load(any(), force: any(named: 'force'))).thenAnswer(
        (_) async => ForecastResult(forecast, isStale: true, failure: const WeatherFailure(FailureKind.offline)),
      ),
      build: () => WeatherBloc(city: istanbul, repository: repo),
      act: (b) => b.add(const WeatherStarted()),
      skip: 1,
      verify: (b) {
        expect(b.state.isStale, isTrue);
        expect(b.state.failure?.kind, FailureKind.offline);
      },
    );

    blocTest<WeatherBloc, WeatherState>(
      'fails when there is nothing to show',
      setUp: () => when(() => repo.load(any(), force: any(named: 'force')))
          .thenThrow(const WeatherFailure(FailureKind.timeout)),
      build: () => WeatherBloc(city: istanbul, repository: repo),
      act: (b) => b.add(const WeatherStarted()),
      expect: () => [
        const WeatherState(status: WeatherStatus.loading),
        const WeatherState(status: WeatherStatus.failure, failure: WeatherFailure(FailureKind.timeout)),
      ],
    );

    blocTest<WeatherBloc, WeatherState>(
      'keeps old data on screen when a refresh fails',
      setUp: () => when(() => repo.load(any(), force: true))
          .thenThrow(const WeatherFailure(FailureKind.offline)),
      build: () => WeatherBloc(city: istanbul, repository: repo),
      seed: () => WeatherState(status: WeatherStatus.success, forecast: forecast),
      act: (b) => b.add(const WeatherRefreshed()),
      expect: () => [
        WeatherState(status: WeatherStatus.success, forecast: forecast, isRefreshing: true),
        WeatherState(
          status: WeatherStatus.success,
          forecast: forecast,
          isStale: true,
          failure: const WeatherFailure(FailureKind.offline),
        ),
      ],
    );
  });

  group('CitySearchBloc', () {
    late MockCityRepository repo;
    setUp(() => repo = MockCityRepository());

    blocTest<CitySearchBloc, CitySearchState>(
      'ignores one-letter queries',
      build: () => CitySearchBloc(repo, debounce: Duration.zero),
      act: (b) => b.add(const SearchQueryChanged('a', language: 'en')),
      wait: const Duration(milliseconds: 20),
      expect: () => [const CitySearchState(query: 'a')],
      verify: (_) => verifyNever(() => repo.search(any(), language: any(named: 'language'))),
    );

    blocTest<CitySearchBloc, CitySearchState>(
      'debounces typing and searches only the last query',
      setUp: () => when(() => repo.search('Malatya', language: 'tr'))
          .thenAnswer((_) async => [istanbul]),
      build: () => CitySearchBloc(repo, debounce: const Duration(milliseconds: 50)),
      act: (b) => b
        ..add(const SearchQueryChanged('Mal', language: 'tr'))
        ..add(const SearchQueryChanged('Malat', language: 'tr'))
        ..add(const SearchQueryChanged('Malatya', language: 'tr')),
      wait: const Duration(milliseconds: 150),
      expect: () => [
        const CitySearchState(query: 'Malatya', status: SearchStatus.loading),
        const CitySearchState(query: 'Malatya', status: SearchStatus.success, results: [istanbul]),
      ],
      verify: (_) => verify(() => repo.search(any(), language: any(named: 'language'))).called(1),
    );

    blocTest<CitySearchBloc, CitySearchState>(
      'reports when nothing matches',
      setUp: () => when(() => repo.search(any(), language: any(named: 'language'))).thenAnswer((_) async => []),
      build: () => CitySearchBloc(repo, debounce: Duration.zero),
      act: (b) => b.add(const SearchQueryChanged('Xyzzy', language: 'en')),
      wait: const Duration(milliseconds: 20),
      skip: 1,
      expect: () => [const CitySearchState(query: 'Xyzzy', status: SearchStatus.empty)],
    );
  });

  group('CitiesCubit', () {
    late MockCityRepository cities;
    late MockWeatherRepository weather;
    setUp(() {
      cities = MockCityRepository();
      weather = MockWeatherRepository();
      when(() => cities.loadSaved()).thenReturn([istanbul, ankara]);
      when(() => cities.save(any())).thenAnswer((_) async {});
    });

    test('adding a saved city selects it instead of duplicating', () async {
      final cubit = CitiesCubit(cities, weather);
      await cubit.add(const City(name: 'Istanbul (again)', latitude: 41.0101, longitude: 28.9499));
      expect(cubit.state.cities, hasLength(2));
      expect(cubit.state.selectedIndex, 0);
      await cubit.add(izmir);
      expect(cubit.state.cities.last, izmir);
      expect(cubit.state.selectedIndex, 2);
    });

    test('never removes the last city', () async {
      when(() => cities.loadSaved()).thenReturn([istanbul]);
      final cubit = CitiesCubit(cities, weather);
      await cubit.remove(istanbul);
      expect(cubit.state.cities, [istanbul]);
    });

    test('reordering keeps the selected city on screen', () async {
      when(() => cities.loadSaved()).thenReturn([istanbul, ankara, izmir]);
      final cubit = CitiesCubit(cities, weather)..select(2);
      await cubit.reorder(2, 0);
      expect(cubit.state.cities.first, izmir);
      expect(cubit.state.selected, izmir);
    });
  });

  group('WeatherRepository', () {
    test('falls back to the saved forecast when offline', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final api = MockWeatherApi();
      when(() => api.forecast(any())).thenAnswer((_) async => fixture('forecast_istanbul.json'));
      when(() => api.airQuality(any())).thenAnswer((_) async => fixture('air_quality.json'));

      final online = await WeatherRepository(api, prefs).load(istanbul);
      expect(online.isStale, isFalse);

      when(() => api.forecast(any())).thenThrow(const WeatherFailure(FailureKind.offline));
      final offline = await WeatherRepository(api, prefs).load(istanbul, force: true);
      expect(offline.isStale, isTrue);
      expect(offline.forecast.daily, hasLength(10));
    });

    test('throws when offline with nothing saved', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final api = MockWeatherApi();
      when(() => api.forecast(any())).thenThrow(const WeatherFailure(FailureKind.offline));
      when(() => api.airQuality(any())).thenThrow(const WeatherFailure(FailureKind.offline));
      expect(
        () => WeatherRepository(api, prefs).load(istanbul),
        throwsA(isA<WeatherFailure>().having((f) => f.kind, 'kind', FailureKind.offline)),
      );
    });
  });
}
