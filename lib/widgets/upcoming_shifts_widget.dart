import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models/shift.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class UpcomingShiftsWidget extends StatelessWidget {
  const UpcomingShiftsWidget({Key? key}) : super(key: key);

  String _getLocalizedDayMonth(
      BuildContext context, DateTime date, AppLocalizations localizations) {
    String weekday;
    switch (date.weekday) {
      case DateTime.monday:
        weekday = localizations.monday_full;
        break;
      case DateTime.tuesday:
        weekday = localizations.tuesday_full;
        break;
      case DateTime.wednesday:
        weekday = localizations.wednesday_full;
        break;
      case DateTime.thursday:
        weekday = localizations.thursday_full;
        break;
      case DateTime.friday:
        weekday = localizations.friday_full;
        break;
      case DateTime.saturday:
        weekday = localizations.saturday_full;
        break;
      case DateTime.sunday:
        weekday = localizations.sunday_full;
        break;
      default:
        weekday = '';
    }

    final day = date.day.toString();
    final month = date.month.toString();
    return localizations.shiftDateFormat(weekday, day, month);
  }

  List<Shift> _getUpcomingShifts(List<Shift> allShifts) {
    final now = DateTime.now();
    final sixDaysFromNow = now.add(const Duration(days: 6));

    // Filter shifts that are from now to the next 6 days
    return allShifts.where((shift) {
      final shiftDate =
          DateTime(shift.date.year, shift.date.month, shift.date.day);
      final today = DateTime(now.year, now.month, now.day);
      return shiftDate.isAfter(today.subtract(const Duration(days: 1))) &&
          shiftDate.isBefore(sixDaysFromNow.add(const Duration(days: 1)));
    }).toList()
      // Sort by date in ascending order (closest dates first)
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final localizations = AppLocalizations.of(context);

    // Get upcoming shifts for the next 6 days
    final upcomingShifts = _getUpcomingShifts(appState.shifts);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  localizations.upcomingShifts,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (upcomingShifts.isEmpty)
              Text(localizations.noUpcomingShifts)
            else
              ...upcomingShifts.map((shift) => ListTile(
                    title: Text(_getLocalizedDayMonth(
                        context, shift.date, localizations)),
                    subtitle: Text(localizations.shiftTimeFormat(
                        DateFormat.jm().format(shift.startTime ?? shift.date),
                        DateFormat.jm().format(shift.endTime ?? shift.date),
                        shift.duration?.inHours.toString() ?? "0",
                        (shift.duration?.inMinutes.remainder(60) ?? 0)
                            .toString())),
                    trailing:
                        Text('${shift.totalHours} ${localizations.hours}'),
                  )),
          ],
        ),
      ),
    );
  }
}
