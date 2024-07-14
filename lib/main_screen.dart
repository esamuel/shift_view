import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'settings_screen.dart';
import 'shift_manager_screen.dart';
import 'report_screen.dart';
import 'info_screen.dart';

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
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
          children: <Widget>[
            _buildButton(
              context,
              localizations.settingsTitle,
              Icons.settings,
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsScreen())),
            ),
            _buildButton(
              context,
              localizations.shiftManagerTitle,
              Icons.work,
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ShiftManagerScreen())),
            ),
            _buildButton(
              context,
              localizations.reportsTitle,
              Icons.bar_chart,
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ReportScreen())),
            ),
            _buildButton(
              context,
              localizations.infoButtonTitle,
              Icons.info,
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => InfoScreen())),
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
        padding: EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 48.0),
          SizedBox(height: 8.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}
