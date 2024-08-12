import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:pdf/widgets.dart' as pw;
import 'app_state.dart';

// Conditional imports
import 'export_service_mobile.dart'
    if (dart.library.html) 'export_service_web.dart' as platform;

class ExportService {
  final AppState appState;

  ExportService(this.appState);

  Future<String> createBackup() async {
    try {
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

      return platform.createBackup(jsonString);
    } catch (e) {
      print("Error in createBackup: $e");
      rethrow;
    }
  }

  Future<void> restoreBackup(String source) async {
    try {
      String jsonString = await platform.restoreBackup(source);

      final data = json.decode(jsonString);

      appState.shifts =
          (data['shifts'] as List).map((s) => Shift.fromJson(s)).toList();
      appState.overtimeRules = (data['overtimeRules'] as List)
          .map((r) => OvertimeRule.fromJson(r))
          .toList();
      appState.festiveDays =
          (data['festiveDays'] as List).map((d) => DateTime.parse(d)).toList();

      final settings = data['settings'];
      appState.hourlyWage = settings['hourlyWage'];
      appState.taxDeduction = settings['taxDeduction'];
      appState.startOnSunday = settings['startOnSunday'];
      appState.setLocale(Locale(settings['locale']));
      appState.setCountry(settings['countryCode']);
      appState.baseHoursWeekday = settings['baseHoursWeekday'];
      appState.baseHoursSpecialDay = settings['baseHoursSpecialDay'];

      await appState.saveSettings();
      await appState.saveShifts();
      await appState.saveOvertimeRules();
      await appState.saveFestiveDays();

      appState.notifyListeners();
    } catch (e) {
      print("Error in restoreBackup: $e");
      rethrow;
    }
  }

  Future<String> generateCSV(List<Shift> shifts) async {
    try {
      List<List<dynamic>> rows = [
        [
          'Date',
          'Start Time',
          'End Time',
          'Total Hours',
          'Gross Wage',
          'Net Wage'
        ]
      ];
      for (var shift in shifts) {
        rows.add([
          DateFormat('yyyy-MM-dd').format(shift.date),
          _formatTimeOfDay(shift.startTime),
          _formatTimeOfDay(shift.endTime),
          shift.totalHours.toStringAsFixed(2),
          shift.grossWage.toStringAsFixed(2),
          shift.netWage.toStringAsFixed(2)
        ]);
      }
      String csv = const ListToCsvConverter().convert(rows);

      return platform.generateCSV(csv);
    } catch (e) {
      print("Error in generateCSV: $e");
      rethrow;
    }
  }

  Future<String> generatePDF(List<Shift> shifts) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Table.fromTextArray(
            context: context,
            data: <List<String>>[
              <String>[
                'Date',
                'Start Time',
                'End Time',
                'Total Hours',
                'Gross Wage',
                'Net Wage'
              ],
              ...shifts.map((shift) => [
                    DateFormat('yyyy-MM-dd').format(shift.date),
                    _formatTimeOfDay(shift.startTime),
                    _formatTimeOfDay(shift.endTime),
                    shift.totalHours.toStringAsFixed(2),
                    shift.grossWage.toStringAsFixed(2),
                    shift.netWage.toStringAsFixed(2),
                  ]),
            ],
          ),
        ),
      );

      final pdfBytes = await pdf.save();

      return platform.generatePDF(pdfBytes);
    } catch (e) {
      print("Error in generatePDF: $e");
      rethrow;
    }
  }

  Future<void> shareFile(String filePath, String subject) async {
    try {
      await platform.shareFile(filePath, subject);
    } catch (e) {
      print("Error in shareFile: $e");
      rethrow;
    }
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return DateFormat('HH:mm').format(dateTime);
  }
}
