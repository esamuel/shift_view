import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'app_state.dart';
import 'export_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:math' as math;
import 'rtl_fix.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime _selectedDate = DateTime.now();
  late ExportService _exportService;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _exportService = ExportService(appState);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final localizations = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.reportsTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: localizations.weeklyView),
              Tab(text: localizations.monthlyView),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildWeeklyReport(appState, localizations),
            _buildMonthlyReport(appState, localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyReport(AppState appState, AppLocalizations localizations) {
    final weekStart = _getWeekStart(_selectedDate, appState.startOnSunday);
    final weekEnd = weekStart.add(Duration(days: 6));
    final weekShifts = appState.shifts
        .where((shift) =>
            shift.date.isAfter(weekStart.subtract(Duration(days: 1))) &&
            shift.date.isBefore(weekEnd.add(Duration(days: 1))))
        .toList();

    return Column(
      children: [
        _buildDateSelector(localizations),
        Text(
          '${_getLocalizedDate(localizations, weekStart)} - ${_getLocalizedDate(localizations, weekEnd)}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: _buildShiftsList(weekShifts, appState, localizations),
        ),
        _buildTotalRow(weekShifts, appState, localizations,
            _calculateWorkingDays(weekShifts)),
        _buildPercentageTotals(weekShifts, appState, localizations),
        _buildExportButtons(localizations, weekShifts),
      ],
    );
  }

  Widget _buildMonthlyReport(
      AppState appState, AppLocalizations localizations) {
    final monthStart = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final monthEnd = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final monthShifts = appState.shifts
        .where((shift) =>
            shift.date.isAfter(monthStart.subtract(Duration(days: 1))) &&
            shift.date.isBefore(monthEnd.add(Duration(days: 1))))
        .toList();

    final totalWorkingDays = _calculateWorkingDays(monthShifts);

    return Column(
      children: [
        _buildDateSelector(localizations),
        Text(
          _getLocalizedMonthYear(localizations, _selectedDate),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: _buildShiftsList(monthShifts, appState, localizations),
        ),
        _buildTotalRow(monthShifts, appState, localizations, totalWorkingDays),
        _buildPercentageTotals(monthShifts, appState, localizations),
        _buildExportButtons(localizations, monthShifts),
      ],
    );
  }

  Widget _buildDateSelector(AppLocalizations localizations) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _selectedDate = _selectedDate.subtract(Duration(days: 7));
            });
          },
        ),
        TextButton(
          child: Text(_getLocalizedMonthYear(localizations, _selectedDate)),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (picked != null) {
              setState(() {
                _selectedDate = picked;
              });
            }
          },
        ),
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              _selectedDate = _selectedDate.add(Duration(days: 7));
            });
          },
        ),
      ],
    );
  }

  Widget _buildShiftsList(
      List<Shift> shifts, AppState appState, AppLocalizations localizations) {
    shifts.sort((a, b) => a.date.compareTo(b.date));
    return ListView.builder(
      itemCount: shifts.length,
      itemBuilder: (context, index) {
        final shift = shifts[index];
        return ListTile(
          title: Text(_getLocalizedDayMonth(localizations, shift.date)),
          subtitle: Row(
            children: [
              Text('${localizations.startTime}: '),
              RTLFix.number(_formatTime(shift.startTime)),
              Text(' - ${localizations.endTime}: '),
              RTLFix.number(_formatTime(shift.endTime)),
            ],
          ),
          trailing: RTLFix.number(
              '${appState.getCurrencySymbol()}${shift.grossWage.toStringAsFixed(2)}'),
        );
      },
    );
  }

  Widget _buildTotalRow(List<Shift> shifts, AppState appState,
      AppLocalizations localizations, int totalWorkingDays) {
    final totalHours =
        shifts.fold<double>(0, (sum, shift) => sum + shift.totalHours);
    final totalGrossWage =
        shifts.fold<double>(0, (sum, shift) => sum + shift.grossWage);
    final totalNetWage =
        shifts.fold<double>(0, (sum, shift) => sum + shift.netWage);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${localizations.totalWorkingDays}: '),
              RTLFix.number('$totalWorkingDays'),
            ],
          ),
          Row(
            children: [
              Text('${localizations.totalHours}: '),
              RTLFix.number(totalHours.toStringAsFixed(2)),
            ],
          ),
          Row(
            children: [
              Text('${localizations.grossWage}: '),
              RTLFix.number(
                  '${appState.getCurrencySymbol()}${totalGrossWage.toStringAsFixed(2)}'),
            ],
          ),
          Row(
            children: [
              Text('${localizations.netWage}: '),
              RTLFix.number(
                  '${appState.getCurrencySymbol()}${totalNetWage.toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageTotals(
      List<Shift> shifts, AppState appState, AppLocalizations localizations) {
    final percentageTotals = _calculatePercentageTotals(shifts, appState);

    final sortedEntries = percentageTotals.entries.toList()
      ..sort((a, b) => int.parse(a.key.replaceAll('%', ''))
          .compareTo(int.parse(b.key.replaceAll('%', ''))));

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(localizations.wageBreakdown,
              style: TextStyle(fontWeight: FontWeight.bold)),
          ...sortedEntries.map((entry) {
            return Row(
              children: [
                Text('${entry.key}: '),
                RTLFix.number(
                    '${entry.value.toStringAsFixed(2)} ${localizations.hours}'),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildExportButtons(
      AppLocalizations localizations, List<Shift> shifts) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              child: Text(localizations.exportAsCsv),
              onPressed: () => _exportReport(shifts, 'csv'),
            ),
            ElevatedButton(
              child: Text(localizations.exportAsPdf),
              onPressed: () => _exportReport(shifts, 'pdf'),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              child: Text(localizations.backup),
              onPressed: () => _createBackup(localizations),
            ),
            ElevatedButton(
              child: Text(localizations.restore),
              onPressed: () => _restoreBackup(localizations),
            ),
          ],
        ),
      ],
    );
  }

  Map<String, double> _calculatePercentageTotals(
      List<Shift> shifts, AppState appState) {
    Map<String, double> totals = {};

    for (var shift in shifts) {
      final isSpecialDay = _isWeekend(appState, shift.date) ||
          _isFestiveDay(appState, shift.date);
      double remainingHours = shift.totalHours;

      final applicableRules = appState.overtimeRules
          .where((rule) => rule.isForSpecialDays == isSpecialDay)
          .toList()
        ..sort((a, b) => a.hoursThreshold.compareTo(b.hoursThreshold));

      double baseHours = isSpecialDay
          ? appState.baseHoursSpecialDay
          : appState.baseHoursWeekday;
      double baseRate = isSpecialDay ? 1.5 : 1.0;

      // Apply base rate
      double hoursAtBaseRate = math.min(remainingHours, baseHours);
      String baseKey = '${(baseRate * 100).toInt()}%';
      totals[baseKey] = (totals[baseKey] ?? 0) + hoursAtBaseRate;
      remainingHours -= hoursAtBaseRate;

      // Apply overtime rules
      for (int i = 0; i < applicableRules.length; i++) {
        var rule = applicableRules[i];
        double nextThreshold = i < applicableRules.length - 1
            ? applicableRules[i + 1].hoursThreshold
            : double.infinity;

        if (shift.totalHours > rule.hoursThreshold) {
          double hoursAtThisRate =
              math.min(remainingHours, nextThreshold - rule.hoursThreshold);

          if (hoursAtThisRate > 0) {
            String key = '${(rule.rate * 100).toInt()}%';
            totals[key] = (totals[key] ?? 0) + hoursAtThisRate;
            remainingHours -= hoursAtThisRate;
          }
        }

        if (remainingHours <= 0) break;
      }
    }

    return totals;
  }

  void _exportReport(List<Shift> shifts, String format) async {
    try {
      String filePath;

      if (format == 'csv') {
        filePath = await _exportService.generateCSV(shifts);
      } else {
        filePath = await _exportService.generatePDF(shifts);
      }

      await _exportService.shareFile(filePath, 'Shift Report');
    } catch (e) {
      print("Error exporting report: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Export failed: $e")),
      );
    }
  }

  void _createBackup(AppLocalizations localizations) async {
    try {
      final backupPath = await _exportService.createBackup();
      await _exportService.shareFile(backupPath, 'Shift View Backup');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.backupCreated)),
      );
    } catch (e) {
      print("Error creating backup: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${localizations.backupFailed}: $e")),
      );
    }
  }

  void _restoreBackup(AppLocalizations localizations) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        String filePath = result.files.single.path!;
        await _exportService.restoreBackup(filePath);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.backupRestored)),
        );
      }
    } catch (e) {
      print("Error restoring backup: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.restoreFailed)),
      );
    }
  }

  bool _isWeekend(AppState appState, DateTime date) {
    if (appState.startOnSunday) {
      return date.weekday == DateTime.saturday;
    } else {
      return date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday;
    }
  }

  bool _isFestiveDay(AppState appState, DateTime date) {
    return appState.festiveDays.any((festiveDay) =>
        festiveDay.year == date.year &&
        festiveDay.month == date.month &&
        festiveDay.day == date.day);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  DateTime _getWeekStart(DateTime date, bool startOnSunday) {
    int daysToSubtract;
    if (startOnSunday) {
      daysToSubtract = date.weekday % 7;
    } else {
      daysToSubtract = (date.weekday - 1) % 7;
    }
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysToSubtract));
  }

  String _getLocalizedDate(AppLocalizations localizations, DateTime date) {
    final month = _getLocalizedMonth(localizations, date.month);
    return '$month ${date.day}, ${date.year}';
  }

  String _getLocalizedDayMonth(AppLocalizations localizations, DateTime date) {
    final day = _getLocalizedDay(localizations, date.weekday);
    final month = _getLocalizedMonth(localizations, date.month);
    return '$day, $month ${date.day}';
  }

  String _getLocalizedMonthYear(AppLocalizations localizations, DateTime date) {
    final month = _getLocalizedMonth(localizations, date.month);
    return '$month ${date.year}';
  }

  String _getLocalizedDay(AppLocalizations localizations, int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return localizations.monday;
      case DateTime.tuesday:
        return localizations.tuesday;
      case DateTime.wednesday:
        return localizations.wednesday;
      case DateTime.thursday:
        return localizations.thursday;
      case DateTime.friday:
        return localizations.friday;
      case DateTime.saturday:
        return localizations.saturday;
      case DateTime.sunday:
        return localizations.sunday;
      default:
        return '';
    }
  }

  String _getLocalizedMonth(AppLocalizations localizations, int month) {
    switch (month) {
      case 1:
        return localizations.january;
      case 2:
        return localizations.february;
      case 3:
        return localizations.march;
      case 4:
        return localizations.april;
      case 5:
        return localizations.may;
      case 6:
        return localizations.june;
      case 7:
        return localizations.july;
      case 8:
        return localizations.august;
      case 9:
        return localizations.september;
      case 10:
        return localizations.october;
      case 11:
        return localizations.november;
      case 12:
        return localizations.december;
      default:
        return '';
    }
  }

  int _calculateWorkingDays(List<Shift> shifts) {
    final Set<DateTime> workingDays = shifts
        .map((shift) =>
            DateTime(shift.date.year, shift.date.month, shift.date.day))
        .toSet();
    return workingDays.length;
  }
}
