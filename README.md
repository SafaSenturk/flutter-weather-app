<div align="center">

<img src="docs/banner.png" alt="Atmos – Flutter weather app" width="100%" />

# Atmos · Flutter Weather App

A polished weather app built on a public REST API: live conditions, hourly and 10-day forecasts, air quality, city search, GPS location and an offline cache — with an animated sky that changes with the weather and the time of day.

[![Flutter](https://img.shields.io/badge/Flutter-3.44-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![State](https://img.shields.io/badge/state-flutter__bloc%209-13B9FD)](https://bloclibrary.dev)
[![CI](https://github.com/SafaSenturk/flutter-weather-app/actions/workflows/ci.yml/badge.svg)](https://github.com/SafaSenturk/flutter-weather-app/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)

**[⬇️ Download the APK](https://github.com/SafaSenturk/flutter-weather-app/releases/latest)** · [🇹🇷 Türkçe açıklama](#-türkçe)

</div>

---

## Demo

<p align="center">
  <img src="docs/demo.gif" alt="Swiping between cities, scrolling the forecast and opening the city list" width="300" />
</p>

## Features

**Forecast**
- Current conditions: temperature, "feels like", today's high/low and the city's **local time**
- **Hourly forecast** for the next 24 hours drawn as a smooth temperature curve, with rain chances
- **10-day forecast** with temperature range bars coloured from cold to warm
- Detail tiles: **wind compass**, **sunrise/sunset arc**, UV index, humidity, **air quality (European AQI, PM2.5, PM10)**, precipitation, pressure and visibility

**Cities**
- Swipe between saved cities like the system weather apps
- **City search** with debounce (results in Turkish or English), flags and regions
- **Use my location** (GPS + reverse geocoding) with proper permission handling
- Reorder by drag and drop, swipe to remove

**Design**
- Full-screen **animated sky** for every condition, day and night: sun rays, stars, drifting clouds, rain, snow, fog and lightning — all drawn with `CustomPainter`
- **Hand-drawn weather icons** (no icon pack), frosted-glass cards

**Reliability**
- **Offline first:** the last forecast of every city is saved on the device. Without a connection the app shows it with a clear "offline" banner instead of an empty screen
- Saved data appears instantly, then refreshes in the background (*stale-while-revalidate*)
- Every state has its own screen: loading placeholders, empty search, offline, timeout, server error, location denied — each with a way to recover
- **Units:** °C / °F and km/h, m/s, mph — switched instantly, no refetch
- **Turkish and English**

## Screenshots

| Clear morning | Rain | Night | Afternoon |
|:---:|:---:|:---:|:---:|
| <img src="docs/screenshots/01_tokyo.jpg" width="200"/> | <img src="docs/screenshots/02_sydney_rain.jpg" width="200"/> | <img src="docs/screenshots/03_istanbul_night.jpg" width="200"/> | <img src="docs/screenshots/04_new_york.jpg" width="200"/> |
| **Details** | **10-day forecast** | **Cities** | **Search** |
| <img src="docs/screenshots/05_details.jpg" width="200"/> | <img src="docs/screenshots/06_daily.jpg" width="200"/> | <img src="docs/screenshots/07_cities.jpg" width="200"/> | <img src="docs/screenshots/08_search.jpg" width="200"/> |
| **Settings** | **Offline (cached data)** | **Error state** | **Turkish + °F** |
| <img src="docs/screenshots/09_settings.jpg" width="200"/> | <img src="docs/screenshots/10_offline_tr.jpg" width="200"/> | <img src="docs/screenshots/11_error.jpg" width="200"/> | <img src="docs/screenshots/12_fahrenheit_tr.jpg" width="200"/> |

## Tech stack

| Area | Choice |
|---|---|
| UI | Flutter 3.44, Material 3, `CustomPainter` animations, `BackdropFilter` glass, bundled Manrope font |
| State management | **flutter_bloc 9** — `Bloc` with event transformers (`restartable`, `droppable`, debounce) and `Cubit` |
| Networking | **Dio**, one `WeatherFailure` type mapped to user-facing messages |
| APIs | [Open-Meteo](https://open-meteo.com) forecast, air-quality and geocoding (no API key) · BigDataCloud reverse geocoding |
| Location | `geolocator` |
| Persistence | `shared_preferences` (cities, settings, cached forecasts) |
| Localization | ARB files + `gen-l10n`, Turkish & English |
| Testing / CI | `bloc_test`, `mocktail`, real API fixtures, GitHub Actions |

## Architecture

```
lib/
├── main.dart                     # Dependency setup: Dio → API → repositories → blocs
├── core/
│   ├── format.dart               # Unit conversion + localized labels
│   └── widgets/                  # SkyBackground, WeatherIcon, GlassCard
├── data/
│   ├── api/weather_api.dart      # Open-Meteo + reverse geocoding, error mapping
│   ├── models/                   # Forecast, City, WeatherCondition (WMO codes)
│   └── repositories/             # WeatherRepository (memory + disk cache), CityRepository (search, GPS)
├── features/
│   ├── weather/                  # WeatherBloc (one per city page) + home carousel + cards
│   ├── cities/                   # CitiesCubit (saved list), CitySearchBloc (debounced search)
│   └── settings/                 # SettingsCubit (units, language)
└── l10n/                         # app_en.arb, app_tr.arb
```

**Data flow:** UI → `WeatherBloc` → `WeatherRepository` → `WeatherApi`.
The repository answers from memory if the data is less than 10 minutes old, otherwise downloads it and saves the raw response. If the download fails it returns the saved copy marked as *stale*, so the bloc can show the offline banner; only when nothing was ever saved does the screen switch to the error state.

Time zones are handled explicitly: Open-Meteo returns local wall-clock times, which are compared with "now in that city" (`UTC + utc_offset`), so the hourly list is correct whatever time zone the phone is in.

## Run it yourself

```bash
git clone https://github.com/SafaSenturk/flutter-weather-app.git
cd flutter-weather-app
flutter pub get
flutter run
```

```bash
flutter test      # 20 tests: blocs, repository, parsing (real API fixtures), units
flutter analyze   # strict lints, no issues
```

No API key needed.

---

## 🇹🇷 Türkçe

**Atmos**, herkese açık bir hava durumu API'si üzerine kurulmuş, tasarımıyla öne çıkan bir Flutter uygulamasıdır.

**Neler var?**
- Anlık hava: sıcaklık, hissedilen, günün en yüksek/en düşük değeri, şehrin yerel saati
- Eğri grafikli **24 saatlik tahmin** ve renkli aralık çubuklu **10 günlük tahmin**
- Rüzgâr pusulası, gün doğumu/batımı yayı, UV, nem, **hava kalitesi**, yağış, basınç, görüş
- Kayıtlı şehirler arasında kaydırarak geçiş, **şehir arama**, **konumumu kullan** (GPS), sürükleyerek sıralama
- Hava durumuna ve gece/gündüze göre değişen **hareketli gökyüzü** (güneş, yıldız, bulut, yağmur, kar, sis, şimşek)
- **Çevrimdışı çalışma:** her şehrin son verisi telefonda saklanır; internet yokken boş ekran yerine son veri "Çevrimdışı" uyarısıyla gösterilir
- Yükleniyor, boş arama, internet yok, zaman aşımı, sunucu hatası ve konum izni reddi için ayrı ekranlar
- °C / °F, km/s · m/s · mph birimleri; **Türkçe / İngilizce**

**Teknik:** Flutter 3.44 · flutter_bloc · Dio · Open-Meteo API · geolocator · SharedPreferences · 20 test · GitHub Actions

**Denemek için:** [Releases](https://github.com/SafaSenturk/flutter-weather-app/releases/latest) sayfasından APK'yı indirip Android telefonuna kurabilirsin.

API entegrasyonlu bir uygulamaya mı ihtiyacın var (hava durumu, döviz, kendi REST servisin…)? **[safasenturk.github.io](https://safasenturk.github.io)**

---

<div align="center">

Built by **[Safa Şentürk](https://github.com/SafaSenturk)** · Flutter Mobile Developer · [Portfolio](https://safasenturk.github.io)

<sub>Weather data by <a href="https://open-meteo.com">Open-Meteo.com</a> (CC BY 4.0).</sub>

</div>
