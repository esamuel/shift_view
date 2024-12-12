import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'app_state.dart';
import 'overtime_rules_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _hourlyWageController;
  late TextEditingController _taxDeductionController;
  late TextEditingController _baseHoursWeekdayController;
  late TextEditingController _baseHoursSpecialDayController;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _hourlyWageController = TextEditingController(text: appState.hourlyWage.toString());
    _taxDeductionController = TextEditingController(text: appState.taxDeduction.toString());
    _baseHoursWeekdayController = TextEditingController(text: appState.baseHoursWeekday.toString());
    _baseHoursSpecialDayController = TextEditingController(text: appState.baseHoursSpecialDay.toString());
  }

  @override
  void dispose() {
    _hourlyWageController.dispose();
    _taxDeductionController.dispose();
    _baseHoursWeekdayController.dispose();
    _baseHoursSpecialDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildNumberInput(
            controller: _hourlyWageController,
            label: localizations.hourlyWage,
            prefixText: appState.getCurrencySymbol(),
          ),
          const SizedBox(height: 16),
          _buildNumberInput(
            controller: _taxDeductionController,
            label: localizations.taxDeduction,
            suffixText: '%',
          ),
          const SizedBox(height: 16),
          _buildNumberInput(
            controller: _baseHoursWeekdayController,
            label: localizations.baseHoursWeekday,
          ),
          const SizedBox(height: 16),
          _buildNumberInput(
            controller: _baseHoursSpecialDayController,
            label: localizations.baseHoursSpecialDay,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(appState.startOnSunday ? 'Start work on Sunday' : 'Start work on Monday'),
            value: appState.startOnSunday,
            onChanged: (value) {
              setState(() {
                appState.startOnSunday = value;
              });
            },
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: appState.isDarkMode,
            onChanged: (value) {
              appState.toggleDarkMode();
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: localizations.language),
            value: appState.locale.languageCode,
            items: const [
              DropdownMenuItem(child: Text('English'), value: 'en'),
              DropdownMenuItem(child: Text('Español'), value: 'es'),
              DropdownMenuItem(child: Text('Français'), value: 'fr'),
              DropdownMenuItem(child: Text('Deutsch'), value: 'de'),
              DropdownMenuItem(child: Text('עברית'), value: 'he'),
              DropdownMenuItem(child: Text('Русский'), value: 'ru'),
            ],
            onChanged: (value) {
              if (value != null) {
                appState.setLocale(Locale(value));
              }
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: localizations.country),
            value: appState.countryCode,
            items: [
              DropdownMenuItem(child: Text(localizations.countryUS), value: 'US'),
              DropdownMenuItem(child: Text(localizations.countryGB), value: 'GB'),
              DropdownMenuItem(child: Text(localizations.countryEU), value: 'EU'),
              DropdownMenuItem(child: Text(localizations.countryJP), value: 'JP'),
              DropdownMenuItem(child: Text(localizations.countryIL), value: 'IL'),
              DropdownMenuItem(child: Text(localizations.countryRU), value: 'RU'),
            ],
            onChanged: (value) {
              if (value != null) {
                appState.setCountry(value);
              }
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            child: Text(localizations.manageOvertimeRules),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OvertimeRulesScreen()),
              );
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            child: Text(localizations.saveSettings),
            onPressed: () {
              appState.updateSettings(
                hourlyWage: double.parse(_hourlyWageController.text),
                taxDeduction: double.parse(_taxDeductionController.text),
                startOnSunday: appState.startOnSunday,
              );
              appState.updateBaseHours(
                weekday: double.parse(_baseHoursWeekdayController.text),
                specialDay: double.parse(_baseHoursSpecialDayController.text),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInput({
    required TextEditingController controller,
    required String label,
    String? prefixText,
    String? suffixText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        suffixText: suffixText,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );
  }
}