import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:your_app_name/app_state.dart';
import 'package:your_app_name/models/shift.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final localizations = AppLocalizations.of(context)!;

    print("Building HomeScreen");

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUpcomingShiftsCard(context, appState, localizations),
            // ... rest of your main screen content ...
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addShift(context, appState),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUpcomingShiftsCard(BuildContext context, AppState appState, AppLocalizations localizations) {
    print("Building Upcoming Shifts Card");
    final upcomingShifts = appState.getUpcomingShifts();
    print("Number of Upcoming Shifts: ${upcomingShifts.length}");

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.upcomingShifts,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (upcomingShifts.isEmpty)
              Text(localizations.noUpcomingShifts)
            else
              Column(
                children: upcomingShifts.map((shift) {
                  print("Displaying Shift ID: ${shift.id}");
                  return _buildShiftItem(context, shift, localizations);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftItem(BuildContext context, Shift shift, AppLocalizations localizations) {
    final dateFormat = DateFormat('EEE, MMM d');
    final timeFormat = DateFormat('HH:mm');

    // Convert TimeOfDay to DateTime for formatting
    DateTime startDateTime = DateTime(
      shift.date.year,
      shift.date.month,
      shift.date.day,
      shift.startTime.hour,
      shift.startTime.minute,
    );

    DateTime endDateTime = DateTime(
      shift.date.year,
      shift.date.month,
      shift.date.day,
      shift.endTime.hour,
      shift.endTime.minute,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(dateFormat.format(shift.date)),
          Text('${timeFormat.format(startDateTime)} - ${timeFormat.format(endDateTime)}'),
        ],
      ),
    );
  }

  void _addShift(BuildContext context, AppState appState) {
    // Implementation for adding a new shift
    // Ensure that after adding, shifts are saved and listeners are notified
    // For brevity, it's not included here
  }
}
