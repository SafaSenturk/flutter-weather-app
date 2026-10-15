import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/api/weather_api.dart';
import 'data/repositories/city_repository.dart';
import 'data/repositories/weather_repository.dart';
import 'features/cities/cubit/cities_cubit.dart';
import 'features/settings/settings_cubit.dart';
import 'features/weather/view/home_page.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
  ));
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final prefs = await SharedPreferences.getInstance();
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));
  final api = WeatherApi(dio);
  final weather = WeatherRepository(api, prefs);
  final cities = CityRepository(api, prefs);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: weather),
        RepositoryProvider.value(value: cities),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SettingsCubit(prefs)),
          BlocProvider(create: (_) => CitiesCubit(cities, weather)),
        ],
        child: const AtmosApp(),
      ),
    ),
  );
}

class AtmosApp extends StatelessWidget {
  const AtmosApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.select((SettingsCubit c) => c.state.locale);
    return MaterialApp(
      title: 'Atmos',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Manrope',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4FA8F0), brightness: Brightness.dark),
        snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        }),
      ),
      home: const HomePage(),
    );
  }
}
