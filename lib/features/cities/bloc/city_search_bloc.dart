import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../data/api/weather_api.dart';
import '../../../data/models/city.dart';
import '../../../data/repositories/city_repository.dart';

final class SearchQueryChanged extends Equatable {
  const SearchQueryChanged(this.query, {required this.language});

  final String query;
  final String language;

  @override
  List<Object?> get props => [query, language];
}

enum SearchStatus { idle, loading, success, empty, failure }

class CitySearchState extends Equatable {
  const CitySearchState({
    this.query = '',
    this.status = SearchStatus.idle,
    this.results = const [],
    this.failure,
  });

  final String query;
  final SearchStatus status;
  final List<City> results;
  final WeatherFailure? failure;

  @override
  List<Object?> get props => [query, status, results, failure?.kind];
}

/// Waits for the user to stop typing, then searches; a newer query cancels
/// an older request so results never arrive out of order.
EventTransformer<E> debounceRestartable<E>(Duration duration) =>
    (events, mapper) => restartable<E>().call(events.debounce(duration), mapper);

class CitySearchBloc extends Bloc<SearchQueryChanged, CitySearchState> {
  CitySearchBloc(this._repository, {Duration debounce = const Duration(milliseconds: 350)})
      : super(const CitySearchState()) {
    on<SearchQueryChanged>(_onQuery, transformer: debounceRestartable(debounce));
  }

  final CityRepository _repository;

  Future<void> _onQuery(SearchQueryChanged event, Emitter<CitySearchState> emit) async {
    final query = event.query.trim();
    if (query.length < 2) {
      emit(CitySearchState(query: query));
      return;
    }
    emit(CitySearchState(query: query, status: SearchStatus.loading, results: state.results));
    try {
      final results = await _repository.search(query, language: event.language);
      emit(CitySearchState(
        query: query,
        status: results.isEmpty ? SearchStatus.empty : SearchStatus.success,
        results: results,
      ));
    } on WeatherFailure catch (f) {
      emit(CitySearchState(query: query, status: SearchStatus.failure, failure: f));
    }
  }
}
