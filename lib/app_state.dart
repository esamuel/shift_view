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

  Locale get locale => _locale;

  AppState() {
    loadSettings();
    loadShifts();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    hourlyWage = prefs.getDouble('hourlyWage') ?? 0;
    taxDeduction = prefs.getDouble('taxDeduction') ?? 0;
    startOnSunday = prefs.getBool('startOnSunday') ?? true;
    _locale = Locale(prefs.getString('languageCode') ?? 'en', '');
    notifyListeners();
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('hourlyWage', hourlyWage);
    await prefs.setDouble('taxDeduction', taxDeduction);
    await prefs.setBool('startOnSunday', startOnSunday);
    await prefs.setString('languageCode', _locale.languageCode);
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

  static Shift fromJson(Map<String, dynamic> json) {
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
