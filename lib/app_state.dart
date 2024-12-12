import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/shift.dart';
import 'models/overtime_rule.dart';

class AppState extends ChangeNotifier {
  List<Shift> shifts = [];
  List<OvertimeRule> overtimeRules = [];
  List<DateTime> festiveDays = [];

  double _hourlyWage = 0;
  double _taxDeduction = 0;
  bool _startOnSunday = true;
  Locale _locale = const Locale('en', '');
  String _countryCode = 'US';
  double _baseHoursWeekday = 8.0;
  double _baseHoursSpecialDay = 8.0;
  bool _isDarkMode = false;

  String _userName = '';

  // Getters
  double get hourlyWage => _hourlyWage;
  double get taxDeduction => _taxDeduction;
  bool get startOnSunday => _startOnSunday;
  Locale get locale => _locale;
  String get countryCode => _countryCode;
  double get baseHoursWeekday => _baseHoursWeekday;
  double get baseHoursSpecialDay => _baseHoursSpecialDay;
  String get userName => _userName;
  bool get isDarkMode => _isDarkMode;

  // Setters
  set hourlyWage(double value) {
    _hourlyWage = value;
    notifyListeners();
    saveSettings();
  }

  set taxDeduction(double value) {
    _taxDeduction = value.clamp(0.0, 100.0);
    notifyListeners();
    saveSettings();
  }

  set startOnSunday(bool value) {
    _startOnSunday = value;
    notifyListeners();
    saveSettings();
  }

  void setLocale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners();
    saveSettings();
  }

  void setCountry(String newCountryCode) {
    _countryCode = newCountryCode;
    notifyListeners();
    saveSettings();
  }

  set baseHoursWeekday(double value) {
    _baseHoursWeekday = value;
    notifyListeners();
    saveSettings();
  }

  set baseHoursSpecialDay(double value) {
    _baseHoursSpecialDay = value;
    notifyListeners();
    saveSettings();
  }

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    saveSettings();
  }

  AppState() {
    loadSettings();
    loadShifts();
    loadOvertimeRules();
    loadFestiveDays();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _hourlyWage = prefs.getDouble('hourlyWage') ?? 0;
    _taxDeduction = prefs.getDouble('taxDeduction') ?? 0;
    _startOnSunday = prefs.getBool('startOnSunday') ?? true;
    _locale = Locale(prefs.getString('languageCode') ?? 'en', '');
    _countryCode = prefs.getString('countryCode') ?? 'US';
    _baseHoursWeekday = prefs.getDouble('baseHoursWeekday') ?? 8.0;
    _baseHoursSpecialDay = prefs.getDouble('baseHoursSpecialDay') ?? 8.0;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('hourlyWage', _hourlyWage);
    await prefs.setDouble('taxDeduction', _taxDeduction);
    await prefs.setBool('startOnSunday', _startOnSunday);
    await prefs.setString('languageCode', _locale.languageCode);
    await prefs.setString('countryCode', _countryCode);
    await prefs.setDouble('baseHoursWeekday', _baseHoursWeekday);
    await prefs.setDouble('baseHoursSpecialDay', _baseHoursSpecialDay);
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  Future<void> loadShifts() async {
    final prefs = await SharedPreferences.getInstance();
    final shiftsJson = prefs.getString('shifts');
    if (shiftsJson != null) {
      final shiftsData = json.decode(shiftsJson) as List;
      shifts = shiftsData.map((shiftData) => Shift.fromJson(shiftData)).toList();
      notifyListeners();
    }
  }

  Future<void> saveShifts() async {
    final prefs = await SharedPreferences.getInstance();
    final shiftsJson = json.encode(shifts.map((shift) => shift.toJson()).toList());
    await prefs.setString('shifts', shiftsJson);
  }

  Future<void> loadOvertimeRules() async {
    final prefs = await SharedPreferences.getInstance();
    final rulesJson = prefs.getString('overtimeRules');
    if (rulesJson != null) {
      final rulesData = json.decode(rulesJson) as List;
      overtimeRules = rulesData
          .map((ruleData) => OvertimeRule.fromJson(ruleData as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }

  Future<void> saveOvertimeRules() async {
    final prefs = await SharedPreferences.getInstance();
    final rulesJson = json.encode(overtimeRules.map((rule) => rule.toJson()).toList());
    await prefs.setString('overtimeRules', rulesJson);
  }

  Future<void> loadFestiveDays() async {
    final prefs = await SharedPreferences.getInstance();
    final festiveDaysJson = prefs.getString('festiveDays');
    if (festiveDaysJson != null) {
      final festiveDaysData = json.decode(festiveDaysJson) as List;
      festiveDays = festiveDaysData
          .map((dateString) => DateTime.parse(dateString as String))
          .toList();
      notifyListeners();
    }
  }

  Future<void> saveFestiveDays() async {
    final prefs = await SharedPreferences.getInstance();
    final festiveDaysJson =
        json.encode(festiveDays.map((date) => date.toIso8601String()).toList());
    await prefs.setString('festiveDays', festiveDaysJson);
  }

  void addOvertimeRule(OvertimeRule rule) {
    overtimeRules.add(rule);
    saveOvertimeRules();
    notifyListeners();
  }

  void updateOvertimeRule(int index, OvertimeRule updatedRule) {
    if (index >= 0 && index < overtimeRules.length) {
      overtimeRules[index] = updatedRule;
      saveOvertimeRules();
      notifyListeners();
    }
  }

  void deleteOvertimeRule(int index) {
    if (index >= 0 && index < overtimeRules.length) {
      overtimeRules.removeAt(index);
      saveOvertimeRules();
      notifyListeners();
    }
  }

  void addFestiveDay(DateTime date) {
    festiveDays.add(date);
    saveFestiveDays();
    notifyListeners();
  }

  void removeFestiveDay(DateTime date) {
    festiveDays.removeWhere((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
    saveFestiveDays();
    notifyListeners();
  }

  void addShift(Shift shift) {
    shifts.add(shift);
    saveShifts();
    notifyListeners();
  }

  void updateShift(int index, Shift updatedShift) {
    if (index >= 0 && index < shifts.length) {
      shifts[index] = updatedShift;
      saveShifts();
      notifyListeners();
    }
  }

  void deleteShift(int index) {
    if (index >= 0 && index < shifts.length) {
      shifts.removeAt(index);
      saveShifts();
      notifyListeners();
    }
  }

  Future<void> updateSettings({
    double? hourlyWage,
    double? taxDeduction,
    bool? startOnSunday,
    String? languageCode,
    String? countryCode,
    double? baseHoursWeekday,
    double? baseHoursSpecialDay,
  }) async {
    if (hourlyWage != null) _hourlyWage = hourlyWage;
    if (taxDeduction != null) _taxDeduction = taxDeduction.clamp(0.0, 100.0);
    if (startOnSunday != null) _startOnSunday = startOnSunday;
    if (languageCode != null) _locale = Locale(languageCode, '');
    if (countryCode != null) _countryCode = countryCode;
    if (baseHoursWeekday != null) _baseHoursWeekday = baseHoursWeekday;
    if (baseHoursSpecialDay != null) _baseHoursSpecialDay = baseHoursSpecialDay;

    notifyListeners();
    await saveSettings();
  }

  Future<void> updateBaseHours({
    required double weekday,
    required double specialDay,
  }) async {
    _baseHoursWeekday = weekday;
    _baseHoursSpecialDay = specialDay;
    notifyListeners();
    await saveSettings();
  }

  String getCurrencySymbol() {
    switch (_countryCode) {
      case 'US':
        return '\$';
      case 'GB':
        return '£';
      case 'EU':
        return '€';
      case 'JP':
        return '¥';
      case 'IL':
        return '₪';
      case 'RU':
        return '₽';
      default:
        return '\$';
    }
  }

  List<Shift> get upcomingShifts {
    final now = DateTime.now();
    return shifts.where((shift) => shift.date.isAfter(now)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<Shift> getShiftsBetweenDates(DateTime start, DateTime end) {
    return shifts.where((shift) => 
      shift.date.isAfter(start.subtract(const Duration(days: 1))) && 
      shift.date.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }
}