import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../data/api/weather_api.dart';
import '../data/models/weather_condition.dart';
import '../features/settings/settings_cubit.dart';
import '../l10n/app_localizations.dart';

/// Pure unit conversions; the API always answers in °C and km/h.
abstract final class Units {
  static double temperature(double celsius, TemperatureUnit unit) =>
      unit == TemperatureUnit.fahrenheit ? celsius * 9 / 5 + 32 : celsius;

  static double wind(double kmh, WindUnit unit) => switch (unit) {
        WindUnit.kmh => kmh,
        WindUnit.ms => kmh / 3.6,
        WindUnit.mph => kmh / 1.609344,
      };

  static String windLabel(WindUnit unit) => switch (unit) {
        WindUnit.kmh => 'km/h',
        WindUnit.ms => 'm/s',
        WindUnit.mph => 'mph',
      };

  /// 0..7 index into an eight-point compass (N, NE, E…).
  static int compassIndex(int degrees) => ((degrees % 360) / 45).round() % 8;
}

extension WeatherFormat on BuildContext {
  AppLocalizations get l => AppLocalizations.of(this);

  String get _lang => Localizations.localeOf(this).languageCode;

  /// "23°" in the user's unit.
  String temp(double celsius) {
    final unit = read<SettingsCubit>().state.temperatureUnit;
    return '${Units.temperature(celsius, unit).round()}°';
  }

  String wind(double kmh) {
    final unit = read<SettingsCubit>().state.windUnit;
    return '${Units.wind(kmh, unit).round()} ${Units.windLabel(unit)}';
  }

  String compass(int degrees) => l.compass.split(',')[Units.compassIndex(degrees)];

  String hourMinute(DateTime t) => DateFormat.Hm(_lang).format(t);

  String hourOnly(DateTime t) => DateFormat.H(_lang).format(t);

  String weekday(DateTime t) => DateFormat.E(_lang).format(t);

  String dayMonth(DateTime t) => DateFormat.MMMEd(_lang).format(t);

  String condition(WeatherCondition c) => switch (c) {
        WeatherCondition.clear => l.condClear,
        WeatherCondition.mainlyClear => l.condMainlyClear,
        WeatherCondition.partlyCloudy => l.condPartlyCloudy,
        WeatherCondition.overcast => l.condOvercast,
        WeatherCondition.fog => l.condFog,
        WeatherCondition.drizzle => l.condDrizzle,
        WeatherCondition.freezingDrizzle => l.condFreezingDrizzle,
        WeatherCondition.lightRain => l.condLightRain,
        WeatherCondition.rain => l.condRain,
        WeatherCondition.heavyRain => l.condHeavyRain,
        WeatherCondition.freezingRain => l.condFreezingRain,
        WeatherCondition.lightSnow => l.condLightSnow,
        WeatherCondition.snow => l.condSnow,
        WeatherCondition.heavySnow => l.condHeavySnow,
        WeatherCondition.rainShowers => l.condRainShowers,
        WeatherCondition.heavyShowers => l.condHeavyShowers,
        WeatherCondition.snowShowers => l.condSnowShowers,
        WeatherCondition.thunderstorm => l.condThunderstorm,
        WeatherCondition.thunderstormHail => l.condThunderstormHail,
        WeatherCondition.unknown => l.condUnknown,
      };

  String failure(WeatherFailure f) => switch (f.kind) {
        FailureKind.offline => l.errorOffline,
        FailureKind.timeout => l.errorTimeout,
        FailureKind.server => l.errorServer,
        FailureKind.locationDenied => l.locationDenied,
        FailureKind.locationDisabled => l.locationDisabled,
        FailureKind.unknown => l.errorUnknown,
      };

  String uvLabel(double uv) => switch (uv) {
        < 3 => l.uvLow,
        < 6 => l.uvModerate,
        < 8 => l.uvHigh,
        < 11 => l.uvVeryHigh,
        _ => l.uvExtreme,
      };

  String aqiLabel(int level) =>
      [l.aqiGood, l.aqiFair, l.aqiModerate, l.aqiPoor, l.aqiVeryPoor, l.aqiExtreme][level];
}
