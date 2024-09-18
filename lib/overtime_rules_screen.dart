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
      body: ListView.builder(
        itemCount: appState.overtimeRules.length,
        itemBuilder: (context, index) {
          final rule = appState.overtimeRules[index];
          return ListTile(
            title: Text('${localizations.afterHours(rule.hoursThreshold.toString())}: ${(rule.rate * 100).toInt()}%'),
            subtitle: Text(rule.isForSpecialDays ? localizations.specialDays : localizations.weekdays),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                appState.deleteOvertimeRule(index);
                appState.saveOvertimeRules();
              },
            ),
            onTap: () => _editOvertimeRule(context, appState, index, rule),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOvertimeRule(context, appState),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addOvertimeRule(BuildContext context, AppState appState) {
    final localizations = AppLocalizations.of(context)!;
    final TextEditingController hoursThresholdController = TextEditingController();
    final TextEditingController rateController = TextEditingController();
    bool isForSpecialDays = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.addOvertimeRule),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: hoursThresholdController,
                  decoration: InputDecoration(labelText: localizations.hoursThreshold),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: rateController,
                  decoration: InputDecoration(labelText: localizations.rate),
                  keyboardType: TextInputType.number,
                ),
                SwitchListTile(
                  title: Text(localizations.appliesOnSpecialDays),
                  value: isForSpecialDays,
                  onChanged: (bool value) {
                    isForSpecialDays = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(localizations.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(localizations.save),
              onPressed: () {
                if (hoursThresholdController.text.isNotEmpty && rateController.text.isNotEmpty) {
                  appState.addOvertimeRule(OvertimeRule(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    hoursThreshold: double.parse(hoursThresholdController.text),
                    rate: double.parse(rateController.text),
                    isForSpecialDays: isForSpecialDays,
                  ));
                  appState.saveOvertimeRules();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _editOvertimeRule(BuildContext context, AppState appState, int index, OvertimeRule rule) {
    final localizations = AppLocalizations.of(context)!;
    final TextEditingController hoursThresholdController = TextEditingController(text: rule.hoursThreshold.toString());
    final TextEditingController rateController = TextEditingController(text: rule.rate.toString());
    bool isForSpecialDays = rule.isForSpecialDays;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.editOvertimeRule),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: hoursThresholdController,
                  decoration: InputDecoration(labelText: localizations.hoursThreshold),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: rateController,
                  decoration: InputDecoration(labelText: localizations.rate),
                  keyboardType: TextInputType.number,
                ),
                SwitchListTile(
                  title: Text(localizations.appliesOnSpecialDays),
                  value: isForSpecialDays,
                  onChanged: (bool value) {
                    isForSpecialDays = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(localizations.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(localizations.save),
              onPressed: () {
                if (hoursThresholdController.text.isNotEmpty && rateController.text.isNotEmpty) {
                  appState.updateOvertimeRule(
                    index,
                    OvertimeRule(
                      id: rule.id,
                      hoursThreshold: double.parse(hoursThresholdController.text),
                      rate: double.parse(rateController.text),
                      isForSpecialDays: isForSpecialDays,
                    ),
                  );
                  appState.saveOvertimeRules();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
