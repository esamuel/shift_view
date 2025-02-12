import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/shift.dart';
import 'models/overtime_rule.dart';
import 'services/firebase_service.dart';

class AppState extends ChangeNotifier {
  List<Shift> shifts = [];
  List<OvertimeRule> overtimeRules = [];
  List<DateTime> festiveDays = [];
  Stream<List<Shift>>? _shiftsStream;
  Stream<List<OvertimeRule>>? _overtimeRulesStream;

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
  Stream<List<Shift>>? get shiftsStream => _shiftsStream;
  Stream<List<OvertimeRule>>? get overtimeRulesStream => _overtimeRulesStream;

  AppState() {
    print('AppState: Constructor called');
    FirebaseService.auth.authStateChanges().listen((user) {
      if (user != null) {
        print('AppState: User authenticated, initializing state');
        _initializeState();
      } else {
        print('AppState: User signed out, resetting state');
        _resetState();
      }
    });
  }

  void _resetState() {
    print('AppState: Resetting state');
    shifts = [];
    overtimeRules = [];
    festiveDays = [];
    _shiftsStream = null;
    _overtimeRulesStream = null;
    _hourlyWage = 0;
    _taxDeduction = 0;
    _startOnSunday = true;
    _locale = const Locale('en', '');
    _countryCode = 'IL';
    _baseHoursWeekday = 8.0;
    _baseHoursSpecialDay = 8.0;
    _isDarkMode = false;
    _userName = '';
    notifyListeners();
  }

  Future<void> _initializeState() async {
    print('AppState: Starting initialization');
    try {
      await _loadSettingsFromFirestore();
      _initializeShiftsStream();
      _initializeOvertimeRulesStream();

      // Verify overtime rules
      await FirebaseService.verifyOvertimeRules();

      await loadFestiveDays();
      print('AppState: Initialization complete');
    } catch (e) {
      print('AppState: Error during initialization: $e');
    }
  }

  void _initializeShiftsStream() {
    print('AppState: Initializing shifts stream');
    if (_shiftsStream != null) {
      print('AppState: Shifts stream already initialized');
      return;
    }

    try {
      print('AppState: Creating new shifts stream');
      _shiftsStream = FirebaseService.getShifts();

      // Force immediate data fetch
      FirebaseService.getShifts().first.then((initialShifts) {
        print('AppState: Got initial shifts: ${initialShifts.length}');
        shifts = initialShifts;
        notifyListeners();
      }).catchError((error) {
        print('AppState: Error getting initial shifts: $error');
      });

      // Set up continuous stream
      _shiftsStream?.listen(
        (updatedShifts) {
          print(
              'AppState: Stream update - received ${updatedShifts.length} shifts');
          shifts = updatedShifts;
          notifyListeners();
        },
        onError: (error) {
          print('AppState: Error in shifts stream: $error');
          _shiftsStream = null;
        },
        cancelOnError: false,
      );
    } catch (e) {
      print('AppState: Error initializing shifts stream: $e');
      _shiftsStream = null;
    }
  }

  void _initializeOvertimeRulesStream() {
    print('AppState: Initializing overtime rules stream');
    _overtimeRulesStream = FirebaseService.getOvertimeRules();
    _overtimeRulesStream?.listen(
      (updatedRules) {
        print(
            'AppState: Received ${updatedRules.length} overtime rules from stream');
        print('AppState: Rules data: $updatedRules');
        overtimeRules = updatedRules;
        notifyListeners();
      },
      onError: (error) {
        print('AppState: Error in overtime rules stream: $error');
      },
    );
  }

  Future<void> _loadSettingsFromFirestore() async {
    print('AppState: Loading settings from Firestore');
    try {
      final settings = await FirebaseService.getUserSettings();
      if (settings != null) {
        print('AppState: Settings found in Firestore');
        _hourlyWage = settings['hourlyWage'] ?? 40.0;
        _taxDeduction = settings['taxDeduction'] ?? 10.0;
        _startOnSunday = settings['startOnSunday'] ?? true;
        _locale = Locale(settings['languageCode'] ?? 'en', '');
        _countryCode = settings['countryCode'] ?? 'IL';
        _baseHoursWeekday = settings['baseHoursWeekday'] ?? 8.0;
        _baseHoursSpecialDay = settings['baseHoursSpecialDay'] ?? 8.0;
        _isDarkMode = settings['isDarkMode'] ?? false;
        notifyListeners();
      } else {
        print('AppState: No settings found in Firestore, using defaults');
        // Initialize with defaults
        _hourlyWage = 40.0;
        _taxDeduction = 10.0;
        _startOnSunday = true;
        _locale = const Locale('en', '');
        _countryCode = 'IL';
        _baseHoursWeekday = 8.0;
        _baseHoursSpecialDay = 8.0;
        _isDarkMode = false;
        notifyListeners();

        // Save defaults to Firestore
        await _saveSettingsToFirestore();
      }
    } catch (e) {
      print('AppState: Error loading settings: $e');
      // Load from local storage as fallback
      await loadSettings();
    }
  }

  Future<void> _saveSettingsToFirestore() async {
    final settings = {
      'hourlyWage': _hourlyWage,
      'taxDeduction': _taxDeduction,
      'startOnSunday': _startOnSunday,
      'languageCode': _locale.languageCode,
      'countryCode': _countryCode,
      'baseHoursWeekday': _baseHoursWeekday,
      'baseHoursSpecialDay': _baseHoursSpecialDay,
      'isDarkMode': _isDarkMode,
    };
    await FirebaseService.saveUserSettings(settings);
  }

  // Setters with Firestore integration
  set hourlyWage(double value) {
    _hourlyWage = value;
    notifyListeners();
    _saveSettingsToFirestore();
  }

  set taxDeduction(double value) {
    _taxDeduction = value.clamp(0.0, 100.0);
    notifyListeners();
    _saveSettingsToFirestore();
  }

  set startOnSunday(bool value) {
    _startOnSunday = value;
    notifyListeners();
    _saveSettingsToFirestore();
  }

  void setLocale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners();
    _saveSettingsToFirestore();
  }

  void setCountry(String newCountryCode) {
    _countryCode = newCountryCode;
    notifyListeners();
    _saveSettingsToFirestore();
  }

  set baseHoursWeekday(double value) {
    _baseHoursWeekday = value;
    notifyListeners();
    _saveSettingsToFirestore();
  }

  set baseHoursSpecialDay(double value) {
    _baseHoursSpecialDay = value;
    notifyListeners();
    _saveSettingsToFirestore();
  }

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    _saveSettingsToFirestore();
  }

  // Local storage methods (as fallback)
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

  // Shift management methods
  Future<void> addShift(Shift shift) async {
    await FirebaseService.saveShift(shift);
  }

  Future<void> updateShift(int index, Shift updatedShift) async {
    await FirebaseService.updateShift(updatedShift.id, updatedShift);
  }

  Future<void> deleteShift(int index) async {
    if (index >= 0 && index < shifts.length) {
      final shiftId = shifts[index].id;
      await FirebaseService.deleteShift(shiftId);
    }
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

  void addOvertimeRule(OvertimeRule rule) async {
    print('AppState: Adding overtime rule: $rule');
    try {
      // Create a new list and add the rule
      final newRules = List<OvertimeRule>.from(overtimeRules);
      newRules.add(rule);

      // Save all rules
      await FirebaseService.saveOvertimeRules(newRules);
      print('AppState: Overtime rule added successfully');
      // The stream will update the UI automatically
    } catch (e) {
      print('AppState: Error adding overtime rule: $e');
      rethrow;
    }
  }

  void updateOvertimeRule(int index, OvertimeRule updatedRule) async {
    print('AppState: Updating overtime rule at index $index: $updatedRule');
    if (index >= 0 && index < overtimeRules.length) {
      try {
        // Create a new list and update the rule
        final newRules = List<OvertimeRule>.from(overtimeRules);
        newRules[index] = updatedRule;

        // Save all rules
        await FirebaseService.saveOvertimeRules(newRules);
        print('AppState: Overtime rule updated successfully');
        // The stream will update the UI automatically
      } catch (e) {
        print('AppState: Error updating overtime rule: $e');
        rethrow;
      }
    }
  }

  void deleteOvertimeRule(int index) async {
    print('AppState: Deleting overtime rule at index $index');
    if (index >= 0 && index < overtimeRules.length) {
      try {
        // Create a new list and remove the rule
        final newRules = List<OvertimeRule>.from(overtimeRules);
        newRules.removeAt(index);

        // Save all rules
        await FirebaseService.saveOvertimeRules(newRules);
        print('AppState: Overtime rule deleted successfully');
        // The stream will update the UI automatically
      } catch (e) {
        print('AppState: Error deleting overtime rule: $e');
        rethrow;
      }
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
    await _saveSettingsToFirestore();
  }

  Future<void> updateBaseHours({
    required double weekday,
    required double specialDay,
  }) async {
    _baseHoursWeekday = weekday;
    _baseHoursSpecialDay = specialDay;
    notifyListeners();
    await _saveSettingsToFirestore();
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
    return shifts
        .where((shift) =>
            shift.date.isAfter(start.subtract(const Duration(days: 1))) &&
            shift.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  // Add a method to ensure shifts stream is initialized
  void ensureShiftsStreamInitialized() {
    if (_shiftsStream == null && FirebaseService.currentUserEmail != null) {
      print('AppState: Ensuring shifts stream is initialized');
      _initializeShiftsStream();
    }
  }

  // Add method to force refresh shifts
  Future<void> refreshShifts() async {
    print('AppState: Forcing shifts refresh');
    try {
      final freshShifts = await FirebaseService.getShifts().first;
      print('AppState: Refresh got ${freshShifts.length} shifts');
      shifts = freshShifts;
      notifyListeners();
    } catch (e) {
      print('AppState: Error refreshing shifts: $e');
    }
  }
}
