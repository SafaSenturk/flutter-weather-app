import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Atmos'**
  String get appTitle;

  /// No description provided for @feelsLike.
  ///
  /// In en, this message translates to:
  /// **'Feels like {temp}'**
  String feelsLike(String temp);

  /// No description provided for @highLow.
  ///
  /// In en, this message translates to:
  /// **'H {high}  ·  L {low}'**
  String highLow(String high, String low);

  /// No description provided for @hourlyForecast.
  ///
  /// In en, this message translates to:
  /// **'Hourly forecast'**
  String get hourlyForecast;

  /// No description provided for @dailyForecast.
  ///
  /// In en, this message translates to:
  /// **'10-day forecast'**
  String get dailyForecast;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @wind.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get wind;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @uvIndex.
  ///
  /// In en, this message translates to:
  /// **'UV index'**
  String get uvIndex;

  /// No description provided for @pressure.
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get pressure;

  /// No description provided for @visibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get visibility;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @sunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get sunset;

  /// No description provided for @airQuality.
  ///
  /// In en, this message translates to:
  /// **'Air quality'**
  String get airQuality;

  /// No description provided for @precipitation.
  ///
  /// In en, this message translates to:
  /// **'Precipitation'**
  String get precipitation;

  /// No description provided for @precipitationToday.
  ///
  /// In en, this message translates to:
  /// **'{amount} mm in the last hour'**
  String precipitationToday(String amount);

  /// No description provided for @chanceOfRain.
  ///
  /// In en, this message translates to:
  /// **'{percent}% chance today'**
  String chanceOfRain(int percent);

  /// No description provided for @uvLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get uvLow;

  /// No description provided for @uvModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get uvModerate;

  /// No description provided for @uvHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get uvHigh;

  /// No description provided for @uvVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very high'**
  String get uvVeryHigh;

  /// No description provided for @uvExtreme.
  ///
  /// In en, this message translates to:
  /// **'Extreme'**
  String get uvExtreme;

  /// No description provided for @aqiGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get aqiGood;

  /// No description provided for @aqiFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get aqiFair;

  /// No description provided for @aqiModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get aqiModerate;

  /// No description provided for @aqiPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get aqiPoor;

  /// No description provided for @aqiVeryPoor.
  ///
  /// In en, this message translates to:
  /// **'Very poor'**
  String get aqiVeryPoor;

  /// No description provided for @aqiExtreme.
  ///
  /// In en, this message translates to:
  /// **'Extremely poor'**
  String get aqiExtreme;

  /// No description provided for @compass.
  ///
  /// In en, this message translates to:
  /// **'N,NE,E,SE,S,SW,W,NW'**
  String get compass;

  /// No description provided for @windFrom.
  ///
  /// In en, this message translates to:
  /// **'from {direction}'**
  String windFrom(String direction);

  /// No description provided for @pressureHigh.
  ///
  /// In en, this message translates to:
  /// **'High pressure, settled weather'**
  String get pressureHigh;

  /// No description provided for @pressureNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal for sea level'**
  String get pressureNormal;

  /// No description provided for @pressureLow.
  ///
  /// In en, this message translates to:
  /// **'Low pressure, unsettled'**
  String get pressureLow;

  /// No description provided for @dewHumid.
  ///
  /// In en, this message translates to:
  /// **'Humid air'**
  String get dewHumid;

  /// No description provided for @dewComfortable.
  ///
  /// In en, this message translates to:
  /// **'Comfortable'**
  String get dewComfortable;

  /// No description provided for @dewDry.
  ///
  /// In en, this message translates to:
  /// **'Dry air'**
  String get dewDry;

  /// No description provided for @visibilityClear.
  ///
  /// In en, this message translates to:
  /// **'Perfectly clear'**
  String get visibilityClear;

  /// No description provided for @visibilityHazy.
  ///
  /// In en, this message translates to:
  /// **'Hazy'**
  String get visibilityHazy;

  /// No description provided for @visibilityPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor visibility'**
  String get visibilityPoor;

  /// No description provided for @condClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get condClear;

  /// No description provided for @condMainlyClear.
  ///
  /// In en, this message translates to:
  /// **'Mostly clear'**
  String get condMainlyClear;

  /// No description provided for @condPartlyCloudy.
  ///
  /// In en, this message translates to:
  /// **'Partly cloudy'**
  String get condPartlyCloudy;

  /// No description provided for @condOvercast.
  ///
  /// In en, this message translates to:
  /// **'Cloudy'**
  String get condOvercast;

  /// No description provided for @condFog.
  ///
  /// In en, this message translates to:
  /// **'Fog'**
  String get condFog;

  /// No description provided for @condDrizzle.
  ///
  /// In en, this message translates to:
  /// **'Drizzle'**
  String get condDrizzle;

  /// No description provided for @condFreezingDrizzle.
  ///
  /// In en, this message translates to:
  /// **'Freezing drizzle'**
  String get condFreezingDrizzle;

  /// No description provided for @condLightRain.
  ///
  /// In en, this message translates to:
  /// **'Light rain'**
  String get condLightRain;

  /// No description provided for @condRain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get condRain;

  /// No description provided for @condHeavyRain.
  ///
  /// In en, this message translates to:
  /// **'Heavy rain'**
  String get condHeavyRain;

  /// No description provided for @condFreezingRain.
  ///
  /// In en, this message translates to:
  /// **'Freezing rain'**
  String get condFreezingRain;

  /// No description provided for @condLightSnow.
  ///
  /// In en, this message translates to:
  /// **'Light snow'**
  String get condLightSnow;

  /// No description provided for @condSnow.
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get condSnow;

  /// No description provided for @condHeavySnow.
  ///
  /// In en, this message translates to:
  /// **'Heavy snow'**
  String get condHeavySnow;

  /// No description provided for @condRainShowers.
  ///
  /// In en, this message translates to:
  /// **'Showers'**
  String get condRainShowers;

  /// No description provided for @condHeavyShowers.
  ///
  /// In en, this message translates to:
  /// **'Heavy showers'**
  String get condHeavyShowers;

  /// No description provided for @condSnowShowers.
  ///
  /// In en, this message translates to:
  /// **'Snow showers'**
  String get condSnowShowers;

  /// No description provided for @condThunderstorm.
  ///
  /// In en, this message translates to:
  /// **'Thunderstorm'**
  String get condThunderstorm;

  /// No description provided for @condThunderstormHail.
  ///
  /// In en, this message translates to:
  /// **'Thunderstorm with hail'**
  String get condThunderstormHail;

  /// No description provided for @condUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get condUnknown;

  /// No description provided for @updatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String updatedAt(String time);

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline · showing data from {time}'**
  String offlineBanner(String time);

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the weather'**
  String get errorTitle;

  /// No description provided for @errorOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Connect to the internet and try again.'**
  String get errorOffline;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The weather service took too long to respond.'**
  String get errorTimeout;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'The weather service is having problems right now.'**
  String get errorServer;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something unexpected happened.'**
  String get errorUnknown;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied. You can still search for any city.'**
  String get locationDenied;

  /// No description provided for @locationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are turned off on this device.'**
  String get locationDisabled;

  /// No description provided for @locationTimeout.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get your position. Please try again outdoors or search instead.'**
  String get locationTimeout;

  /// No description provided for @cities.
  ///
  /// In en, this message translates to:
  /// **'Cities'**
  String get cities;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a city'**
  String get searchHint;

  /// No description provided for @searchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type at least two letters'**
  String get searchPrompt;

  /// No description provided for @searchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No city found for “{query}”'**
  String searchEmpty(String query);

  /// No description provided for @useMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get useMyLocation;

  /// No description provided for @locating.
  ///
  /// In en, this message translates to:
  /// **'Finding you…'**
  String get locating;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get myLocation;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @temperatureUnit.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperatureUnit;

  /// No description provided for @windUnit.
  ///
  /// In en, this message translates to:
  /// **'Wind speed'**
  String get windUnit;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @dataSource.
  ///
  /// In en, this message translates to:
  /// **'Weather data by Open-Meteo.com · CC BY 4.0'**
  String get dataSource;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'Atmos is a portfolio project built with Flutter and Bloc.'**
  String get about;

  /// No description provided for @localTime.
  ///
  /// In en, this message translates to:
  /// **'Local time {time}'**
  String localTime(String time);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
