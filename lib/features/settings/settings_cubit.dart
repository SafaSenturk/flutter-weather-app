import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TemperatureUnit { celsius, fahrenheit }

enum WindUnit { kmh, ms, mph }

class SettingsState extends Equatable {
  const SettingsState({
    this.temperatureUnit = TemperatureUnit.celsius,
    this.windUnit = WindUnit.kmh,
    this.locale,
  });

  final TemperatureUnit temperatureUnit;
  final WindUnit windUnit;

  /// Null follows the device language.
  final Locale? locale;

  SettingsState copyWith({TemperatureUnit? temperatureUnit, WindUnit? windUnit, Locale? locale}) =>
      SettingsState(
        temperatureUnit: temperatureUnit ?? this.temperatureUnit,
        windUnit: windUnit ?? this.windUnit,
        locale: locale ?? this.locale,
      );

  @override
  List<Object?> get props => [temperatureUnit, windUnit, locale];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._prefs)
      : super(SettingsState(
          temperatureUnit: TemperatureUnit.values.asNameMap()[_prefs.getString(_tempKey)] ??
              TemperatureUnit.celsius,
          windUnit: WindUnit.values.asNameMap()[_prefs.getString(_windKey)] ?? WindUnit.kmh,
          locale: switch (_prefs.getString(_localeKey)) {
            final String code => Locale(code),
            null => null,
          },
        ));

  final SharedPreferences _prefs;

  static const _tempKey = 'settings.temp';
  static const _windKey = 'settings.wind';
  static const _localeKey = 'settings.locale';

  void setTemperatureUnit(TemperatureUnit unit) {
    emit(state.copyWith(temperatureUnit: unit));
    _prefs.setString(_tempKey, unit.name);
  }

  void setWindUnit(WindUnit unit) {
    emit(state.copyWith(windUnit: unit));
    _prefs.setString(_windKey, unit.name);
  }

  void setLocale(Locale locale) {
    emit(state.copyWith(locale: locale));
    _prefs.setString(_localeKey, locale.languageCode);
  }
}
