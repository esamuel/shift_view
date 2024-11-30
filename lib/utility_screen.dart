import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'app_state.dart';
import 'export_service.dart';
import 'package:file_picker/file_picker.dart';
import 'models/pdf_config.dart';

class UtilityScreen extends StatefulWidget {
  final List<Shift> shifts;
  final DateTime? selectedDate;

  const UtilityScreen({
    Key? key,
    required this.shifts,
    this.selectedDate,
  }) : super(key: key);

  @override
  _UtilityScreenState createState() => _UtilityScreenState();
}

class _UtilityScreenState extends State<UtilityScreen> {
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

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.utilities),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.backupAndRestore,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      alignment: WrapAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.backup, size: 20),
                          label: Text(localizations.backup),
                          onPressed: () => _createBackup(localizations),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.restore, size: 20),
                          label: Text(localizations.restore),
                          onPressed: () => _restoreBackup(localizations),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.export,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      alignment: WrapAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.description, size: 20),
                          label: Text(localizations.exportAsCsv),
                          onPressed: () => _exportReport('csv'),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.picture_as_pdf, size: 20),
                          label: Text(localizations.exportAsPdf),
                          onPressed: () => _exportReport('pdf'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
        SnackBar(content: Text("${localizations.backupError}: $e")),
      );
    }
  }

  void _restoreBackup(AppLocalizations localizations) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result != null) {
        String filePath = result.files.single.path!;
        await _exportService.restoreBackup(filePath);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.restoreSuccessful),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print("Error restoring backup: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${localizations.restoreError}: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _exportReport(String format) async {
    try {
      String filePath;
      if (format == 'csv') {
        filePath = await _exportService.generateCSV(widget.shifts);
      } else {
        final pdfConfig = PDFConfig(
          headerText: AppLocalizations.of(context)!.reportsTitle,
          includeDateRange: true,
          includePageNumbers: true,
        );

        filePath = await _exportService.generatePDF(
          widget.shifts,
          Provider.of<AppState>(context, listen: false),
          pdfConfig,
        );
      }
      await _exportService.shareFile(filePath, 'Shift Report');
    } catch (e) {
      print("Error exporting report: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Export failed: $e")),
      );
    }
  }
} 