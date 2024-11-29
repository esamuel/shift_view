import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          double totalHours = 0;
          double totalEarnings = 0;
          
          for (var shift in appState.shifts) {
            totalHours += shift.totalHours;
            totalEarnings += shift.grossWage;
          }
          
          return Padding(
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
                        Text('Total Hours: ${totalHours.toStringAsFixed(2)}'),
                        Text(
                          'Total Earnings: ${appState.getCurrencySymbol()}${totalEarnings.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 