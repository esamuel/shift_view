import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class ShiftManagerScreen extends StatelessWidget {
  const ShiftManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Shifts'),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return ListView.builder(
            itemCount: appState.shifts.length,
            itemBuilder: (context, index) {
              final shift = appState.shifts[index];
              return ListTile(
                title: Text('Shift on ${shift.date.toString().split(' ')[0]}'),
                subtitle: Text(
                  'Hours: ${shift.totalHours.toStringAsFixed(2)} - Wage: ${appState.getCurrencySymbol()}${shift.grossWage.toStringAsFixed(2)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => appState.deleteShift(index),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add shift functionality
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 