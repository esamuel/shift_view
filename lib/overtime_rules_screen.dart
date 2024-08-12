import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'app_state.dart';

class OvertimeRulesScreen extends StatelessWidget {
  const OvertimeRulesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.overtimeRulesTitle),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(localizations.baseHoursWeekday),
            subtitle:
                Text('${appState.baseHoursWeekday} ${localizations.hours}'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () =>
                  _editBaseHours(context, appState, isWeekday: true),
            ),
          ),
          ListTile(
            title: Text(localizations.baseHoursSpecialDay),
            subtitle:
                Text('${appState.baseHoursSpecialDay} ${localizations.hours}'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () =>
                  _editBaseHours(context, appState, isWeekday: false),
            ),
          ),
          const Divider(),
          ...appState.overtimeRules.asMap().entries.map((entry) {
            final index = entry.key;
            final rule = entry.value;
            return ListTile(
              title: Text(
                  '${localizations.afterHours(rule.hoursThreshold.toString())} @ ${rule.rate}x'),
              subtitle: Text(rule.isForSpecialDays
                  ? localizations.specialDays
                  : localizations.weekdays),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () =>
                        _editOvertimeRule(context, appState, index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => appState.deleteOvertimeRule(index),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _addOvertimeRule(context, appState),
      ),
    );
  }

  void _addOvertimeRule(BuildContext context, AppState appState) {
    _showOvertimeRuleDialog(context, appState);
  }

  void _editOvertimeRule(BuildContext context, AppState appState, int index) {
    _showOvertimeRuleDialog(context, appState,
        existingRule: appState.overtimeRules[index], index: index);
  }

  void _showOvertimeRuleDialog(BuildContext context, AppState appState,
      {OvertimeRule? existingRule, int? index}) {
    final localizations = AppLocalizations.of(context)!;
    double hoursThreshold = existingRule?.hoursThreshold ?? 8;
    double rate = existingRule?.rate ?? 1.5;
    bool isForSpecialDays = existingRule?.isForSpecialDays ?? false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(existingRule == null
                  ? localizations.addOvertimeRule
                  : localizations.editOvertimeRule),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: hoursThreshold.toString(),
                    decoration: InputDecoration(
                        labelText: localizations.hoursThreshold),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) => hoursThreshold =
                        double.tryParse(value) ?? hoursThreshold,
                  ),
                  TextFormField(
                    initialValue: rate.toString(),
                    decoration: InputDecoration(labelText: localizations.rate),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) => rate = double.tryParse(value) ?? rate,
                  ),
                  SwitchListTile(
                    title: Text(localizations.isForSpecialDays),
                    value: isForSpecialDays,
                    onChanged: (value) =>
                        setState(() => isForSpecialDays = value),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text(localizations.cancel),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text(localizations.save),
                  onPressed: () {
                    final rule = OvertimeRule(
                      id: existingRule?.id ?? DateTime.now().toIso8601String(),
                      hoursThreshold: hoursThreshold,
                      rate: rate,
                      isForSpecialDays: isForSpecialDays,
                    );
                    if (existingRule == null) {
                      appState.addOvertimeRule(rule);
                    } else {
                      appState.updateOvertimeRule(index!, rule);
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editBaseHours(BuildContext context, AppState appState,
      {required bool isWeekday}) {
    final localizations = AppLocalizations.of(context)!;
    final currentValue =
        isWeekday ? appState.baseHoursWeekday : appState.baseHoursSpecialDay;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        double newValue = currentValue;
        return AlertDialog(
          title: Text(isWeekday
              ? localizations.baseHoursWeekday
              : localizations.baseHoursSpecialDay),
          content: TextFormField(
            initialValue: currentValue.toString(),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) =>
                newValue = double.tryParse(value) ?? currentValue,
          ),
          actions: [
            TextButton(
              child: Text(localizations.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(localizations.save),
              onPressed: () {
                if (isWeekday) {
                  appState.baseHoursWeekday = newValue;
                } else {
                  appState.baseHoursSpecialDay = newValue;
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
