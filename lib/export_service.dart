import 'models/shift.dart';
import 'models/pdf_config.dart';
import 'app_state.dart';

class ExportService {
  final AppState appState;

  ExportService(this.appState);

  Future<String> generatePDF(
    List<Shift> shifts,
    AppState appState,
    PDFConfig config,
  ) async {
    // Implement PDF generation logic here
    // Ensure to include detailed logging for wage calculations
    // and handle overnight shifts and special days properly
    print('Generating PDF with the following configuration:');
    print('Header: ${config.headerText}');
    print('Include Company Info: ${config.includeCompanyInfo}');
    print('Include Page Numbers: ${config.includePageNumbers}');
    print('Include Date Range: ${config.includeDateRange}');

    // Example of detailed logging for wage calculations
    for (var shift in shifts) {
      final totalHours = _calculateTotalHours(shift);
      final grossWage = _calculateGrossWage(shift, appState);
      print('Shift on ${shift.date}:');
      print('Total Hours: $totalHours');
      print('Gross Wage: $grossWage');
    }

    // Return the file path of the generated PDF
    return 'path/to/generated/pdf';
  }

  double _calculateTotalHours(Shift shift) {
    // Correct duration calculation for overnight shifts
    final start = DateTime(
      shift.date.year,
      shift.date.month,
      shift.date.day,
      shift.startTime?.hour ?? 0,
      shift.startTime?.minute ?? 0,
    );

    DateTime end = DateTime(
      shift.date.year,
      shift.date.month,
      shift.date.day,
      shift.endTime?.hour ?? 0,
      shift.endTime?.minute ?? 0,
    );

    if (end.isBefore(start)) {
      end = end.add(const Duration(days: 1));
    }

    return end.difference(start).inMinutes / 60.0;
  }

  double _calculateGrossWage(Shift shift, AppState appState) {
    final totalHours = _calculateTotalHours(shift);
    double wage = 0.0;

    // Properly applying rates for special days and regular days
    if (_isSpecialDay(shift.date)) {
      // Weekend/Special Day calculation
      if (totalHours <= 8.0) {
        wage = totalHours * appState.hourlyWage * 1.5;
      } else if (totalHours <= 10.0) {
        wage = 8.0 * appState.hourlyWage * 1.5;
        wage += (totalHours - 8.0) * appState.hourlyWage * 1.75;
      } else {
        wage = 8.0 * appState.hourlyWage * 1.5;
        wage += 2.0 * appState.hourlyWage * 1.75;
        wage += (totalHours - 10.0) * appState.hourlyWage * 2.0;
      }
    } else {
      // Regular Workday calculation
      if (totalHours <= 8.0) {
        wage = totalHours * appState.hourlyWage;
      } else if (totalHours <= 10.0) {
        wage = 8.0 * appState.hourlyWage;
        wage += (totalHours - 8.0) * appState.hourlyWage * 1.25;
      } else {
        wage = 8.0 * appState.hourlyWage;
        wage += 2.0 * appState.hourlyWage * 1.25;
        wage += (totalHours - 10.0) * appState.hourlyWage * 1.5;
      }
    }

    return wage;
  }

  bool _isSpecialDay(DateTime date) {
    // Check if the date is a Saturday or a festive day
    return date.weekday == DateTime.saturday || appState.festiveDays.contains(date);
  }

  Future<void> shareFile(String filePath, String fileName) async {
    // Implement file sharing logic here
  }
} 