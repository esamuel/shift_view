import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<String> createBackup(String jsonString) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/shift_view_backup.json');
  await file.writeAsString(jsonString);
  return file.path;
}

Future<String> restoreBackup(String source) async {
  final file = File(source);
  return await file.readAsString();
}

Future<String> generateCSV(String csv) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/shifts_report.csv');
  await file.writeAsString(csv);
  return file.path;
}

Future<String> generatePDF(List<int> pdfBytes) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/shifts_report.pdf');
  await file.writeAsBytes(pdfBytes);
  return file.path;
}

Future<void> shareFile(String filePath, String subject) async {
  await Share.shareFiles([filePath], subject: subject);
}
