import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'app_state.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _isMonthlyView = false;

  String _getCurrencySymbol(String locale) {
    final format = NumberFormat.simpleCurrency(locale: locale);
    return format.currencySymbol;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.reportsTitle),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: Text(_isMonthlyView
                ? localizations.monthlyView
                : localizations.weeklyView),
            value: _isMonthlyView,
            onChanged: (bool value) {
              setState(() {
                _isMonthlyView = value;
              });
            },
          ),
          Expanded(
            child:
                _isMonthlyView ? _buildMonthlyReport() : _buildWeeklyReport(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyReport() {
    final localizations = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final currencySymbol = _getCurrencySymbol(locale);
    final numberFormat = NumberFormat.decimalPattern(locale);

    return Consumer<AppState>(
      builder: (context, appState, child) {
        var weeklyReports = _generateWeeklyReports(appState);
        return ListView.builder(
          itemCount: weeklyReports.length,
          itemBuilder: (context, index) {
            var report = weeklyReports[index];
            return ListTile(
              title: Text('${report['startDate']} to ${report['endDate']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${localizations.totalHours}: ${numberFormat.format(report['totalHours'])}'),
                  Text(
                      '${localizations.grossWage}: $currencySymbol${numberFormat.format(report['grossWage'])}'),
                  Text(
                      '${localizations.netWage}: $currencySymbol${numberFormat.format(report['netWage'])}'),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMonthlyReport() {
    final localizations = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final currencySymbol = _getCurrencySymbol(locale);
    final numberFormat = NumberFormat.decimalPattern(locale);

    return Consumer<AppState>(
      builder: (context, appState, child) {
        var monthlyReports = _generateMonthlyReports(appState);
        return ListView.builder(
          itemCount: monthlyReports.length,
          itemBuilder: (context, index) {
            var report = monthlyReports[index];
            return ExpansionTile(
              title: Text(report['month'],
                  style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${localizations.totalHours}: ${numberFormat.format(report['totalHours'])}'),
                      Text(
                          '${localizations.grossWage}: $currencySymbol${numberFormat.format(report['grossWage'])}'),
                      Text(
                          '${localizations.netWage}: $currencySymbol${numberFormat.format(report['netWage'])}'),
                      SizedBox(height: 8),
                      Text(localizations.wageBreakdown,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                          '${localizations.hoursAt100Percent}: ${numberFormat.format(report['wagePercentages']['100%'] ?? 0)}'),
                      Text(
                          '${localizations.hoursAt125Percent}: ${numberFormat.format(report['wagePercentages']['125%'] ?? 0)}'),
                      Text(
                          '${localizations.hoursAt150Percent}: ${numberFormat.format(report['wagePercentages']['150%'] ?? 0)}'),
                      Text(
                          '${localizations.hoursAt175Percent}: ${numberFormat.format(report['wagePercentages']['175%'] ?? 0)}'),
                      Text(
                          '${localizations.hoursAt200Percent}: ${numberFormat.format(report['wagePercentages']['200%'] ?? 0)}'),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _generateWeeklyReports(AppState appState) {
    var shifts = appState.shifts;
    shifts.sort((a, b) => a.date.compareTo(b.date));

    List<Map<String, dynamic>> weeklyReports = [];
    if (shifts.isEmpty) return weeklyReports;

    DateTime currentWeekStart =
        _getWeekStart(shifts.first.date, appState.startOnSunday);
    double totalHours = 0;
    double grossWage = 0;
    double netWage = 0;

    for (var shift in shifts) {
      if (shift.date.isAfter(currentWeekStart.add(Duration(days: 7)))) {
        // Save the current week's report
        weeklyReports.add({
          'startDate': DateFormat('MMM dd').format(currentWeekStart),
          'endDate': DateFormat('MMM dd')
              .format(currentWeekStart.add(Duration(days: 6))),
          'totalHours': totalHours,
          'grossWage': grossWage,
          'netWage': netWage,
        });

        // Start a new week
        currentWeekStart = _getWeekStart(shift.date, appState.startOnSunday);
        totalHours = 0;
        grossWage = 0;
        netWage = 0;
      }

      totalHours += shift.totalHours;
      grossWage += shift.grossWage;
      netWage += shift.netWage;
    }

    // Add the last week
    weeklyReports.add({
      'startDate': DateFormat('MMM dd').format(currentWeekStart),
      'endDate':
          DateFormat('MMM dd').format(currentWeekStart.add(Duration(days: 6))),
      'totalHours': totalHours,
      'grossWage': grossWage,
      'netWage': netWage,
    });

    return weeklyReports;
  }

  List<Map<String, dynamic>> _generateMonthlyReports(AppState appState) {
    var shifts = appState.shifts;
    shifts.sort((a, b) => a.date.compareTo(b.date));

    Map<String, Map<String, dynamic>> monthlyReports = {};

    for (var shift in shifts) {
      String monthKey = DateFormat('yyyy-MM').format(shift.date);
      String monthName = DateFormat('MMMM yyyy').format(shift.date);

      if (!monthlyReports.containsKey(monthKey)) {
        monthlyReports[monthKey] = {
          'month': monthName,
          'totalHours': 0.0,
          'grossWage': 0.0,
          'netWage': 0.0,
          'wagePercentages': {
            '100%': 0.0,
            '125%': 0.0,
            '150%': 0.0,
            '175%': 0.0,
            '200%': 0.0,
          },
        };
      }

      monthlyReports[monthKey]!['totalHours'] += shift.totalHours;
      monthlyReports[monthKey]!['grossWage'] += shift.grossWage;
      monthlyReports[monthKey]!['netWage'] += shift.netWage;

      for (var entry in shift.wagePercentages.entries) {
        monthlyReports[monthKey]!['wagePercentages']![entry.key] =
            (monthlyReports[monthKey]!['wagePercentages']![entry.key] ?? 0.0) +
                entry.value;
      }
    }

    return monthlyReports.values.toList()
      ..sort((a, b) => DateFormat('MMMM yyyy')
          .parse(a['month'])
          .compareTo(DateFormat('MMMM yyyy').parse(b['month'])));
  }

  DateTime _getWeekStart(DateTime date, bool startOnSunday) {
    int daysToSubtract =
        startOnSunday ? date.weekday % 7 : (date.weekday - 1) % 7;
    return date.subtract(Duration(days: daysToSubtract));
  }
}
