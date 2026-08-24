import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/app_database.dart';
import '../network/api_client.dart';
import '../storage/secure_storage.dart';
import '../constants/app_constants.dart';

// ─── Core Services ──────────────────────────────────────────

/// Single database instance for the entire app.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Secure storage for tokens and sensitive data.
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// API client with auto-auth.
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage);
});

/// SharedPreferences for non-sensitive settings.
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

// ─── Connectivity ───────────────────────────────────────────

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

final isOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.when(
    data: (results) => !results.contains(ConnectivityResult.none),
    loading: () => true, // Assume online while checking
    error: (_, __) => false,
  );
});

// ─── Theme ──────────────────────────────────────────────────

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(AppConstants.keyThemeMode);
    if (mode == 'light') state = ThemeMode.light;
    else if (mode == 'dark') state = ThemeMode.dark;
    else state = ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    switch (mode) {
      case ThemeMode.light:
        await prefs.setString(AppConstants.keyThemeMode, 'light');
      case ThemeMode.dark:
        await prefs.setString(AppConstants.keyThemeMode, 'dark');
      case ThemeMode.system:
        await prefs.remove(AppConstants.keyThemeMode);
    }
  }
}

// ─── Font Size ──────────────────────────────────────────────

final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>((ref) {
  return FontSizeNotifier();
});

class FontSizeNotifier extends StateNotifier<double> {
  FontSizeNotifier() : super(1.0) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble(AppConstants.keyFontSize) ?? 1.0;
  }

  Future<void> setFontSize(double scale) async {
    state = scale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.keyFontSize, scale);
  }
}

// ─── Data Import State ──────────────────────────────────────

enum DataImportStatus { notStarted, importing, completed, error }

final dataImportStatusProvider = StateProvider<DataImportStatus>((ref) {
  return DataImportStatus.notStarted;
});

final dataImportProgressProvider = StateProvider<String>((ref) => '');
