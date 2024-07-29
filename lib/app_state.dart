import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppState extends ChangeNotifier {
  String userName = '';
  List<Shift> shifts = [];

  double hourlyWage = 0;
  double taxDeduction = 0;
  bool startOnSunday = true;
  Locale _locale = Locale('en', '');
  String _countryCode = 'US'; // Default to US
  List<OvertimeRule> overtimeRules = [];
  List<DateTime> festiveDays = [];

  double baseHoursWeekday = 8.0;
  double baseHoursSpecialDay = 8.0;

  Locale get locale => _locale;
  String get countryCode => _countryCode;

  AppState() {
    loadSettings();
    loadShifts();
    loadOvertimeRules();
    loadFestiveDays();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    hourlyWage = prefs.getDouble('hourlyWage') ?? 0;
    taxDeduction = prefs.getDouble('taxDeduction') ?? 0;
    startOnSunday = prefs.getBool('startOnSunday') ?? true;
    _locale = Locale(prefs.getString('languageCode') ?? 'en', '');
    _countryCode = prefs.getString('countryCode') ?? 'US';
    baseHoursWeekday = prefs.getDouble('baseHoursWeekday') ?? 8.0;
    baseHoursSpecialDay = prefs.getDouble('baseHoursSpecialDay') ?? 8.0;
    notifyListeners();
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('hourlyWage', hourlyWage);
    await prefs.setDouble('taxDeduction', taxDeduction);
    await prefs.setBool('startOnSunday', startOnSunday);
    await prefs.setString('languageCode', _locale.languageCode);
    await prefs.setString('countryCode', _countryCode);
    await prefs.setDouble('baseHoursWeekday', baseHoursWeekday);
    await prefs.setDouble('baseHoursSpecialDay', baseHoursSpecialDay);
  }

  Future<void> loadShifts() async {
    final prefs = await SharedPreferences.getInstance();
    final shiftsJson = prefs.getString('shifts');
    if (shiftsJson != null) {
      final shiftsData = json.decode(shiftsJson) as List;
      shifts =
          shiftsData.map((shiftData) => Shift.fromJson(shiftData)).toList();
      notifyListeners();
    }
  }

  Future<void> saveShifts() async {
    final prefs = await SharedPreferences.getInstance();
    final shiftsJson =
        json.encode(shifts.map((shift) => shift.toJson()).toList());
    await prefs.setString('shifts', shiftsJson);
  }

  Future<void> loadOvertimeRules() async {
    final prefs = await SharedPreferences.getInstance();
    final rulesJson = prefs.getString('overtimeRules');
    if (rulesJson != null) {
      final rulesData = json.decode(rulesJson) as List;
      overtimeRules = rulesData
          .map((ruleData) =>
              OvertimeRule.fromJson(ruleData as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }

  Future<void> saveOvertimeRules() async {
    final prefs = await SharedPreferences.getInstance();
    final rulesJson =
        json.encode(overtimeRules.map((rule) => rule.toJson()).toList());
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

  void setUserName(String name) {
    userName = name;
    notifyListeners();
  }

  void addShift(Shift shift) {
    shifts.add(shift);
    saveShifts();
    notifyListeners();
  }

  void updateShift(int index, Shift updatedShift) {
    shifts[index] = updatedShift;
    saveShifts();
    notifyListeners();
  }

  void deleteShift(int index) {
    shifts.removeAt(index);
    saveShifts();
    notifyListeners();
  }

  void addOvertimeRule(OvertimeRule rule) {
    overtimeRules.add(rule);
    saveOvertimeRules();
    notifyListeners();
  }

  void updateOvertimeRule(int index, OvertimeRule updatedRule) {
    overtimeRules[index] = updatedRule;
    saveOvertimeRules();
    notifyListeners();
  }

  void deleteOvertimeRule(int index) {
    overtimeRules.removeAt(index);
    saveOvertimeRules();
    notifyListeners();
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

  Future<void> setLocale(Locale newLocale) async {
    if (_locale != newLocale) {
      _locale = newLocale;
      await saveSettings();
      notifyListeners();
    }
  }

  void updateSettings({
    required double hourlyWage,
    required double taxDeduction,
    required bool startOnSunday,
  }) {
    this.hourlyWage = hourlyWage;
    this.taxDeduction = taxDeduction;
    this.startOnSunday = startOnSunday;
    saveSettings();
    notifyListeners();
  }

  void updateBaseHours({required double weekday, required double specialDay}) {
    baseHoursWeekday = weekday;
    baseHoursSpecialDay = specialDay;
    saveSettings();
    notifyListeners();
  }

  void setCountry(String countryCode) {
    if (_countryCode != countryCode) {
      _countryCode = countryCode;
      saveSettings();
      notifyListeners();
    }
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
        return '\$'; // Default to USD if unknown
    }
  }
}

class Shift {
  final String id;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final double totalHours;
  final double grossWage;
  final double netWage;
  final Map<String, double> wagePercentages;

  Shift({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.totalHours,
    required this.grossWage,
    required this.netWage,
    required this.wagePercentages,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
      'totalHours': totalHours,
      'grossWage': grossWage,
      'netWage': netWage,
      'wagePercentages': wagePercentages,
    };
  }

  factory Shift.fromJson(Map<String, dynamic> json) {
    final startTimeParts = json['startTime'].split(':');
    final endTimeParts = json['endTime'].split(':');
    return Shift(
      id: json['id'],
      date: DateTime.parse(json['date']),
      startTime: TimeOfDay(
          hour: int.parse(startTimeParts[0]),
          minute: int.parse(startTimeParts[1])),
      endTime: TimeOfDay(
          hour: int.parse(endTimeParts[0]), minute: int.parse(endTimeParts[1])),
      totalHours: json['totalHours'],
      grossWage: json['grossWage'],
      netWage: json['netWage'],
      wagePercentages: Map<String, double>.from(json['wagePercentages']),
    );
  }
}

class OvertimeRule {
  final String id;
  final double hoursThreshold;
  final double rate;
  final bool isForSpecialDays;

  OvertimeRule({
    required this.id,
    required this.hoursThreshold,
    required this.rate,
    required this.isForSpecialDays,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hoursThreshold': hoursThreshold,
      'rate': rate,
      'isForSpecialDays': isForSpecialDays,
    };
  }

  factory OvertimeRule.fromJson(Map<String, dynamic> json) {
    return OvertimeRule(
      id: json['id'],
      hoursThreshold: json['hoursThreshold'],
      rate: json['rate'],
      isForSpecialDays: json['isForSpecialDays'],
    );
  }
}
