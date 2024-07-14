import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late double _hourlyWage;
  late double _taxDeduction;
  late bool _startOnSunday;
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _hourlyWage = appState.hourlyWage;
    _taxDeduction = appState.taxDeduction;
    _startOnSunday = appState.startOnSunday;
    _selectedLanguage = appState.locale.languageCode;
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final appState = Provider.of<AppState>(context, listen: false);
      appState.updateSettings(
        hourlyWage: _hourlyWage,
        taxDeduction: _taxDeduction,
        startOnSunday: _startOnSunday,
      );
      appState.setLocale(Locale(_selectedLanguage, ''));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settingsTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              initialValue: _hourlyWage.toString(),
              decoration: InputDecoration(
                labelText: localizations.hourlyWage,
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localizations.pleaseEnterYourHourlyWage;
                }
                if (double.tryParse(value) == null) {
                  return localizations.pleaseEnterAValidNumber;
                }
                return null;
              },
              onSaved: (value) => _hourlyWage = double.parse(value!),
            ),
            SizedBox(height: 16),
            TextFormField(
              initialValue: _taxDeduction.toString(),
              decoration: InputDecoration(
                labelText: localizations.taxDeduction,
                prefixIcon: Icon(Icons.percent),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localizations.pleaseEnterTaxDeductionPercentage;
                }
                final number = double.tryParse(value);
                if (number == null || number < 0 || number > 100) {
                  return localizations.pleaseEnterAValidPercentage;
                }
                return null;
              },
              onSaved: (value) => _taxDeduction = double.parse(value!),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text(localizations.startWorkWeekOnSunday),
              value: _startOnSunday,
              onChanged: (value) {
                setState(() {
                  _startOnSunday = value;
                });
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: InputDecoration(
                labelText: localizations.language,
                prefixIcon: Icon(Icons.language),
              ),
              items: [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'he', child: Text('עברית')),
                DropdownMenuItem(value: 'es', child: Text('Español')),
                DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                DropdownMenuItem(value: 'ru', child: Text('Русский')),
                DropdownMenuItem(value: 'fr', child: Text('Français')),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                }
              },
            ),
            SizedBox(height: 32),
            ElevatedButton(
              child: Text(localizations.saveSettings),
              onPressed: _saveSettings,
            ),
          ],
        ),
      ),
    );
  }
}
