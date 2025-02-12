import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'settings_screen.dart';
import 'shift_manager_screen.dart';
import 'report_screen.dart';
import 'info_screen.dart';
import 'overtime_rules_screen.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'login_screen.dart';
import 'services/firebase_service.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final user = FirebaseService.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundImage:
                  user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null
                  ? Icon(Icons.person, color: colorScheme.onPrimary)
                  : null,
            ),
            onSelected: (value) async {
              if (value == 'add_account') {
                await FirebaseService.auth.signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                }
              } else if (value == 'sign_out') {
                await FirebaseService.auth.signOut();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                enabled: false,
                child: Text(
                  user?.email ?? 'No email',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'add_account',
                child: Row(
                  children: [
                    Icon(Icons.person_add),
                    SizedBox(width: 8),
                    Text('Add another account'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'sign_out',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Sign out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            _buildButton(
              context,
              localizations.upcomingShiftsTitle,
              Icons.calendar_today,
              () => _showUpcomingShifts(context),
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildButton(
              context,
              localizations.shiftManagerTitle,
              Icons.work,
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ShiftManagerScreen())),
            ),
            const SizedBox(height: 16),
            _buildButton(
              context,
              localizations.reportsTitle,
              Icons.bar_chart,
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ReportScreen())),
            ),
            const SizedBox(height: 16),
            _buildButton(
              context,
              localizations.infoButtonTitle,
              Icons.info,
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const InfoScreen())),
            ),
            const SizedBox(height: 16),
            _buildButton(
              context,
              localizations.overtimeRulesTitle,
              Icons.access_time,
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const OvertimeRulesScreen())),
            ),
            const SizedBox(height: 16),
            _buildButton(
              context,
              localizations.settingsTitle,
              Icons.settings,
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String title, IconData icon, VoidCallback onPressed,
      {Color? color}) {
    final colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? colorScheme.primary,
        foregroundColor:
            color != null ? colorScheme.onPrimary : colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        children: <Widget>[
          Icon(icon, size: 24.0),
          const SizedBox(width: 16.0),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 18.0),
        ],
      ),
    );
  }

  void _showAddToHomeScreenDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.addToHomeScreenTitle),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(localizations.addToHomeScreeniOS),
                const SizedBox(height: 16),
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

  void _showUpcomingShifts(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final appState = Provider.of<AppState>(context, listen: false);
    final now = DateTime.now();
    final endDate = now.add(const Duration(days: 7));
    final upcomingShifts = appState.getShiftsBetweenDates(now, endDate);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.upcomingShiftsTitle),
          content: SizedBox(
            width: double.maxFinite,
            child: upcomingShifts.isEmpty
                ? Center(child: Text(localizations.noUpcomingShifts))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: upcomingShifts.length,
                    itemBuilder: (BuildContext context, int index) {
                      final shift = upcomingShifts[index];
                      final duration = shift.startTime != null &&
                              shift.endTime != null
                          ? Duration(
                              hours:
                                  shift.endTime!.hour - shift.startTime!.hour,
                              minutes: shift.endTime!.minute -
                                  shift.startTime!.minute)
                          : const Duration();
                      final hours = duration.inHours;
                      final minutes = duration.inMinutes % 60;

                      return ListTile(
                        title: Text(localizations.shiftDateFormat(
                          _getDayName(context, shift.date.weekday),
                          shift.date.day.toString().padLeft(2, '0'),
                          shift.date.month.toString().padLeft(2, '0'),
                        )),
                        subtitle: Text(localizations.shiftTimeFormat(
                          shift.startTime != null
                              ? TimeOfDay(
                                      hour: shift.startTime!.hour,
                                      minute: shift.startTime!.minute)
                                  .format(context)
                              : '--:--',
                          shift.endTime != null
                              ? TimeOfDay(
                                      hour: shift.endTime!.hour,
                                      minute: shift.endTime!.minute)
                                  .format(context)
                              : '--:--',
                          hours.toString(),
                          minutes.toString(),
                        )),
                      );
                    },
                  ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.upcomingShiftsClose),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _getDayName(BuildContext context, int weekday) {
    final localizations = AppLocalizations.of(context);
    switch (weekday) {
      case 1:
        return localizations.mon;
      case 2:
        return localizations.tue;
      case 3:
        return localizations.wed;
      case 4:
        return localizations.thu;
      case 5:
        return localizations.fri;
      case 6:
        return localizations.sat;
      case 7:
        return localizations.sun;
      default:
        return '';
    }
  }
}
