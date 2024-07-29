import 'dart:html' as html;

Future<String> createBackup(String jsonString) async {
  final blob = html.Blob([jsonString], 'text/plain', 'native');
  return html.Url.createObjectUrlFromBlob(blob);
}

Future<String> restoreBackup(String source) async {
  final response = await html.HttpRequest.request(source, responseType: 'text');
  return response.responseText!;
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
  html.AnchorElement(href: filePath)
    ..setAttribute("download",
        "shift_report${filePath.endsWith('.pdf') ? '.pdf' : '.csv'}")
    ..click();
}
