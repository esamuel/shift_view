import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../settings_screen.dart';
import '../shift_manager_screen.dart';
import '../report_screen.dart';
import '../info_screen.dart';
import '../overtime_rules_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                MaterialPageRoute(builder: (context) => const ShiftManagerScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _buildButton(
              context,
              localizations.reportsTitle,
              Icons.bar_chart,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _buildButton(
              context,
              localizations.infoButtonTitle,
              Icons.info,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InfoScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _buildButton(
              context,
              localizations.overtimeRulesTitle,
              Icons.access_time,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OvertimeRulesScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _buildButton(
              context,
              localizations.settingsTitle,
              Icons.settings,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String title, IconData icon,
      VoidCallback onPressed, {Color? color}) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? colorScheme.primary,
          foregroundColor: color != null ? colorScheme.onPrimary : colorScheme.onPrimary,
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
      ),
    );
  }

  void _showUpcomingShifts(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context, listen: false);
    final now = DateTime.now();
    final endDate = now.add(const Duration(days: 7));
    final upcomingShifts = appState.getShiftsBetweenDates(now, endDate);
    upcomingShifts.sort((a, b) => a.date.compareTo(b.date));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    localizations.upcomingShiftsTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: upcomingShifts.isEmpty
                        ? Center(child: Text(localizations.noUpcomingShifts))
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: upcomingShifts.length,
                            itemBuilder: (context, index) {
                              final shift = upcomingShifts[index];
                              return ListTile(
                                title: Text(_formatDate(shift.date)),
                                subtitle: Text(
                                  '${_formatTime(shift.startTime)} - ${_formatTime(shift.endTime)}',
                                ),
                              );
                            },
                          ),
                  ),
                  TextButton(
                    child: Text(localizations.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
