/// Application constants
class AppConstants {
  AppConstants._();

  static const String appName = 'حوة';
  static const String appVersion = '1.0.0';

  // API — Set via environment or override here
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
  );

  // Quran
  static const String quranDataSource = 'Tanzil.net';
  static const String quranDataAttribution =
      'Quran text provided by Tanzil.net. '
      'This is a verbatim copy of the Tanzil Quran text. '
      'Visit tanzil.net for more information.';

  // Hadith
  static const String hadithDataSource = 'Sunnah.com';

  // Database
  static const String dbName = 'hawah.db';
  static const int dbVersion = 1;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Tasbih
  static const int defaultTasbihTarget = 33;
  static const List<int> tasbihTargetOptions = [33, 34, 100, 500, 1000];

  // Qibla — Kaaba coordinates
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  // Storage keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyFontSize = 'font_size';
  static const String keyLanguage = 'language';
  static const String keyLastSyncTime = 'last_sync_time';
  static const String keyDataImported = 'data_imported';
  static const String keyLastQuranSurah = 'last_quran_surah';
  static const String keyLastQuranAyah = 'last_quran_ayah';
  static const String keyLastQuranScroll = 'last_quran_scroll';
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserData = 'user_data';
}
