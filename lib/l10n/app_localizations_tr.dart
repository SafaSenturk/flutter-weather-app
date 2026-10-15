// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Atmos';

  @override
  String feelsLike(String temp) {
    return 'Hissedilen $temp';
  }

  @override
  String highLow(String high, String low) {
    return 'En yüksek $high  ·  En düşük $low';
  }

  @override
  String get hourlyForecast => 'Saatlik tahmin';

  @override
  String get dailyForecast => '10 günlük tahmin';

  @override
  String get now => 'Şimdi';

  @override
  String get today => 'Bugün';

  @override
  String get wind => 'Rüzgâr';

  @override
  String get humidity => 'Nem';

  @override
  String get uvIndex => 'UV indeksi';

  @override
  String get pressure => 'Basınç';

  @override
  String get visibility => 'Görüş';

  @override
  String get sunrise => 'Gün doğumu';

  @override
  String get sunset => 'Gün batımı';

  @override
  String get airQuality => 'Hava kalitesi';

  @override
  String get precipitation => 'Yağış';

  @override
  String precipitationToday(String amount) {
    return 'Son bir saatte $amount mm';
  }

  @override
  String chanceOfRain(int percent) {
    return 'Bugün %$percent ihtimal';
  }

  @override
  String get uvLow => 'Düşük';

  @override
  String get uvModerate => 'Orta';

  @override
  String get uvHigh => 'Yüksek';

  @override
  String get uvVeryHigh => 'Çok yüksek';

  @override
  String get uvExtreme => 'Aşırı';

  @override
  String get aqiGood => 'İyi';

  @override
  String get aqiFair => 'Makul';

  @override
  String get aqiModerate => 'Orta';

  @override
  String get aqiPoor => 'Kötü';

  @override
  String get aqiVeryPoor => 'Çok kötü';

  @override
  String get aqiExtreme => 'Son derece kötü';

  @override
  String get compass => 'K,KD,D,GD,G,GB,B,KB';

  @override
  String windFrom(String direction) {
    return '$direction yönünden';
  }

  @override
  String get pressureHigh => 'Yüksek basınç, durgun hava';

  @override
  String get pressureNormal => 'Deniz seviyesi için normal';

  @override
  String get pressureLow => 'Alçak basınç, değişken hava';

  @override
  String get dewHumid => 'Nemli hava';

  @override
  String get dewComfortable => 'Konforlu';

  @override
  String get dewDry => 'Kuru hava';

  @override
  String get visibilityClear => 'Tamamen açık';

  @override
  String get visibilityHazy => 'Puslu';

  @override
  String get visibilityPoor => 'Görüş zayıf';

  @override
  String get condClear => 'Açık';

  @override
  String get condMainlyClear => 'Çoğunlukla açık';

  @override
  String get condPartlyCloudy => 'Parçalı bulutlu';

  @override
  String get condOvercast => 'Bulutlu';

  @override
  String get condFog => 'Sisli';

  @override
  String get condDrizzle => 'Çisenti';

  @override
  String get condFreezingDrizzle => 'Donan çisenti';

  @override
  String get condLightRain => 'Hafif yağmur';

  @override
  String get condRain => 'Yağmurlu';

  @override
  String get condHeavyRain => 'Şiddetli yağmur';

  @override
  String get condFreezingRain => 'Donan yağmur';

  @override
  String get condLightSnow => 'Hafif kar';

  @override
  String get condSnow => 'Karlı';

  @override
  String get condHeavySnow => 'Yoğun kar';

  @override
  String get condRainShowers => 'Sağanak';

  @override
  String get condHeavyShowers => 'Kuvvetli sağanak';

  @override
  String get condSnowShowers => 'Kar sağanağı';

  @override
  String get condThunderstorm => 'Gök gürültülü fırtına';

  @override
  String get condThunderstormHail => 'Dolulu fırtına';

  @override
  String get condUnknown => 'Bilinmiyor';

  @override
  String updatedAt(String time) {
    return '$time itibarıyla güncel';
  }

  @override
  String offlineBanner(String time) {
    return 'Çevrimdışı · $time verisi gösteriliyor';
  }

  @override
  String get errorTitle => 'Hava durumu yüklenemedi';

  @override
  String get errorOffline => 'İnternet bağlantın yok. Bağlanıp tekrar dene.';

  @override
  String get errorTimeout => 'Hava durumu servisi çok geç yanıt verdi.';

  @override
  String get errorServer => 'Hava durumu servisinde şu an bir sorun var.';

  @override
  String get errorUnknown => 'Beklenmeyen bir hata oluştu.';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get locationDenied =>
      'Konum izni verilmedi. Yine de istediğin şehri arayabilirsin.';

  @override
  String get locationDisabled => 'Bu cihazda konum servisleri kapalı.';

  @override
  String get locationTimeout =>
      'Konumun alınamadı. Açık alanda tekrar dene ya da şehir ara.';

  @override
  String get cities => 'Şehirler';

  @override
  String get searchHint => 'Şehir ara';

  @override
  String get searchPrompt => 'En az iki harf yaz';

  @override
  String searchEmpty(String query) {
    return '“$query” için şehir bulunamadı';
  }

  @override
  String get useMyLocation => 'Konumumu kullan';

  @override
  String get locating => 'Konum bulunuyor…';

  @override
  String get myLocation => 'Konumum';

  @override
  String get remove => 'Kaldır';

  @override
  String get settings => 'Ayarlar';

  @override
  String get temperatureUnit => 'Sıcaklık';

  @override
  String get windUnit => 'Rüzgâr hızı';

  @override
  String get language => 'Dil';

  @override
  String get dataSource => 'Hava durumu verisi: Open-Meteo.com · CC BY 4.0';

  @override
  String get about =>
      'Atmos, Flutter ve Bloc ile geliştirilmiş bir portföy projesidir.';

  @override
  String localTime(String time) {
    return 'Yerel saat $time';
  }
}
