import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../app_state.dart';
import '../models/shift.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({Key? key}) : super(key: key);

  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<Shift> _searchResults = [];

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    try {
      final now = DateTime.now();
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(2000),
        lastDate: DateTime(now.year + 5, 12, 31),
      );

      if (picked != null) {
        setState(() {
          if (isStartDate) {
            _startDate = picked;
            if (_endDate != null && _endDate!.isBefore(picked)) {
              _endDate = null;
            }
          } else {
            if (_startDate != null && picked.isBefore(_startDate!)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('End date must be after start date'),
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }
            _endDate = picked;
          }
        });

        if (_startDate != null && _endDate != null) {
          _search();
        }
      }
    } catch (e) {
      print('Error showing date picker: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error selecting date. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _search() {
    final appState = Provider.of<AppState>(context, listen: false);
    if (_startDate == null || _endDate == null) return;

    setState(() {
      _searchResults = appState.shifts.where((shift) {
        final shiftDate = DateTime(shift.date.year, shift.date.month, shift.date.day);
        final start = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
        final end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
        
        return (shiftDate.isAtSameMomentAs(start) || shiftDate.isAfter(start)) &&
               (shiftDate.isAtSameMomentAs(end) || shiftDate.isBefore(end));
      }).toList();

      _searchResults.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  Future<void> _generatePDF() async {
    if (_searchResults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No data to export'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      print('Starting PDF generation...');
      final pdf = pw.Document(
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
        ),
      );
      
      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(40),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Shifts Report',
                style: pw.TextStyle(
                  font: pw.Font.helvetica(),
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Period: ${DateFormat('MMM dd, yyyy').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}',
                style: pw.TextStyle(
                  font: pw.Font.helvetica(),
                  fontSize: 14
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                  4: const pw.FlexColumnWidth(3),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      pw.Text('Date', style: pw.TextStyle(
                        font: pw.Font.helvetica(),
                        fontWeight: pw.FontWeight.bold
                      )),
                      pw.Text('Start Time', style: pw.TextStyle(
                        font: pw.Font.helvetica(),
                        fontWeight: pw.FontWeight.bold
                      )),
                      pw.Text('End Time', style: pw.TextStyle(
                        font: pw.Font.helvetica(),
                        fontWeight: pw.FontWeight.bold
                      )),
                      pw.Text('Total Hours', style: pw.TextStyle(
                        font: pw.Font.helvetica(),
                        fontWeight: pw.FontWeight.bold
                      )),
                      pw.Text('Note', style: pw.TextStyle(
                        font: pw.Font.helvetica(),
                        fontWeight: pw.FontWeight.bold
                      )),
                    ].map((text) => pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      child: text,
                    )).toList(),
                  ),
                  ..._searchResults.map((shift) => pw.TableRow(
                    children: [
                      pw.Text(DateFormat('MMM dd, yyyy').format(shift.date),
                        style: pw.TextStyle(font: pw.Font.helvetica())),
                      pw.Text(shift.startTime != null ? DateFormat('HH:mm').format(shift.startTime!) : '--:--',
                        style: pw.TextStyle(font: pw.Font.helvetica())),
                      pw.Text(shift.endTime != null ? DateFormat('HH:mm').format(shift.endTime!) : '--:--',
                        style: pw.TextStyle(font: pw.Font.helvetica())),
                      pw.Text(shift.totalHours.toStringAsFixed(1),
                        style: pw.TextStyle(font: pw.Font.helvetica())),
                      pw.Text(shift.note ?? '',
                        style: pw.TextStyle(font: pw.Font.helvetica())),
                    ].map((text) => pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      alignment: pw.Alignment.centerLeft,
                      child: text,
                    )).toList(),
                  )),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'Total Hours: ${_searchResults.fold<double>(0.0, (sum, shift) => sum + shift.totalHours).toStringAsFixed(1)}',
                    style: pw.TextStyle(
                        font: pw.Font.helvetica(),
                        fontWeight: pw.FontWeight.bold
                      ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      print('Saving PDF...');
      final Uint8List pdfBytes = await pdf.save();
      print('PDF saved, size: ${pdfBytes.length} bytes');
      
      final String fileName = 'shifts_${DateFormat('yyyy_MM_dd').format(DateTime.now())}.pdf';
      print('Preparing to share file: $fileName');
      
      // Create a Blob containing the PDF data
      final blob = html.Blob([pdfBytes], 'application/pdf');
      
      // Create a URL for the Blob
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // Create an anchor element and trigger download
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..style.display = 'none';
      
      html.document.body?.children.add(anchor);
      anchor.click();
      
      // Clean up
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
      print('Download completed');
    } catch (e, stackTrace) {
      print('Error generating PDF: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: ${e.toString()}'),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalHours = 0;
    for (var shift in _searchResults) {
      totalHours += shift.totalHours;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Select Date Range',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => _selectDate(context, true),
                        child: Column(
                          children: [
                            const Text('Start Date'),
                            const SizedBox(height: 8),
                            Text(
                              _startDate != null 
                                ? DateFormat('MMM dd, yyyy').format(_startDate!)
                                : 'Select Start',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextButton(
                        onPressed: () => _selectDate(context, false),
                        child: Column(
                          children: [
                            const Text('End Date'),
                            const SizedBox(height: 8),
                            Text(
                              _endDate != null 
                                ? DateFormat('MMM dd, yyyy').format(_endDate!)
                                : 'Select End',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: (_startDate != null && _endDate != null) ? _search : null,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Text('Search', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
          if (_searchResults.isNotEmpty) ...[            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Results: ${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd').format(_endDate!)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Start Time')),
                        DataColumn(label: Text('End Time')),
                        DataColumn(label: Text('Total Hours')),
                        DataColumn(label: Text('Note')),
                      ],
                      rows: _searchResults.map((shift) => DataRow(cells: [
                        DataCell(Text(DateFormat('MMM dd, yyyy').format(shift.date))),
                        DataCell(Text(shift.startTime != null ? DateFormat('HH:mm').format(shift.startTime!) : '--:--')),
                        DataCell(Text(shift.endTime != null ? DateFormat('HH:mm').format(shift.endTime!) : '--:--')),
                        DataCell(Text(shift.totalHours.toStringAsFixed(1))),
                        DataCell(Text(shift.note ?? '')),
                      ])).toList(),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _generatePDF,
                    icon: const Icon(Icons.print),
                    label: const Text('Export to PDF'),
                  ),
                  Text(
                    'Total Hours: ${totalHours.toStringAsFixed(1)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
