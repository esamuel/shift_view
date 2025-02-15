import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<ReportItem> _searchResults = [];

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _search() {
    // TODO: Implement the actual search logic here
    // This is just a placeholder
    setState(() {
      _searchResults = [
        ReportItem(
            startHour: DateTime.now(),
            endHour: DateTime.now().add(const Duration(hours: 8)),
            totalHourWorked: 8,
            workedHours: 8,
            grossWage: 160,
            netWage: 120),
        ReportItem(
            startHour: DateTime.now(),
            endHour: DateTime.now().add(const Duration(hours: 8)),
            totalHourWorked: 8,
            workedHours: 8,
            grossWage: 160,
            netWage: 120),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).reportsTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate ?? DateTime.now())}'),
                    ElevatedButton(
                      onPressed: () => _selectDate(context, true),
                      child: const Text('Select Start Date'),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text('End Date: ${DateFormat('yyyy-MM-dd').format(_endDate  ?? DateTime.now())}'),
                    ElevatedButton(
                      onPressed: () => _selectDate(context, false),
                      child: const Text('Select End Date'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _search,
              child: const Text('Search'),
            ),
            const SizedBox(height: 20),
            Text('Search Result for date: ${_startDate != null && _endDate != null ? "${DateFormat('yyyy-MM-dd').format(_startDate!)} - ${DateFormat('yyyy-MM-dd').format(_endDate!)}" : ""}',),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Start Hour')),
                    DataColumn(label: Text('End Hour')),
                    DataColumn(label: Text('Total Hour Worked')),
                    DataColumn(label: Text('Worked Hours')),
                    DataColumn(label: Text('Gross Wage')),
                    DataColumn(label: Text('Net Wage')),
                  ],
                  rows: _searchResults.map((item) => DataRow(cells: [
                    DataCell(Text(DateFormat('HH:mm').format(item.startHour))),
                    DataCell(Text(DateFormat('HH:mm').format(item.endHour))),
                    DataCell(Text(item.totalHourWorked.toString())),
                    DataCell(Text(item.workedHours.toString())),
                    DataCell(Text(item.grossWage.toString())),
                    DataCell(Text(item.netWage.toString())),
                  ])).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportItem {
  final DateTime startHour;
  final DateTime endHour;
  final double totalHourWorked;
  final double workedHours;
  final double grossWage;
  final double netWage;

  ReportItem({
    required this.startHour,
    required this.endHour,
    required this.totalHourWorked,
    required this.workedHours,
    required this.grossWage,
    required this.netWage,
  });
}