import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/api/weather_api.dart';
import '../../../data/models/city.dart';
import '../../../data/models/forecast.dart';
import '../../../data/repositories/weather_repository.dart';

sealed class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object?> get props => [];
}

/// First load when a city page appears.
final class WeatherStarted extends WeatherEvent {
  const WeatherStarted();
}

/// Pull-to-refresh or the retry button: always goes to the network.
final class WeatherRefreshed extends WeatherEvent {
  const WeatherRefreshed();
}

enum WeatherStatus { initial, loading, success, failure }

class WeatherState extends Equatable {
  const WeatherState({
    this.status = WeatherStatus.initial,
    this.forecast,
    this.isStale = false,
    this.isRefreshing = false,
    this.failure,
  });

  final WeatherStatus status;
  final Forecast? forecast;

  /// Showing the saved forecast because the network is unavailable.
  final bool isStale;
  final bool isRefreshing;
  final WeatherFailure? failure;

  WeatherState copyWith({
    WeatherStatus? status,
    Forecast? forecast,
    bool? isStale,
    bool? isRefreshing,
    WeatherFailure? Function()? failure,
  }) =>
      WeatherState(
        status: status ?? this.status,
        forecast: forecast ?? this.forecast,
        isStale: isStale ?? this.isStale,
        isRefreshing: isRefreshing ?? this.isRefreshing,
        failure: failure != null ? failure() : this.failure,
      );

  @override
  List<Object?> get props => [status, forecast, isStale, isRefreshing, failure?.kind];
}

/// Loads the forecast of one city. Each page of the city carousel owns one.
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc({required this.city, required this.repository}) : super(const WeatherState()) {
    // A new request cancels one that is still running.
    on<WeatherStarted>((_, emit) => _load(emit, force: false), transformer: restartable());
    on<WeatherRefreshed>((_, emit) => _load(emit, force: true), transformer: droppable());
  }

  final City city;
  final WeatherRepository repository;

  Future<void> _load(Emitter<WeatherState> emit, {required bool force}) async {
    // Show the last saved forecast straight away and refresh it in the background.
    if (state.forecast == null) {
      final cached = repository.cached(city);
      if (cached != null) emit(WeatherState(status: WeatherStatus.success, forecast: cached));
    }
    final hasData = state.forecast != null;
    emit(hasData
        ? state.copyWith(isRefreshing: true)
        : state.copyWith(status: WeatherStatus.loading, failure: () => null));
    try {
      final result = await repository.load(city, force: force);
      emit(WeatherState(
        status: WeatherStatus.success,
        forecast: result.forecast,
        isStale: result.isStale,
        failure: result.failure,
      ));
    } catch (e) {
      final failure = WeatherFailure.from(e);
      // Keep what is already on screen and just report the problem.
      emit(hasData
          ? state.copyWith(isRefreshing: false, isStale: true, failure: () => failure)
          : WeatherState(status: WeatherStatus.failure, failure: failure));
    }
  }
}
