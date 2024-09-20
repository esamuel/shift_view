import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../app_state.dart';
import '../models/shift.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ShiftManagerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final localizations = AppLocalizations.of(context)!;
    final upcomingShifts = appState.upcomingShifts;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.shiftManagerTitle),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upcoming Shifts Section
          if (upcomingShifts.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                localizations.upcomingShifts,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: upcomingShifts.length,
                itemBuilder: (context, index) {
                  final shift = upcomingShifts[index];
                  return ListTile(
                    leading: Icon(Icons.event),
                    title: Text(DateFormat.yMMMd().format(shift.date)),
                    subtitle: Text('${shift.startTime.format(context)} - ${shift.endTime.format(context)}'),
                    trailing: Text('${shift.totalHours.toStringAsFixed(2)} ${localizations.hours}'),
                  );
                },
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                localizations.noUpcomingShifts,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
          ],

          // Existing Shifts Section (if you have one)
          // ...

          // Add New Shift Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to Add Shift Screen or show Add Shift Dialog
              },
              child: Text(localizations.addNewShift),
            ),
          ),
        ],
      ),
    );
  }
}