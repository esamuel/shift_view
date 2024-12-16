import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/overtime_rule.dart';
import '../services/shift_service.dart';

class OvertimeRulesScreen extends StatefulWidget {
  const OvertimeRulesScreen({Key? key}) : super(key: key);

  @override
  State<OvertimeRulesScreen> createState() => _OvertimeRulesScreenState();
}

class _OvertimeRulesScreenState extends State<OvertimeRulesScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _hoursThresholdController;
  late TextEditingController _rateController;
  bool _isForSpecialDays = false;
  bool _appliesOnWeekends = false;
  OvertimeRule? _editingRule;

  @override
  void initState() {
    super.initState();
    _hoursThresholdController = TextEditingController();
    _rateController = TextEditingController();
  }

  @override
  void dispose() {
    _hoursThresholdController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _hoursThresholdController.clear();
    _rateController.clear();
    setState(() {
      _isForSpecialDays = false;
      _appliesOnWeekends = false;
      _editingRule = null;
    });
  }

  void _editRule(OvertimeRule rule) {
    setState(() {
      _editingRule = rule;
      _hoursThresholdController.text = rule.hoursThreshold.toString();
      _rateController.text = rule.rate.toString();
      _isForSpecialDays = rule.isForSpecialDays;
      _appliesOnWeekends = rule.appliesOnWeekends;
    });
  }

  Future<void> _saveRule(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final shiftService = context.read<ShiftService>();
    final rule = OvertimeRule(
      id: _editingRule?.id ?? '',
      hoursThreshold: double.parse(_hoursThresholdController.text),
      rate: double.parse(_rateController.text),
      isForSpecialDays: _isForSpecialDays,
      appliesOnWeekends: _appliesOnWeekends,
    );

    try {
      if (_editingRule != null) {
        await shiftService.updateOvertimeRule(rule);
      } else {
        await shiftService.addOvertimeRule(rule);
      }
      _resetForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving rule: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overtime Rules'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ShiftService>().initializeDefaultOvertimeRules(),
            tooltip: 'Reset to Default Rules',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Consumer<ShiftService>(
                builder: (context, service, child) {
                  final rules = service.overtimeRules;
                  return ListView.builder(
                    itemCount: rules.length,
                    itemBuilder: (context, index) {
                      final rule = rules[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                            'Rate: ${(rule.rate * 100).toStringAsFixed(0)}% after ${rule.hoursThreshold}h',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            rule.isForSpecialDays
                                ? 'Special Days${rule.appliesOnWeekends ? ' & Weekends' : ''}'
                                : 'Regular Days',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editRule(rule),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Rule'),
                                      content: const Text('Are you sure you want to delete this rule?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await service.deleteOvertimeRule(rule.id);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(height: 32),
                  Text(
                    _editingRule != null ? 'Edit Rule' : 'Add New Rule',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _hoursThresholdController,
                          decoration: const InputDecoration(
                            labelText: 'Hours Threshold',
                            hintText: 'e.g., 8',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter hours threshold';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _rateController,
                          decoration: const InputDecoration(
                            labelText: 'Rate Multiplier',
                            hintText: 'e.g., 1.5',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter rate';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('Special Days'),
                          value: _isForSpecialDays,
                          onChanged: (value) {
                            setState(() {
                              _isForSpecialDays = value ?? false;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('Weekends'),
                          value: _appliesOnWeekends,
                          onChanged: (value) {
                            setState(() {
                              _appliesOnWeekends = value ?? false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_editingRule != null)
                        TextButton(
                          onPressed: _resetForm,
                          child: const Text('Cancel'),
                        ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () => _saveRule(context),
                        child: Text(_editingRule != null ? 'Update Rule' : 'Add Rule'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 