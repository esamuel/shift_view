import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
  bool _skipWelcomeScreen = false;

  static const String _isDarkModeKey = 'isDarkMode';
  bool _isDarkMode = false;
  late SharedPreferences _prefs;

  // Getters
  double get hourlyWage => _hourlyWage;
  double get taxDeduction => _taxDeduction;
  bool get startOnSunday => _startOnSunday;
  Locale get locale => _locale;
  String get countryCode => _countryCode;
  double get baseHoursWeekday => _baseHoursWeekday;
  double get baseHoursSpecialDay => _baseHoursSpecialDay;
  bool get skipWelcomeScreen => _skipWelcomeScreen;
  bool get isDarkMode => _isDarkMode;

  // Add new getters for total hours and earnings
  double get totalHours {
    return shifts.fold<double>(
      0,
      (sum, shift) => sum + shift.totalHours,
    );
  }

  double get totalEarnings {
    return shifts.fold<double>(
      0,
      (sum, shift) => sum + shift.grossWage,
    );
  }

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
    if (['US', 'GB', 'EU', 'IL', 'RU'].contains(newCountryCode)) {
      _countryCode = newCountryCode;
      notifyListeners();
      saveSettings();
    }
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

  AppState() {
    _loadPreferences();
    loadSettings();
    loadShifts();
    loadOvertimeRules();
    loadFestiveDays();
  }

  get userName => null;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _hourlyWage = prefs.getDouble('hourlyWage') ?? 0;
    _taxDeduction = prefs.getDouble('taxDeduction') ?? 0;
    _startOnSunday = prefs.getBool('startOnSunday') ?? true;
    _locale = Locale(prefs.getString('languageCode') ?? 'en', '');
    
    String? storedCountry = prefs.getString('countryCode');
    if (storedCountry != null && 
        ['US', 'GB', 'EU', 'IL', 'RU'].contains(storedCountry)) {
      _countryCode = storedCountry;
    } else {
      _countryCode = 'US';
      await prefs.setString('countryCode', 'US');
    }
    
    _baseHoursWeekday = prefs.getDouble('baseHoursWeekday') ?? 8.0;
    _baseHoursSpecialDay = prefs.getDouble('baseHoursSpecialDay') ?? 8.0;
    _skipWelcomeScreen = prefs.getBool('skipWelcomeScreen') ?? false;
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
    await prefs.setBool('skipWelcomeScreen', _skipWelcomeScreen);
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

  Future<void> updateBaseHours(
      {required double weekday, required double specialDay}) async {
    baseHoursWeekday = weekday;
    baseHoursSpecialDay = specialDay;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('baseHoursWeekday', weekday);
    await prefs.setDouble('baseHoursSpecialDay', specialDay);
    notifyListeners();
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

  void updateSettings({
    double? hourlyWage,
    double? taxDeduction,
    bool? startOnSunday,
    String? languageCode,
    String? countryCode,
    double? baseHoursWeekday,
    double? baseHoursSpecialDay,
    bool? skipWelcomeScreen,
  }) {
    if (hourlyWage != null) _hourlyWage = hourlyWage;
    if (taxDeduction != null) _taxDeduction = taxDeduction.clamp(0.0, 100.0);
    if (startOnSunday != null) {
      _startOnSunday = startOnSunday;
      notifyListeners();
    }
    if (languageCode != null) _locale = Locale(languageCode, '');
    if (countryCode != null) _countryCode = countryCode;
    if (baseHoursWeekday != null) _baseHoursWeekday = baseHoursWeekday;
    if (baseHoursSpecialDay != null) _baseHoursSpecialDay = baseHoursSpecialDay;
    if (skipWelcomeScreen != null) _skipWelcomeScreen = skipWelcomeScreen;

    notifyListeners();
    saveSettings();
  }
  // Add methods for overtime rules and festive days management here

  String getCurrencySymbol() {
    switch (_countryCode) {
      case 'US':
        return '\$';
      case 'GB':
        return '£';
      case 'EU':
        return '€';
      case 'IL':
        return '₪';
      case 'RU':
        return '₽';
      default:
        return '\$';
    }
  }

  // Add a getter for upcoming shifts
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

  bool isWeekend(DateTime date) {
    if (_startOnSunday) {
      // If week starts on Sunday, Friday and Saturday are weekend
      return date.weekday == DateTime.friday || date.weekday == DateTime.saturday;
    } else {
      // If week starts on Monday, Saturday and Sunday are weekend
      return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    }
  }

  Future<void> restoreFromBackup(Map<String, dynamic> data) async {
    // Clear existing data
    shifts.clear();
    overtimeRules.clear();
    festiveDays.clear();

    // Restore data
    shifts = (data['shifts'] as List)
        .map((s) => Shift.fromJson(s))
        .toList();
    
    overtimeRules = (data['overtimeRules'] as List)
        .map((r) => OvertimeRule.fromJson(r))
        .toList();
    
    festiveDays = (data['festiveDays'] as List)
        .map((d) => DateTime.parse(d))
        .toList();

    final settings = data['settings'];
    updateSettings(
      hourlyWage: settings['hourlyWage'],
      taxDeduction: settings['taxDeduction'],
      startOnSunday: settings['startOnSunday'],
      languageCode: settings['locale'],
      countryCode: settings['countryCode'],
      baseHoursWeekday: settings['baseHoursWeekday'],
      baseHoursSpecialDay: settings['baseHoursSpecialDay'],
    );

    await saveSettings();
    await saveShifts();
    await saveOvertimeRules();
    await saveFestiveDays();

    notifyListeners();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool(_isDarkModeKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool(_isDarkModeKey, _isDarkMode);
    notifyListeners();
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
  String? note;
  bool isSpecialDay;

  Shift({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.totalHours,
    required this.grossWage,
    required this.netWage,
    required this.wagePercentages,
    this.note,
    this.isSpecialDay = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'startTime': {'hour': startTime.hour, 'minute': startTime.minute},
      'endTime': {'hour': endTime.hour, 'minute': endTime.minute},
      'totalHours': totalHours,
      'grossWage': grossWage,
      'netWage': netWage,
      'wagePercentages': wagePercentages,
      'note': note,
      'isSpecialDay': isSpecialDay,
    };
  }

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'],
      date: DateTime.parse(json['date']),
      startTime: TimeOfDay(
        hour: json['startTime']['hour'],
        minute: json['startTime']['minute'],
      ),
      endTime: TimeOfDay(
        hour: json['endTime']['hour'],
        minute: json['endTime']['minute'],
      ),
      totalHours: json['totalHours'],
      grossWage: json['grossWage'],
      netWage: json['netWage'],
      wagePercentages: Map<String, double>.from(json['wagePercentages']),
      note: json['note'],
      isSpecialDay: json['isSpecialDay'] ?? false,
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

  @override
  String toString() {
    return 'OvertimeRule(id: $id, hoursThreshold: $hoursThreshold, rate: $rate, isForSpecialDays: $isForSpecialDays)';
  }
}