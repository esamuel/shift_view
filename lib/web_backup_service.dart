import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart'; // Add this import for Locale
import 'package:universal_html/html.dart' as html;
import 'app_state.dart';

class WebBackupService {
  static Future<void> createBackup(AppState appState) async {
    if (!kIsWeb) return;

    final data = {
      'shifts': appState.shifts.map((s) => s.toJson()).toList(),
      'overtimeRules': appState.overtimeRules.map((r) => r.toJson()).toList(),
      'festiveDays':
          appState.festiveDays.map((d) => d.toIso8601String()).toList(),
      'settings': {
        'hourlyWage': appState.hourlyWage,
        'taxDeduction': appState.taxDeduction,
        'startOnSunday': appState.startOnSunday,
        'locale': appState.locale.languageCode,
        'countryCode': appState.countryCode,
        'baseHoursWeekday': appState.baseHoursWeekday,
        'baseHoursSpecialDay': appState.baseHoursSpecialDay,
      },
    };

    final jsonString = json.encode(data);
    final bytes = utf8.encode(jsonString);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'shift_view_backup.json';
    html.document.body!.children.add(anchor);

    anchor.click();

    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  static Future<void> restoreBackup(AppState appState) async {
    if (!kIsWeb) return;

    final input = html.FileUploadInputElement()..accept = '.json';
    input.click();

    await input.onChange.first;
    if (input.files!.isEmpty) return;

    final file = input.files!.first;
    final reader = html.FileReader();
    reader.readAsText(file);
    await reader.onLoad.first;

    final jsonString = reader.result as String;
    final data = json.decode(jsonString);

    appState.shifts = (data['shifts'] as List)
        .map((shiftData) => Shift.fromJson(shiftData))
        .toList();
    appState.overtimeRules = (data['overtimeRules'] as List)
        .map((ruleData) => OvertimeRule.fromJson(ruleData))
        .toList();
    appState.festiveDays = (data['festiveDays'] as List)
        .map((dateString) => DateTime.parse(dateString))
        .toList();

    final settings = data['settings'];
    appState.hourlyWage = settings['hourlyWage'];
    appState.taxDeduction = settings['taxDeduction'];
    appState.startOnSunday = settings['startOnSunday'];
    appState
        .setLocale(Locale(settings['locale'])); // Use Locale constructor here
    appState.setCountry(settings['countryCode']);
    appState.baseHoursWeekday = settings['baseHoursWeekday'];
    appState.baseHoursSpecialDay = settings['baseHoursSpecialDay'];

    appState.notifyListeners();
  }
}
