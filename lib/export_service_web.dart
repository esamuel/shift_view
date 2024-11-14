import 'dart:html' as html;
import 'dart:convert';

Future<String> createBackup(String jsonString) async {
  try {
    final bytes = utf8.encode(jsonString);
    final blob = html.Blob([bytes], 'application/json;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'shift_view_backup_${DateTime.now().toIso8601String()}.json';
    html.document.body!.children.add(anchor);

    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
    return url;
  } catch (e) {
    print('Error in web createBackup: $e');
    rethrow;
  }
}

Future<String> restoreBackup(String source) async {
  try {
    final input = html.FileUploadInputElement()
      ..accept = '.json,application/json';
    input.click();

    await input.onChange.first;
    if (input.files!.isEmpty) throw Exception('No file selected');

    final file = input.files!.first;
    if (!file.name.toLowerCase().endsWith('.json')) {
      throw Exception('Invalid file type. Please select a JSON file.');
    }

    final reader = html.FileReader();
    reader.readAsText(file);
    await reader.onLoad.first;

    final content = reader.result as String;
    // Validate JSON format
    json.decode(content); // This will throw if invalid JSON
    return content;
  } catch (e) {
    print('Error in web restoreBackup: $e');
    rethrow;
  }
}

Future<String> generateCSV(String csv) async {
  final blob = html.Blob([csv], 'text/csv', 'native');
  return html.Url.createObjectUrlFromBlob(blob);
}

Future<String> generatePDF(List<int> pdfBytes) async {
  final blob = html.Blob([pdfBytes], 'application/pdf', 'native');
  return html.Url.createObjectUrlFromBlob(blob);
}

Future<void> shareFile(String filePath, String subject) async {
  if (subject.contains('Backup')) {
    // For backup files, we don't need to do anything as createBackup handles the download
    return;
  }
  
  final extension = filePath.endsWith('.pdf') ? '.pdf' : '.csv';
  final filename = 'shift_report$extension';
  
  html.AnchorElement(href: filePath)
    ..setAttribute("download", filename)
    ..click();
}
