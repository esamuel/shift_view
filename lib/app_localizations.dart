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
      'settingsTitle': 'Settings',
      'hourlyWage': 'Hourly Wage',
      'taxDeduction': 'Tax Deduction (%)',
      'baseHoursWeekday': 'Base Hours (Weekday)',
      'baseHoursSpecialDay': 'Base Hours (Special Day)',
      'startWorkWeekOnSunday': 'Start work week on Sunday',
      'shiftManagerTitle': 'Shift Manager',
      'reportsTitle': 'Reports',
      'infoButtonTitle': 'Info',
      'overtimeRulesTitle': 'Overtime Rules',
      'addToHomeScreen': 'Add to Home Screen',
      'addToHomeScreenTitle': 'How to Add to Home Screen',
      'addToHomeScreeniOS':
          'For iOS: Tap the share button in Safari, then select "Add to Home Screen".',
      'addToHomeScreenAndroid':
          'For Android: Tap the menu button in Chrome, then select "Add to home screen".',
      'ok': 'OK',
      'addNewShift': 'Add New Shift',
      'selectDate': 'Select Date',
      'startTime': 'Start Time',
      'endTime': 'End Time',
      'addShift': 'Add Shift',
      'existingShifts': 'Existing Shifts',
      'currentMonth': 'Current Month',
      'allShifts': 'All Shifts',
      'weeklyView': 'Weekly View',
      'monthlyView': 'Monthly View',
      'language': 'Language',
      'country': 'Country',
      'manageOvertimeRules': 'Manage Overtime Rules',
      'saveSettings': 'Save Settings',
      'noShiftsThisMonth': 'No shifts found for the current month',
      'noShiftsYet': 'No shifts added yet',
      'countryUS': 'United States (USD)',
      'countryGB': 'United Kingdom (GBP)',
      'countryEU': 'European Union (EUR)',
      'countryIL': 'Israel (ILS)',
      'countryRU': 'Russia (RUB)',
    },
    // Add translations for other languages (he, es, de, ru, fr) here
  };

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get settingsTitle =>
      _localizedValues[locale.languageCode]!['settingsTitle']!;
  String get shiftManagerTitle =>
      _localizedValues[locale.languageCode]!['shiftManagerTitle']!;
  String get reportsTitle =>
      _localizedValues[locale.languageCode]!['reportsTitle']!;
  String get infoButtonTitle =>
      _localizedValues[locale.languageCode]!['infoButtonTitle']!;
  String get overtimeRulesTitle =>
      _localizedValues[locale.languageCode]!['overtimeRulesTitle']!;
  String get addToHomeScreen =>
      _localizedValues[locale.languageCode]!['addToHomeScreen']!;
  String get addToHomeScreenTitle =>
      _localizedValues[locale.languageCode]!['addToHomeScreenTitle']!;
  String get addToHomeScreeniOS =>
      _localizedValues[locale.languageCode]!['addToHomeScreeniOS']!;
  String get addToHomeScreenAndroid =>
      _localizedValues[locale.languageCode]!['addToHomeScreenAndroid']!;
  String get ok => _localizedValues[locale.languageCode]!['ok']!;
  String get addNewShift =>
      _localizedValues[locale.languageCode]!['addNewShift']!;
  String get selectDate =>
      _localizedValues[locale.languageCode]!['selectDate']!;
  String get startTime => _localizedValues[locale.languageCode]!['startTime']!;
  String get endTime => _localizedValues[locale.languageCode]!['endTime']!;
  String get addShift => _localizedValues[locale.languageCode]!['addShift']!;
  String get existingShifts =>
      _localizedValues[locale.languageCode]!['existingShifts']!;
  String get currentMonth =>
      _localizedValues[locale.languageCode]!['currentMonth']!;
  String get allShifts => _localizedValues[locale.languageCode]!['allShifts']!;
  String get weeklyView =>
      _localizedValues[locale.languageCode]!['weeklyView']!;
  String get monthlyView =>
      _localizedValues[locale.languageCode]!['monthlyView']!;
  String get baseHoursWeekday =>
      _localizedValues[locale.languageCode]!['baseHoursWeekday']!;
  String get baseHoursSpecialDay =>
      _localizedValues[locale.languageCode]!['baseHoursSpecialDay']!;
  String get startWorkWeekOnSunday =>
      _localizedValues[locale.languageCode]!['startWorkWeekOnSunday']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get country => _localizedValues[locale.languageCode]!['country']!;
  String get manageOvertimeRules =>
      _localizedValues[locale.languageCode]!['manageOvertimeRules']!;
  String get saveSettings =>
      _localizedValues[locale.languageCode]!['saveSettings']!;
  String get countryUS => _localizedValues[locale.languageCode]!['countryUS']!;
  String get countryGB => _localizedValues[locale.languageCode]!['countryGB']!;
  String get countryEU => _localizedValues[locale.languageCode]!['countryEU']!;
  String get countryIL => _localizedValues[locale.languageCode]!['countryIL']!;
  String get countryRU => _localizedValues[locale.languageCode]!['countryRU']!;
  String get hourlyWage =>
      _localizedValues[locale.languageCode]!['hourlyWage']!;
  String get taxDeduction =>
      _localizedValues[locale.languageCode]!['taxDeduction']!;
  String get noShiftsThisMonth =>
      _localizedValues[locale.languageCode]!['noShiftsThisMonth']!;
  String get noShiftsYet =>
      _localizedValues[locale.languageCode]!['noShiftsYet']!;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'he', 'es', 'de', 'ru', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
