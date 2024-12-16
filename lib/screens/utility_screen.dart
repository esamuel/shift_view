import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../export_service.dart';
import '../models/pdf_config.dart';
import 'pdf_config_screen.dart';

class UtilityScreen extends StatefulWidget {
  const UtilityScreen({super.key});

  @override
  _UtilityScreenState createState() => _UtilityScreenState();
}

class _UtilityScreenState extends State<UtilityScreen> {
  late ExportService _exportService;
  List<Shift> _filteredShifts = [];

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _exportService = ExportService(appState);
    _filteredShifts = appState.shifts;
  }

  Future<void> _exportToPDF() async {
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final config = await Navigator.push<PDFConfig>(
        context,
        MaterialPageRoute(builder: (context) => const PDFConfigScreen()),
      );

      if (config != null) {
        final filePath = await _exportService.generatePDF(
          _filteredShifts,
          appState,
          config,
        );
        
        if (filePath.isNotEmpty) {
          await _exportService.shareFile(
            filePath,
            'Shifts Report.pdf',
          );
        }
      }
    } catch (e) {
      if (mounted) {  // Check if widget is still mounted before showing SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Utilities'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ElevatedButton(
            onPressed: _exportToPDF,
            child: const Text('Export to PDF'),
          ),
          // Add other utility buttons here
        ],
      ),
    );
  }
} 