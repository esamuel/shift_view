import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'app_state.dart';
import 'export_service.dart';
import 'package:file_picker/file_picker.dart';
import 'models/pdf_config.dart';
import 'utils/font_loader.dart';
import 'package:intl/intl.dart';

class UtilityScreen extends StatefulWidget {
  final List<Shift> shifts;
  final DateTime? selectedDate;
  final String viewType;

  const UtilityScreen({
    super.key,
    required this.shifts,
    required this.viewType,
    this.selectedDate,
  });

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
        SnackBar(
          content: Text(localizations.backupCreated),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      print("Error creating backup: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${localizations.backupError}: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
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
        await _exportService.restoreBackup();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.restoreSuccessful),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print("Error restoring backup: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${localizations.restoreError}: ${e.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _exportReport(String format) async {
    try {
      String dateRangeTitle = _getDateRangeTitle();
      
      String filePath;
      if (format == 'csv') {
        filePath = await _exportService.generateCSV(widget.shifts);
      } else {
        final fonts = await FontLoader.loadFonts();
        
        final pdfConfig = PDFConfig(
          headerText: '${AppLocalizations.of(context)!.reportsTitle} - $dateRangeTitle',
          includeDateRange: true,
          includePageNumbers: true,
          font: fonts.regular,
          boldFont: fonts.bold,
        );

        filePath = await _exportService.generatePDF(
          widget.shifts,
          Provider.of<AppState>(context, listen: false),
          pdfConfig,
        );
      }

      String fileName = _generateFileName(format);
      await _exportService.shareFile(filePath, fileName);
    } catch (e) {
      print("Error exporting report: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Export failed: $e")),
        );
      }
    }
  }

  String _getDateRangeTitle() {
    final localizations = AppLocalizations.of(context)!;
    if (widget.viewType == 'weekly') {
      final weekStart = widget.selectedDate ?? DateTime.now();
      final weekEnd = weekStart.add(const Duration(days: 6));
      return '${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d, yyyy').format(weekEnd)}';
    } else {
      final month = widget.selectedDate ?? DateTime.now();
      return DateFormat('MMMM yyyy').format(month);
    }
  }

  String _generateFileName(String format) {
    final dateStr = widget.selectedDate != null 
        ? DateFormat('yyyy-MM-dd').format(widget.selectedDate!)
        : DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    final viewTypeStr = widget.viewType == 'weekly' ? 'Weekly' : 'Monthly';
    return 'Shifts_${viewTypeStr}_$dateStr.$format';
  }
} 