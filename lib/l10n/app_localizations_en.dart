// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Atmos';

  @override
  String feelsLike(String temp) {
    return 'Feels like $temp';
  }

  @override
  String highLow(String high, String low) {
    return 'H $high  ·  L $low';
  }

  @override
  String get hourlyForecast => 'Hourly forecast';

  @override
  String get dailyForecast => '10-day forecast';

  @override
  String get now => 'Now';

  @override
  String get today => 'Today';

  @override
  String get wind => 'Wind';

  @override
  String get humidity => 'Humidity';

  @override
  String get uvIndex => 'UV index';

  @override
  String get pressure => 'Pressure';

  @override
  String get visibility => 'Visibility';

  @override
  String get sunrise => 'Sunrise';

  @override
  String get sunset => 'Sunset';

  @override
  String get airQuality => 'Air quality';

  @override
  String get precipitation => 'Precipitation';

  @override
  String precipitationToday(String amount) {
    return '$amount mm in the last hour';
  }

  @override
  String chanceOfRain(int percent) {
    return '$percent% chance today';
  }

  @override
  String get uvLow => 'Low';

  @override
  String get uvModerate => 'Moderate';

  @override
  String get uvHigh => 'High';

  @override
  String get uvVeryHigh => 'Very high';

  @override
  String get uvExtreme => 'Extreme';

  @override
  String get aqiGood => 'Good';

  @override
  String get aqiFair => 'Fair';

  @override
  String get aqiModerate => 'Moderate';

  @override
  String get aqiPoor => 'Poor';

  @override
  String get aqiVeryPoor => 'Very poor';

  @override
  String get aqiExtreme => 'Extremely poor';

  @override
  String get compass => 'N,NE,E,SE,S,SW,W,NW';

  @override
  String windFrom(String direction) {
    return 'from $direction';
  }

  @override
  String get pressureHigh => 'High pressure, settled weather';

  @override
  String get pressureNormal => 'Normal for sea level';

  @override
  String get pressureLow => 'Low pressure, unsettled';

  @override
  String get dewHumid => 'Humid air';

  @override
  String get dewComfortable => 'Comfortable';

  @override
  String get dewDry => 'Dry air';

  @override
  String get visibilityClear => 'Perfectly clear';

  @override
  String get visibilityHazy => 'Hazy';

  @override
  String get visibilityPoor => 'Poor visibility';

  @override
  String get condClear => 'Clear';

  @override
  String get condMainlyClear => 'Mostly clear';

  @override
  String get condPartlyCloudy => 'Partly cloudy';

  @override
  String get condOvercast => 'Cloudy';

  @override
  String get condFog => 'Fog';

  @override
  String get condDrizzle => 'Drizzle';

  @override
  String get condFreezingDrizzle => 'Freezing drizzle';

  @override
  String get condLightRain => 'Light rain';

  @override
  String get condRain => 'Rain';

  @override
  String get condHeavyRain => 'Heavy rain';

  @override
  String get condFreezingRain => 'Freezing rain';

  @override
  String get condLightSnow => 'Light snow';

  @override
  String get condSnow => 'Snow';

  @override
  String get condHeavySnow => 'Heavy snow';

  @override
  String get condRainShowers => 'Showers';

  @override
  String get condHeavyShowers => 'Heavy showers';

  @override
  String get condSnowShowers => 'Snow showers';

  @override
  String get condThunderstorm => 'Thunderstorm';

  @override
  String get condThunderstormHail => 'Thunderstorm with hail';

  @override
  String get condUnknown => 'Unknown';

  @override
  String updatedAt(String time) {
    return 'Updated $time';
  }

  @override
  String offlineBanner(String time) {
    return 'Offline · showing data from $time';
  }

  @override
  String get errorTitle => 'Couldn\'t load the weather';

  @override
  String get errorOffline =>
      'You\'re offline. Connect to the internet and try again.';

  @override
  String get errorTimeout => 'The weather service took too long to respond.';

  @override
  String get errorServer => 'The weather service is having problems right now.';

  @override
  String get errorUnknown => 'Something unexpected happened.';

  @override
  String get retry => 'Try again';

  @override
  String get locationDenied =>
      'Location permission was denied. You can still search for any city.';

  @override
  String get locationDisabled =>
      'Location services are turned off on this device.';

  @override
  String get locationTimeout =>
      'Couldn\'t get your position. Please try again outdoors or search instead.';

  @override
  String get cities => 'Cities';

  @override
  String get searchHint => 'Search for a city';

  @override
  String get searchPrompt => 'Type at least two letters';

  @override
  String searchEmpty(String query) {
    return 'No city found for “$query”';
  }

  @override
  String get useMyLocation => 'Use my location';

  @override
  String get locating => 'Finding you…';

  @override
  String get myLocation => 'My location';

  @override
  String get remove => 'Remove';

  @override
  String get settings => 'Settings';

  @override
  String get temperatureUnit => 'Temperature';

  @override
  String get windUnit => 'Wind speed';

  @override
  String get language => 'Language';

  @override
  String get dataSource => 'Weather data by Open-Meteo.com · CC BY 4.0';

  @override
  String get about =>
      'Atmos is a portfolio project built with Flutter and Bloc.';

  @override
  String localTime(String time) {
    return 'Local time $time';
  }
}
