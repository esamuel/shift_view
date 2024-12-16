import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';

class AppState extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isAuthenticated = false;
  Locale _locale = const Locale('en');
  final _prefs = SharedPreferences.getInstance();

  AppState() {
    _loadPreferences();
    _setupAuthListener();
  }

  bool get isDarkMode => _isDarkMode;
  bool get isAuthenticated => _isAuthenticated;
  Locale get locale => _locale;

  void _setupAuthListener() {
    FirebaseService.auth.authStateChanges().listen((user) {
      _isAuthenticated = user != null;
      notifyListeners();
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await _prefs;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    final languageCode = prefs.getString('languageCode') ?? 'en';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  void toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await _prefs;
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  void setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    _locale = newLocale;
    final prefs = await _prefs;
    await prefs.setString('languageCode', newLocale.languageCode);
    notifyListeners();
  }
} 