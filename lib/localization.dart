import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'appTitle': 'Shift View',
      'welcomeMessage': 'Welcome to Shift View',
      'settingsTitle': 'Settings',
      'hourlyWage': 'Hourly Wage',
      'taxDeduction': 'Tax Deduction (%)',
      'workWeekStart': 'Work Week Start Day',
      'language': 'Language',
      'save': 'Save',
      'infoTitle': 'Information',
      // Add other strings here
    },
    'he': {
      'appTitle': 'תצוגת משמרות',
      'welcomeMessage': 'ברוכים הבאים לתצוגת משמרות',
      'settingsTitle': 'הגדרות',
      'hourlyWage': 'שכר שעתי',
      'taxDeduction': 'ניכוי מס (%)',
      'workWeekStart': 'יום תחילת שבוע העבודה',
      'language': 'שפה',
      'save': 'שמור',
      'infoTitle': 'מידע',
      // Add other strings here
    },
    // Add other languages here
  };

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get welcomeMessage =>
      _localizedValues[locale.languageCode]!['welcomeMessage']!;
  String get settingsTitle =>
      _localizedValues[locale.languageCode]!['settingsTitle']!;
  String get hourlyWage =>
      _localizedValues[locale.languageCode]!['hourlyWage']!;
  String get taxDeduction =>
      _localizedValues[locale.languageCode]!['taxDeduction']!;
  String get workWeekStart =>
      _localizedValues[locale.languageCode]!['workWeekStart']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get infoTitle => _localizedValues[locale.languageCode]!['infoTitle']!;

  // Add other getters for your strings here
}

// Add this class at the end of the file
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'he', 'es', 'de', 'ru', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
