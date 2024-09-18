// Part 1: Imports and class declaration
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'app_state.dart';
import 'dart:math' as Math;

class ShiftManagerScreen extends StatefulWidget {
  const ShiftManagerScreen({Key? key}) : super(key: key);

  @override
  _ShiftManagerScreenState createState() => _ShiftManagerScreenState();
}

// Part 2: State class and variables
class _ShiftManagerScreenState extends State<ShiftManagerScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  bool _showCurrentMonthOnly = true;
  String notes = '';

// Part 3: Build method
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.shiftManagerTitle),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizations.addNewShift,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                _buildButton(
                  context,
                  '${localizations.selectDate}: ${DateFormat('dd-MM-yyyy').format(_selectedDate)}',
                  () => _selectDate(context),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildButton(
                        context,
                        '${localizations.startTime}: ${_formatTime(_startTime)}',
                        () => _selectTime(context, true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildButton(
                        context,
                        '${localizations.endTime}: ${_formatTime(_endTime)}',
                        () => _selectTime(context, false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildButton(context, localizations.addShift, _addShift),
                const SizedBox(height: 32),
                Text(localizations.existingShifts,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _showCurrentMonthOnly
                            ? localizations.currentMonth
                            : localizations.allShifts,
                      ),
                    ),
                    Switch(
                      value: _showCurrentMonthOnly,
                      onChanged: (value) {
                        setState(() {
                          _showCurrentMonthOnly = value;
                        });
                      },
                      activeColor: colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildShiftsList(appState, localizations),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, VoidCallback onPressed) {
    final colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton(
      child: Text(text, textAlign: TextAlign.center),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        minimumSize: const Size(double.infinity, 36),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildShiftsList(AppState appState, AppLocalizations localizations) {
    List<Shift> shiftsToShow = _showCurrentMonthOnly
        ? _getCurrentMonthShifts(appState.shifts)
        : appState.shifts;
    shiftsToShow.sort((b, a) => a.date.compareTo(b.date));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shiftsToShow.length,
      itemBuilder: (context, index) {
        final shift = shiftsToShow[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getLocalizedDayMonth(context, shift.date),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${localizations.startTime}: ${_formatTime(shift.startTime)} - ${localizations.endTime}: ${_formatTime(shift.endTime)}',
                ),
                Text(
                  '${localizations.totalHours}: ${shift.totalHours.toStringAsFixed(2)}',
                ),
                Text(
                  '${localizations.grossWage}: ${appState.getCurrencySymbol()}${shift.grossWage.toStringAsFixed(2)}',
                ),
                Text(
                  '${localizations.netWage}: ${appState.getCurrencySymbol()}${shift.netWage.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editShift(context, appState, shift),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteShift(context, appState, shift),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
// Part 5: Date and time selection methods
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

// Part 6: Shift management methods
  void _addShift() {
    final appState = Provider.of<AppState>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.addNewShift),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildButton(
                  context,
                  '${localizations.selectDate}: ${DateFormat('dd-MM-yyyy').format(_selectedDate)}',
                  () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildButton(
                        context,
                        '${localizations.startTime}: ${_formatTime(_startTime)}',
                        () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: _startTime,
                          );
                          if (picked != null) {
                            setState(() {
                              _startTime = picked;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildButton(
                        context,
                        '${localizations.endTime}: ${_formatTime(_endTime)}',
                        () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: _endTime,
                          );
                          if (picked != null) {
                            setState(() {
                              _endTime = picked;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(labelText: localizations.shiftNotes),
                  onChanged: (value) => notes = value,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
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
              child: Text(localizations.addShift),
              onPressed: () {
                final totalHours = _calculateTotalHours(_selectedDate, _startTime, _endTime);
                final grossWage = _calculateGrossWage(appState, _selectedDate, _startTime, _endTime);
                final netWage = _calculateNetWage(grossWage, appState.taxDeduction);
                final wagePercentages = _calculateWagePercentages(appState, _selectedDate, _startTime, _endTime);

                final newShift = Shift(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  date: _selectedDate,
                  startTime: _startTime,
                  endTime: _endTime,
                  totalHours: totalHours,
                  grossWage: grossWage,
                  netWage: netWage,
                  wagePercentages: wagePercentages,
                  notes: notes,
                );

                bool isDuplicate = appState.shifts.any((shift) =>
                    shift.date.year == newShift.date.year &&
                    shift.date.month == newShift.date.month &&
                    shift.date.day == newShift.date.day &&
                    shift.startTime.hour == newShift.startTime.hour &&
                    shift.startTime.minute == newShift.startTime.minute &&
                    shift.endTime.hour == newShift.endTime.hour &&
                    shift.endTime.minute == newShift.endTime.minute);

                if (isDuplicate) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizations.shiftAlreadySaved)),
                  );
                } else {
                  appState.addShift(newShift);
                  appState.saveShifts(); // Save changes immediately
                  Navigator.of(context).pop();
                  setState(() {}); // Trigger a rebuild to show the new shift
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizations.shiftAddedSuccessfully)),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _editShift(BuildContext context, AppState appState, Shift shift) async {
    print("Editing shift with ID: ${shift.id}");
    DateTime editDate = shift.date;
    TimeOfDay editStartTime = shift.startTime;
    TimeOfDay editEndTime = shift.endTime;
    String notes = shift.notes;

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.editShift),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.selectDate),
                      subtitle: Text(DateFormat('yyyy-MM-dd').format(editDate)),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: editDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            editDate = picked;
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.startTime),
                      subtitle: Text(editStartTime.format(context)),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: editStartTime,
                        );
                        if (picked != null) {
                          setState(() {
                            editStartTime = picked;
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.endTime),
                      subtitle: Text(editEndTime.format(context)),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: editEndTime,
                        );
                        if (picked != null) {
                          setState(() {
                            editEndTime = picked;
                          });
                        }
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.shiftNotes),
                      controller: TextEditingController(text: notes),
                      onChanged: (value) => notes = value,
                      maxLines: null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text(AppLocalizations.of(context)!.cancel),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text(AppLocalizations.of(context)!.save),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      print("Updating shift...");
      final totalHours = _calculateTotalHours(editDate, editStartTime, editEndTime);
      final grossWage = _calculateGrossWage(appState, editDate, editStartTime, editEndTime);
      final netWage = _calculateNetWage(grossWage, appState.taxDeduction);
      final wagePercentages = _calculateWagePercentages(appState, editDate, editStartTime, editEndTime);

      final updatedShift = Shift(
        id: shift.id,
        date: editDate,
        startTime: editStartTime,
        endTime: editEndTime,
        totalHours: totalHours,
        grossWage: grossWage,
        netWage: netWage,
        wagePercentages: wagePercentages,
        notes: notes,
      );

      print("Updated shift: $updatedShift");
      appState.updateShift(shift.id, updatedShift);
      print("Shift updated");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.shiftUpdatedSuccessfully)),
      );
    } else {
      print("Edit cancelled");
    }
  }

  void _deleteShift(BuildContext context, AppState appState, Shift shift) {
    print("Attempting to delete shift with ID: ${shift.id}");
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deleteShift),
          content: Text(AppLocalizations.of(context)!.deleteShiftConfirmation),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.delete),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        print("Deleting shift...");
        appState.deleteShift(shift.id);
        print("Shift deleted");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.shiftDeletedSuccessfully)),
        );
      } else {
        print("Deletion cancelled");
      }
    });
  }

// Part 7: Calculation methods
  Shift _createShift(AppState appState) {
    final totalHours = _calculateTotalHours(_selectedDate, _startTime, _endTime);
    final grossWage = _calculateGrossWage(appState, _selectedDate, _startTime, _endTime);
    final netWage = _calculateNetWage(grossWage, appState.taxDeduction);
    final wagePercentages = _calculateWagePercentages(appState, _selectedDate, _startTime, _endTime);

    return Shift(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _selectedDate,
      startTime: _startTime,
      endTime: _endTime,
      totalHours: totalHours,
      grossWage: grossWage,
      netWage: netWage,
      wagePercentages: wagePercentages,
      notes: notes,
    );
  }

  // Part 7: Calculation methods (continued)
  double _calculateTotalHours(DateTime date, TimeOfDay startTime, TimeOfDay endTime) {
    final startDateTime = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);
    var endDateTime = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);

    if (endDateTime.isBefore(startDateTime)) {
      endDateTime = endDateTime.add(const Duration(days: 1));
    }

    return endDateTime.difference(startDateTime).inMinutes / 60.0;
  }

  double _calculateGrossWage(AppState appState, DateTime date, TimeOfDay startTime, TimeOfDay endTime) {
    final totalHours = _calculateTotalHours(date, startTime, endTime);
    final hourlyWage = appState.hourlyWage;
    final isWeekend = _isWeekend(appState, date);
    final isFestiveDay = _isFestiveDay(appState, date);
    final isSpecialDay = isWeekend || isFestiveDay;

    double wage = 0;
    double remainingHours = totalHours;

    // Determine base hours and base rate
    final baseHours = isSpecialDay ? appState.baseHoursSpecialDay : appState.baseHoursWeekday;
    final baseRate = isSpecialDay ? 1.5 : 1.0;

    // Apply base rate to base hours
    if (remainingHours > 0) {
      final hoursAtBaseRate = Math.min(remainingHours, baseHours);
      wage += hoursAtBaseRate * hourlyWage * baseRate;
      remainingHours -= hoursAtBaseRate;
    }

    // Sort overtime rules by hours threshold in ascending order
    final applicableRules = appState.overtimeRules
        .where((rule) => rule.isForSpecialDays == isSpecialDay)
        .toList()
      ..sort((a, b) => a.hoursThreshold.compareTo(b.hoursThreshold));

    // Apply overtime rules
    for (var rule in applicableRules) {
      if (remainingHours > 0 && totalHours > rule.hoursThreshold) {
        final overtimeHours = Math.min(remainingHours, totalHours - rule.hoursThreshold);
        wage += overtimeHours * hourlyWage * rule.rate;
        remainingHours -= overtimeHours;
      }
    }

    return wage;
  }

  double _calculateNetWage(double grossWage, double taxDeduction) {
    return grossWage * (1 - taxDeduction / 100);
  }

  Map<String, double> _calculateWagePercentages(AppState appState, DateTime date, TimeOfDay startTime, TimeOfDay endTime) {
    final totalHours = _calculateTotalHours(date, startTime, endTime);
    final isSpecialDay = _isWeekend(appState, date) || _isFestiveDay(appState, date);

    Map<String, double> wagePercentages = {};
    double remainingHours = totalHours;

    // Determine base hours and base rate
    final baseHours = isSpecialDay ? appState.baseHoursSpecialDay : appState.baseHoursWeekday;
    final baseRate = isSpecialDay ? 1.5 : 1.0;

    // Apply base rate to base hours
    if (remainingHours > 0) {
      final hoursAtBaseRate = Math.min(remainingHours, baseHours);
      wagePercentages['${(baseRate * 100).toInt()}%'] = hoursAtBaseRate;
      remainingHours -= hoursAtBaseRate;
    }

    // Sort overtime rules by hours threshold in ascending order
    final applicableRules = appState.overtimeRules
        .where((rule) => rule.isForSpecialDays == isSpecialDay)
        .toList()
      ..sort((a, b) => a.hoursThreshold.compareTo(b.hoursThreshold));

    // Apply overtime rules
    for (var rule in applicableRules) {
      if (remainingHours > 0 && totalHours > rule.hoursThreshold) {
        final overtimeHours = Math.min(remainingHours, totalHours - rule.hoursThreshold);
        wagePercentages['${(rule.rate * 100).toInt()}%'] = 
            (wagePercentages['${(rule.rate * 100).toInt()}%'] ?? 0) + overtimeHours;
        remainingHours -= overtimeHours;
      }
    }

    return wagePercentages;
  }

// Part 8: Utility methods
  bool _isWeekend(AppState appState, DateTime date) {
    if (appState.startOnSunday) {
      return date.weekday == DateTime.saturday;
    } else {
      return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    }
  }

  bool _isFestiveDay(AppState appState, DateTime date) {
    return appState.festiveDays.any((festiveDay) =>
        festiveDay.year == date.year &&
        festiveDay.month == date.month &&
        festiveDay.day == date.day);
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.Hm().format(dateTime);
  }

  List<Shift> _getCurrentMonthShifts(List<Shift> allShifts) {
    final now = DateTime.now();
    return allShifts
        .where((shift) => shift.date.year == now.year && shift.date.month == now.month)
        .toList();
  }

  String _getLocalizedDayMonth(BuildContext context, DateTime date) {
    final localizations = AppLocalizations.of(context)!;
    final dayNames = [
      localizations.sunday,
      localizations.monday,
      localizations.tuesday,
      localizations.wednesday,
      localizations.thursday,
      localizations.friday,
      localizations.saturday,
    ];
    final monthNames = [
      localizations.january,
      localizations.february,
      localizations.march,
      localizations.april,
      localizations.may,
      localizations.june,
      localizations.july,
      localizations.august,
      localizations.september,
      localizations.october,
      localizations.november,
      localizations.december,
    ];
    return '${dayNames[date.weekday % 7]}, ${monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }
}
