import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'app_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/widgets.dart' show Locale;

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
      
      // Return success to trigger UI feedback
      return Future.value();
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
    // Create PDF with Unicode font support
    final pdf = pw.Document();
    
    // Use a font that supports Unicode
    final font = pw.Font.helvetica();
    final boldFont = pw.Font.helveticaBold();
    
    final date = selectedDate ?? DateTime.now();
    final currentMonth = DateFormat('MMMM yyyy', appState.locale.languageCode).format(date);
    
    final localizations = lookupAppLocalizations(appState.locale);
    final headers = [
      'Date',
      localizations.startTime,
      localizations.endTime,
      localizations.totalHours,
      localizations.grossWage,
      localizations.netWage,
    ];
    
    final monthStart = DateTime(date.year, date.month, 1);
    final monthEnd = DateTime(date.year, date.month + 1, 0);
    final monthShifts = shifts.where((shift) =>
      shift.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
      shift.date.isBefore(monthEnd.add(const Duration(days: 1)))
    ).toList();
    
    double totalHours = monthShifts.fold(0, (sum, shift) => sum + shift.totalHours);
    double totalNetWage = monthShifts.fold(0, (sum, shift) => sum + shift.netWage);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    currentMonth,
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 24,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(5)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${localizations.totalWorkingDays}: ${_calculateWorkingDays(monthShifts)}',
                        style: pw.TextStyle(font: boldFont, fontSize: 14),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        '${localizations.totalHours}: ${totalHours.toStringAsFixed(2)}',
                        style: pw.TextStyle(font: boldFont, fontSize: 14),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        '${localizations.grossWage}: ${monthShifts.fold<double>(0, (sum, shift) => sum + shift.grossWage).toStringAsFixed(2)}',
                        style: pw.TextStyle(font: boldFont, fontSize: 14),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        '${localizations.netWage}: ${totalNetWage.toStringAsFixed(2)}',
                        style: pw.TextStyle(font: boldFont, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  width: double.infinity,
                  child: pw.Table.fromTextArray(
                    context: context,
                    headers: headers,
                    data: () {
                      var sortedShifts = List<Shift>.from(monthShifts)
                        ..sort((a, b) => a.date.compareTo(b.date));
                      return sortedShifts.map((shift) => [
                        DateFormat('dd/MM/yyyy', appState.locale.languageCode).format(shift.date),
                        _formatTimeOfDay(shift.startTime),
                        _formatTimeOfDay(shift.endTime),
                        shift.totalHours.toStringAsFixed(2),
                        shift.grossWage.toStringAsFixed(2),
                        shift.netWage.toStringAsFixed(2),
                      ]).toList();
                    }(),
                    border: pw.TableBorder.all(width: 0.5),
                    headerStyle: pw.TextStyle(font: boldFont),
                    headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    cellStyle: pw.TextStyle(font: font, fontSize: 10),
                    cellAlignment: pw.Alignment.center,
                    cellPadding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 5),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2), // Date column
                      1: const pw.FlexColumnWidth(1.5), // Start Time
                      2: const pw.FlexColumnWidth(1.5), // End Time
                      3: const pw.FlexColumnWidth(1), // Total Hours
                      4: const pw.FlexColumnWidth(1.5), // Gross Wage
                      5: const pw.FlexColumnWidth(1.5), // Net Wage
                    },
                    cellDecoration: (index, data, rowNum) {
                      if (rowNum == -1) return const pw.BoxDecoration(color: PdfColors.grey300); // Header
                      if (rowNum >= monthShifts.length) return const pw.BoxDecoration(); // Empty decoration
                      
                      final shift = monthShifts[rowNum];
                      final isWeekend = _isWeekend(shift.date, appState.startOnSunday);
                      final isFestiveDay = appState.festiveDays.any((festiveDay) =>
                          festiveDay.year == shift.date.year &&
                          festiveDay.month == shift.date.month &&
                          festiveDay.day == shift.date.day);
                      
                      if (shift.isSpecialDay || isWeekend || isFestiveDay) {
                        return const pw.BoxDecoration(color: PdfColors.grey100);
                      }
                      return const pw.BoxDecoration(); // Empty decoration instead of null
                    },
                  ),
                ),
              ],
            ),
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

  bool _isWeekend(DateTime date, bool startOnSunday) {
    if (startOnSunday) {
      return date.weekday == DateTime.friday || date.weekday == DateTime.saturday;
    } else {
      return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    }
  }
}
