import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mabrouk_app/features/auth/domain/auth_models.dart';

final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService.instance;
});

class LocalStorageService {
  final SharedPreferences _prefs;

  // 🏛️ Singleton Instance for project-wide access
  static LocalStorageService? _instance;
  static LocalStorageService get instance {
    if (_instance == null) {
      throw Exception("LocalStorageService must be initialized in main() before use.");
    }
    return _instance!;
  }

  // 🛠️ Private constructor + init method
  LocalStorageService._(this._prefs);

  static Future<void> init() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = LocalStorageService._(prefs);
    }
  }

  // --- Auth Token ---
  static const String _keyToken = 'auth_token';
  
  String? getToken() => _prefs.getString(_keyToken);
  
  Future<void> saveToken(String token) async {
    await _prefs.setString(_keyToken, token);
  }

  // --- User Role ---
  static const String _keyRole = 'user_role';
  
  String? getRole() => _prefs.getString(_keyRole);
  
  Future<void> saveRole(String role) async {
    await _prefs.setString(_keyRole, role);
  }

  // --- Full User Profile ---
  static const String _keyUser = 'auth_user_data';

  AuthUser? getUser() {
    final userJson = _prefs.getString(_keyUser);
    if (userJson == null) return null;
    try {
      return AuthUser.fromJson(jsonDecode(userJson));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(AuthUser user) async {
    await _prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  // --- Theme Mode (Placeholder) ---
  static const String _keyTheme = 'theme_mode';
  bool isDarkMode() => _prefs.getBool(_keyTheme) ?? false;
  Future<void> setDarkMode(bool value) async => await _prefs.setBool(_keyTheme, value);

  // --- Localization ---
  static const String _keyLocale = 'app_locale';
  String getLocale() => _prefs.getString(_keyLocale) ?? 'ar';
  Future<void> saveLocale(String langCode) async => await _prefs.setString(_keyLocale, langCode);

  // --- General Methods ---
  Future<void> clearAuthData() async {
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyRole);
    await _prefs.remove(_keyUser);
  }

  // --- Favorites (IDs list) ---
  static const String _keyFavorites = 'favorites_list';
  
  List<String> getFavorites() => _prefs.getStringList(_keyFavorites) ?? [];
  
  Future<void> saveFavorites(List<String> list) async {
    await _prefs.setStringList(_keyFavorites, list);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}

