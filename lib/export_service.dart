import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
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
      if (jsonString.isEmpty) {
        throw Exception('No backup data found');
      }

      final data = json.decode(jsonString);
      
      // Validate required fields
      if (data['shifts'] == null || data['settings'] == null) {
        throw Exception('Invalid backup format');
      }

      // Clear existing data
      appState.shifts.clear();
      appState.overtimeRules.clear();
      appState.festiveDays.clear();

      // Restore data
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

  Future<String> generatePDF(List<Shift> shifts, {DateTime? selectedDate}) async {
    final pdf = pw.Document();
    final date = selectedDate ?? DateTime.now();
    final currentMonth = DateFormat('MMMM yyyy').format(date);
    
    // Filter shifts for selected month
    final monthStart = DateTime(date.year, date.month, 1);
    final monthEnd = DateTime(date.year, date.month + 1, 0);
    final monthShifts = shifts.where((shift) =>
      shift.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
      shift.date.isBefore(monthEnd.add(const Duration(days: 1)))
    ).toList();
    
    // Calculate totals for filtered month
    double totalHours = monthShifts.fold(0, (sum, shift) => sum + shift.totalHours);
    double totalNetWage = monthShifts.fold(0, (sum, shift) => sum + shift.netWage);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Text(
                  currentMonth,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              // Totals
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Total Working Days: ${_calculateWorkingDays(monthShifts)}',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Total Hours: ${totalHours.toStringAsFixed(2)}',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Total Gross Wage: ${monthShifts.fold<double>(0, (sum, shift) => sum + shift.grossWage).toStringAsFixed(2)}',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Total Net Wage: ${totalNetWage.toStringAsFixed(2)}',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              // Modified table
              pw.Table.fromTextArray(
                context: context,
                headers: ['Date', 'Start Time', 'End Time', 'Hours', 'Gross Wage', 'Net Wage'],
                data: () {
                  var sortedShifts = List<Shift>.from(monthShifts);
                  sortedShifts.sort((a, b) => a.date.compareTo(b.date));
                  return sortedShifts.map((shift) => [
                    DateFormat('dd/MM/yyyy').format(shift.date),
                    _formatTimeOfDay(shift.startTime),
                    _formatTimeOfDay(shift.endTime),
                    shift.totalHours.toStringAsFixed(2),
                    shift.grossWage.toStringAsFixed(2),
                    shift.netWage.toStringAsFixed(2),
                  ]).toList();
                }(),
                border: pw.TableBorder.all(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                cellStyle: pw.TextStyle(fontSize: 10),
                cellAlignment: pw.Alignment.center,
                cellPadding: const pw.EdgeInsets.all(5),
              ),
            ],
          );
        },
      ),
    );

    return platform.generatePDF(await pdf.save());
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

  int _calculateWorkingDays(List<Shift> shifts) {
    final Set<DateTime> workingDays = shifts
        .map((shift) => DateTime(shift.date.year, shift.date.month, shift.date.day))
        .toSet();
    return workingDays.length;
  }
}
