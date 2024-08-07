
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'settings_screen.dart';
import 'shift_manager_screen.dart';
import 'report_screen.dart';
import 'info_screen.dart';
import 'overtime_rules_screen.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            _buildButton(
              context,
              localizations.settingsTitle,
              Icons.settings,
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsScreen())),
            ),
            SizedBox(height: 16),
            _buildButton(
              context,
              localizations.shiftManagerTitle,
              Icons.work,
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ShiftManagerScreen())),
            ),
            SizedBox(height: 16),
            _buildButton(
              context,
              localizations.reportsTitle,
              Icons.bar_chart,
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ReportScreen())),
            ),
            SizedBox(height: 16),
            _buildButton(
              context,
              localizations.infoButtonTitle,
              Icons.info,
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => InfoScreen())),
            ),
            SizedBox(height: 16),
            _buildButton(
              context,
              localizations.overtimeRulesTitle,
              Icons.access_time,
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OvertimeRulesScreen())),
            ),
            SizedBox(height: 16),
            _buildButton(
              context,
              localizations.addToHomeScreen,
              Icons.add_to_home_screen,
              () => _showAddToHomeScreenDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String title, IconData icon,
      VoidCallback onPressed) {
    final colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        children: <Widget>[
          Icon(icon, size: 24.0),
          SizedBox(width: 16.0),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 18.0),
        ],
      ),
    );
  }

  void _showAddToHomeScreenDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.addToHomeScreenTitle),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(localizations.addToHomeScreeniOS),
                SizedBox(height: 16),
                Text(localizations.addToHomeScreenAndroid),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.ok),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
