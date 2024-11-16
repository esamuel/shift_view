import 'dart:html' as html;
import 'dart:convert';
import 'dart:async';

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
    final completer = Completer<String>();
    
    // Create file input element
    final input = html.FileUploadInputElement()
      ..accept = '.json,application/json'
      ..style.display = 'none';
    
    html.document.body!.children.add(input);

    // Handle file selection
    input.onChange.listen((event) async {
      if (input.files!.isEmpty) {
        html.document.body!.children.remove(input);
        completer.completeError('No file selected');
        return;
      }

      final file = input.files!.first;
      if (!file.name.toLowerCase().endsWith('.json')) {
        html.document.body!.children.remove(input);
        completer.completeError('Please select a JSON backup file');
        return;
      }

      final reader = html.FileReader();
      
      reader.onLoad.listen((event) {
        try {
          final content = reader.result as String;
          // Validate JSON format
          final jsonData = json.decode(content);
          if (jsonData == null || 
              !jsonData.containsKey('shifts') || 
              !jsonData.containsKey('settings')) {
            throw Exception('Invalid backup file format');
          }
          html.document.body!.children.remove(input);
          completer.complete(content);
        } catch (e) {
          html.document.body!.children.remove(input);
          completer.completeError('Invalid backup file: $e');
        }
      });

      reader.onError.listen((event) {
        html.document.body!.children.remove(input);
        completer.completeError('Error reading file: ${reader.error}');
      });

      try {
        reader.readAsText(file);
      } catch (e) {
        html.document.body!.children.remove(input);
        completer.completeError('Error reading file: $e');
      }
    });

    // Handle cancel
    input.onAbort.listen((event) {
      html.document.body!.children.remove(input);
      completer.completeError('File selection cancelled');
    });

    // Trigger file selection
    input.click();

    return await completer.future;
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
    return;
  }
  
  final extension = filePath.endsWith('.pdf') ? '.pdf' : '.csv';
  final filename = 'shift_report$extension';
  
  html.AnchorElement(href: filePath)
    ..setAttribute("download", filename)
    ..click();
}
