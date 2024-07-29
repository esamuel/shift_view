import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'app_state.dart';

class ExportService {
  final AppState appState;

  ExportService(this.appState);

  Future<String> generateCSV(List<Shift> shifts) async {
    List<List<dynamic>> rows = [];
    final currencySymbol = appState.getCurrencySymbol();

    // Add header row
    rows.add([
      'Date',
      'Start Time',
      'End Time',
      'Total Hours',
      'Gross Wage ($currencySymbol)',
      'Net Wage ($currencySymbol)',
    ]);

    // Add data rows
    for (var shift in shifts) {
      rows.add([
        DateFormat('yyyy-MM-dd').format(shift.date),
        _formatTimeOfDay(shift.startTime),
        _formatTimeOfDay(shift.endTime),
        shift.totalHours.toStringAsFixed(2),
        shift.grossWage.toStringAsFixed(2),
        shift.netWage.toStringAsFixed(2),
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/shifts_report.csv');
    await file.writeAsString(csv);

    return file.path;
  }

  Future<String> generatePDF(List<Shift> shifts) async {
    final pdf = pw.Document();
    final currencySymbol = appState.getCurrencySymbol();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Shifts Report'),
              ),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>[
                    'Date',
                    'Start Time',
                    'End Time',
                    'Total Hours',
                    'Gross Wage ($currencySymbol)',
                    'Net Wage ($currencySymbol)'
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
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/shifts_report.pdf');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  Future<String> createBackup({Function(double)? onProgress}) async {
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
    final file = File('${directory.path}/shift_view_backup.json');

    // Simulate progress for demonstration purposes
    // In a real scenario, you'd base this on actual file write progress
    for (var i = 0; i <= 100; i++) {
      await Future.delayed(Duration(milliseconds: 20));
      onProgress?.call(i / 100);
    }

    await file.writeAsString(jsonString);
    return file.path;
  }

  Future<void> restoreBackup(String filePath,
      {Function(double)? onProgress}) async {
    final file = File(filePath);
    if (await file.exists()) {
      final jsonString = await file.readAsString();
      final data = json.decode(jsonString);

      // Simulate progress for demonstration purposes
      for (var i = 0; i <= 100; i++) {
        await Future.delayed(Duration(milliseconds: 20));
        onProgress?.call(i / 100);
      }

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
      appState.setLocale(Locale(settings['locale']));
      appState.setCountry(settings['countryCode']);
      appState.baseHoursWeekday = settings['baseHoursWeekday'];
      appState.baseHoursSpecialDay = settings['baseHoursSpecialDay'];

      await appState.saveSettings();
      await appState.saveShifts();
      await appState.saveOvertimeRules();
      await appState.saveFestiveDays();

      appState.notifyListeners();
    }
  }

  Future<void> shareFile(String filePath, String subject) async {
    final result = await Share.shareXFiles(
      [XFile(filePath)],
      subject: subject,
    );

    if (result.status == ShareResultStatus.success) {
      print('Share successful');
    } else {
      print('Share failed');
    }
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return DateFormat('HH:mm').format(dateTime);
  }
}
