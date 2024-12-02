import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models/pdf_config.dart';
import '../export_service.dart';
import '../screens/pdf_config_screen.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Reports'),
            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                onPressed: () => _exportToPDF(context, appState),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Summary',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        Text('Total Hours: ${appState.totalHours.toStringAsFixed(2)}'),
                        Text(
                          'Total Earnings: ${appState.getCurrencySymbol()}${appState.totalEarnings.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Add more report sections here
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportToPDF(BuildContext context, AppState appState) async {
    try {
      // Create a default PDF config if none is provided
      final defaultConfig = PDFConfig(
        headerText: 'Shifts Report',
        includeCompanyInfo: true,
        includePageNumbers: true,
        includeDateRange: true,
      );

      // Get custom config from PDF config screen
      final customConfig = await Navigator.push<PDFConfig>(
        context,
        MaterialPageRoute(builder: (context) => PDFConfigScreen()),
      );

      // Use custom config if provided, otherwise use default
      final config = customConfig ?? defaultConfig;

      final exportService = ExportService(appState);
      final filePath = await exportService.generatePDF(
        appState.shifts,  // List<Shift>
        appState,         // AppState
        config,          // PDFConfig
      );

      if (filePath.isNotEmpty && context.mounted) {
        await exportService.shareFile(
          filePath,
          'Shifts Report.pdf',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting PDF: $e')),
        );
      }
    }
  }
} 