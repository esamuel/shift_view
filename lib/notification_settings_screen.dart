import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'app_state.dart';

class NotificationSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.notificationSettings),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(localizations.enableShiftReminders),
            value: appState.shiftRemindersEnabled,
            onChanged: (bool value) {
              appState.setShiftRemindersEnabled(value);
            },
          ),
          ListTile(
            title: Text(localizations.reminderTime),
            subtitle: Text('${appState.reminderMinutesBefore} ${localizations.minutesBefore}'),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _showReminderTimeDialog(context, appState, localizations),
            ),
          ),
          SwitchListTile(
            title: Text(localizations.enableEndShiftReminders),
            value: appState.endShiftRemindersEnabled,
            onChanged: (bool value) {
              appState.setEndShiftRemindersEnabled(value);
            },
          ),
        ],
      ),
    );
  }

  void _showReminderTimeDialog(BuildContext context, AppState appState, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int minutes = appState.reminderMinutesBefore;
        return AlertDialog(
          title: Text(localizations.setReminderTime),
          content: DropdownButton<int>(
            value: minutes,
            items: [5, 10, 15, 30, 60].map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text('$value ${localizations.minutes}'),
              );
            }).toList(),
            onChanged: (int? newValue) {
              if (newValue != null) {
                minutes = newValue;
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(localizations.save),
              onPressed: () {
                appState.setReminderMinutesBefore(minutes);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}