import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models/shift.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class UpcomingShiftsWidget extends StatelessWidget {
  const UpcomingShiftsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final localizations = AppLocalizations.of(context)!;

    List<Shift> upcomingShifts = appState.shifts;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  localizations.upcomingShifts,
                  style: Theme.of(context).textTheme.titleLarge, // Changed from headline6 to titleLarge
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (upcomingShifts.isEmpty)
              Text(localizations.noUpcomingShifts)
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: upcomingShifts.length,
                itemBuilder: (context, index) {
                  final shift = upcomingShifts[index];
                  return ListTile(
                    title: Text(shift.name),
                    subtitle: Text('${localizations.startsAt}: ${DateFormat.yMd().add_jm().format(shift.date)}'),
                    trailing: Text('${shift.duration} ${localizations.hours}'),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
