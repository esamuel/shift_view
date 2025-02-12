import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'app_state.dart';
import 'models/shift.dart';
import 'models/overtime_rule.dart';

class ExportService {
  final AppState appState;

  ExportService(this.appState);

  String _formatTimeOfDay(DateTime? dateTime) {
    if (dateTime == null) return '--:--';
    final time = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<String> generateCSV(List<Shift> shifts) async {
    List<List<dynamic>> rows = [];
    
    // Add header row
    rows.add([
      'Date',
      'Start Time',
      'End Time',
      'Total Hours',
      'Gross Wage',
      'Net Wage'
    ]);

    // Add data rows
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
    
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/shifts_report.csv';
    final file = File(path);
    await file.writeAsString(csv);
    
    return path;
  }

  Future<String> generatePDF(List<Shift> shifts) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            headers: ['Date', 'Start Time', 'End Time', 'Hours', 'Gross', 'Net'],
            data: [
              ...shifts.map((shift) => [
                    DateFormat('yyyy-MM-dd').format(shift.date),
                    _formatTimeOfDay(shift.startTime),
                    _formatTimeOfDay(shift.endTime),
                    shift.totalHours.toStringAsFixed(2),
                    shift.grossWage.toStringAsFixed(2),
                    shift.netWage.toStringAsFixed(2),
                  ])
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/shifts_report.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());

    return path;
  }

  Future<void> shareFile(String filePath, String subject) async {
    await Share.shareFiles([filePath], subject: subject);
  }

  Future<String> createBackup() async {
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
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/shift_view_backup.json';
    final file = File(path);
    await file.writeAsString(jsonString);

    return path;
  }

  Future<void> restoreBackup(String filePath) async {
    final file = File(filePath);
    final jsonString = await file.readAsString();
    final data = json.decode(jsonString);

    appState.shifts =
        (data['shifts'] as List).map((s) => Shift.fromJson(s)).toList();
    appState.overtimeRules = (data['overtimeRules'] as List)
        .map((r) => OvertimeRule.fromJson(r))
        .toList();
    appState.festiveDays =
        (data['festiveDays'] as List).map((d) => DateTime.parse(d)).toList();

    final settings = data['settings'];
    appState.updateSettings(
      hourlyWage: settings['hourlyWage'],
      taxDeduction: settings['taxDeduction'],
      startOnSunday: settings['startOnSunday'],
      languageCode: settings['locale'],
      countryCode: settings['countryCode'],
      baseHoursWeekday: settings['baseHoursWeekday'],
      baseHoursSpecialDay: settings['baseHoursSpecialDay'],
    );
  }
}
