import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'app_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'models/pdf_config.dart';

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

  Future<String> generatePDF(
    List<Shift> shifts,
    AppState appState,
    PDFConfig config,
  ) async {
    final pdf = pw.Document();

    // Add company logo if provided
    pw.Image? logoImage;
    if (config.companyLogo != null) {
      final logoBytes = base64Decode(config.companyLogo!);
      logoImage = pw.Image(pw.MemoryImage(logoBytes));
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: config.pageFormat,
        header: (context) => _buildHeader(context, config, logoImage),
        footer: (context) => _buildFooter(context, config),
        build: (context) => [
          _buildTitle(config),
          _buildDateRange(shifts, config),
          _buildShiftsTable(shifts, appState),
          _buildSummary(shifts, appState),
        ],
      ),
    );

    return platform.generatePDF(await pdf.save());
  }

  pw.Widget _buildHeader(
    pw.Context context,
    PDFConfig config,
    pw.Image? logoImage,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          if (logoImage != null)
            pw.Container(
              height: 50,
              child: logoImage,
            ),
          if (config.companyName != null)
            pw.Text(
              config.companyName!,
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          if (config.customHeader != null)
            pw.Text(config.customHeader!),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context, PDFConfig config) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          if (config.includePageNumbers)
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
            ),
          if (config.customFooter != null)
            pw.Text(config.customFooter!),
          pw.Text(DateTime.now().toString().split('.')[0]),
        ],
      ),
    );
  }

  pw.Widget _buildTitle(PDFConfig config) {
    return pw.Header(
      level: 0,
      child: pw.Text(
        config.headerText ?? 'Shifts Report',
        style: pw.TextStyle(
          fontSize: 24,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildDateRange(List<Shift> shifts, PDFConfig config) {
    if (!config.includeDateRange) return pw.Container();

    final firstDate = shifts.first.date;
    final lastDate = shifts.last.date;
    
    return pw.Paragraph(
      text: 'Period: ${_formatDate(firstDate)} - ${_formatDate(lastDate)}',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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

  pw.Widget _buildShiftsTable(List<Shift> shifts, AppState appState) {
    final headers = [
      'Date',
      'Start Time',
      'End Time',
      'Total Hours',
      'Gross Wage',
      'Net Wage',
    ];

    return pw.Table.fromTextArray(
      headers: headers,
      data: shifts.map((shift) => [
        DateFormat('dd/MM/yyyy').format(shift.date),
        _formatTimeOfDay(shift.startTime),
        _formatTimeOfDay(shift.endTime),
        shift.totalHours.toStringAsFixed(2),
        shift.grossWage.toStringAsFixed(2),
        shift.netWage.toStringAsFixed(2),
      ]).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      border: pw.TableBorder.all(),
      headerDecoration: pw.BoxDecoration(
        color: PdfColors.grey300,
      ),
    );
  }

  pw.Widget _buildSummary(List<Shift> shifts, AppState appState) {
    final totalHours = shifts.fold<double>(
      0,
      (sum, shift) => sum + shift.totalHours,
    );
    final totalGrossWage = shifts.fold<double>(
      0,
      (sum, shift) => sum + shift.grossWage,
    );
    final totalNetWage = shifts.fold<double>(
      0,
      (sum, shift) => sum + shift.netWage,
    );

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Summary',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Total Hours: ${totalHours.toStringAsFixed(2)}'),
          pw.Text('Total Gross Wage: ${totalGrossWage.toStringAsFixed(2)}'),
          pw.Text('Total Net Wage: ${totalNetWage.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}
