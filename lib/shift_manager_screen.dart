import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'app_state.dart';
import 'dart:math' as Math;

class ShiftManagerScreen extends StatefulWidget {
  @override
  _ShiftManagerScreenState createState() => _ShiftManagerScreenState();
}

class _ShiftManagerScreenState extends State<ShiftManagerScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 17, minute: 0);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.shiftManagerTitle),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.addNewShift,
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            _buildButton(
              context,
              '${localizations.selectDate}: ${DateFormat('dd-MM-yyyy').format(_selectedDate)}',
              () => _selectDate(context),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildButton(
                    context,
                    '${localizations.startTime}: ${_startTime.format(context)}',
                    () => _selectTime(context, true),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildButton(
                    context,
                    '${localizations.endTime}: ${_endTime.format(context)}',
                    () => _selectTime(context, false),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildButton(context, localizations.addShift, _addShift),
            SizedBox(height: 32),
            Text(localizations.existingShifts,
                style: Theme.of(context).textTheme.titleLarge),
            Expanded(
              child: Consumer<AppState>(
                builder: (context, appState, child) {
                  List<Shift> sortedShifts = List.from(appState.shifts)
                    ..sort((a, b) => a.date.compareTo(b.date));
                  return ListView.builder(
                    itemCount: sortedShifts.length,
                    itemBuilder: (context, index) {
                      final shift = sortedShifts[index];
                      return ListTile(
                        title:
                            Text(DateFormat('dd-MM-yyyy').format(shift.date)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${localizations.startTime}: ${shift.startTime.format(context)} - ${localizations.endTime}: ${shift.endTime.format(context)}'),
                            Text(
                                '${localizations.totalHours}: ${shift.totalHours.toStringAsFixed(2)}'),
                            Text(
                                '${localizations.grossWage}: \$${shift.grossWage.toStringAsFixed(2)}'),
                            Text(
                                '${localizations.netWage}: \$${shift.netWage.toStringAsFixed(2)}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  Icon(Icons.edit, color: colorScheme.primary),
                              onPressed: () => _editShift(context, appState,
                                  appState.shifts.indexOf(shift), shift),
                            ),
                            IconButton(
                              icon:
                                  Icon(Icons.delete, color: colorScheme.error),
                              onPressed: () => _confirmDeleteShift(context,
                                  appState, appState.shifts.indexOf(shift)),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String text, VoidCallback onPressed) {
    final colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton(
      child: Text(text),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        minimumSize: Size(double.infinity, 36),
      ),
    );
  }

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

  void _addShift() {
    final appState = Provider.of<AppState>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;

    final newShift = _createShift(appState);

    // Check for duplicate shift
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.shiftAddedSuccessfully)),
      );
    }
  }

  Shift _createShift(AppState appState) {
    final totalHours =
        _calculateTotalHours(_selectedDate, _startTime, _endTime);
    final grossWage =
        _calculateGrossWage(appState, _selectedDate, _startTime, _endTime);
    final netWage = _calculateNetWage(grossWage, appState.taxDeduction);

    return Shift(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _selectedDate,
      startTime: _startTime,
      endTime: _endTime,
      totalHours: totalHours,
      grossWage: grossWage,
      netWage: netWage,
      wagePercentages: _calculateWagePercentages(
          appState, _selectedDate, _startTime, _endTime),
    );
  }

  void _editShift(
      BuildContext context, AppState appState, int index, Shift shift) async {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    DateTime editDate = shift.date;
    TimeOfDay editStartTime = shift.startTime;
    TimeOfDay editEndTime = shift.endTime;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(localizations.edit),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildButton(
                    context,
                    '${localizations.selectDate}: ${DateFormat('dd-MM-yyyy').format(editDate)}',
                    () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: editDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != editDate) {
                        setState(() {
                          editDate = picked;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildButton(
                          context,
                          '${localizations.startTime}: ${editStartTime.format(context)}',
                          () async {
                            final TimeOfDay? picked = await showTimePicker(
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
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildButton(
                          context,
                          '${localizations.endTime}: ${editEndTime.format(context)}',
                          () async {
                            final TimeOfDay? picked = await showTimePicker(
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
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text(localizations.cancel),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text(localizations.save),
                  onPressed: () {
                    final totalHours = _calculateTotalHours(
                        editDate, editStartTime, editEndTime);
                    final grossWage = _calculateGrossWage(
                        appState, editDate, editStartTime, editEndTime);
                    final netWage =
                        _calculateNetWage(grossWage, appState.taxDeduction);

                    final updatedShift = Shift(
                      id: shift.id,
                      date: editDate,
                      startTime: editStartTime,
                      endTime: editEndTime,
                      totalHours: totalHours,
                      grossWage: grossWage,
                      netWage: netWage,
                      wagePercentages: _calculateWagePercentages(
                          appState, editDate, editStartTime, editEndTime),
                    );
                    appState.updateShift(index, updatedShift);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  double _calculateTotalHours(
      DateTime date, TimeOfDay startTime, TimeOfDay endTime) {
    final startDateTime = DateTime(
        date.year, date.month, date.day, startTime.hour, startTime.minute);
    var endDateTime =
        DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);

    if (endDateTime.isBefore(startDateTime)) {
      // If end time is before start time, it means the shift ends on the next day
      endDateTime = endDateTime.add(Duration(days: 1));
    }

    final duration = endDateTime.difference(startDateTime);
    return duration.inMinutes / 60.0;
  }

  double _calculateGrossWage(AppState appState, DateTime date,
      TimeOfDay startTime, TimeOfDay endTime) {
    final totalHours = _calculateTotalHours(date, startTime, endTime);
    final hourlyWage = appState.hourlyWage;

    double wage = 0;
    double remainingHours = totalHours;
    DateTime currentDateTime = DateTime(
        date.year, date.month, date.day, startTime.hour, startTime.minute);

    while (remainingHours > 0) {
      bool isWeekend = _isWeekend(appState, currentDateTime);
      double hoursToday = Math.min(remainingHours,
          24 - currentDateTime.hour - currentDateTime.minute / 60);

      if (isWeekend) {
        // Weekend rates
        wage += _calculateOvertimeWage(hourlyWage, hoursToday, 8, 1.5);
        double overtimeHours = Math.max(0, hoursToday - 8);
        wage += _calculateOvertimeWage(hourlyWage, overtimeHours, 2, 1.75);
        wage += _calculateOvertimeWage(
            hourlyWage, Math.max(0, overtimeHours - 2), double.infinity, 2.0);
      } else {
        // Weekday rates
        wage += _calculateOvertimeWage(hourlyWage, hoursToday, 8, 1.0);
        double overtimeHours = Math.max(0, hoursToday - 8);
        wage += _calculateOvertimeWage(hourlyWage, overtimeHours, 2, 1.25);
        wage += _calculateOvertimeWage(
            hourlyWage, Math.max(0, overtimeHours - 2), double.infinity, 1.5);
      }

      remainingHours -= hoursToday;
      currentDateTime = currentDateTime.add(Duration(
          hours: hoursToday.floor(), minutes: ((hoursToday % 1) * 60).round()));
    }

    return wage;
  }

  Map<String, double> _calculateWagePercentages(AppState appState,
      DateTime date, TimeOfDay startTime, TimeOfDay endTime) {
    final totalHours = _calculateTotalHours(date, startTime, endTime);
    bool isWeekend = _isWeekend(appState, date);

    Map<String, double> wagePercentages = {
      '100%': 0,
      '125%': 0,
      '150%': 0,
      '175%': 0,
      '200%': 0,
    };

    if (isWeekend) {
      // Weekend rates
      wagePercentages['150%'] = Math.min(totalHours, 8);
      wagePercentages['175%'] = Math.min(Math.max(totalHours - 8, 0), 2);
      wagePercentages['200%'] = Math.max(totalHours - 10, 0);
    } else {
      // Weekday rates
      wagePercentages['100%'] = Math.min(totalHours, 8);
      wagePercentages['125%'] = Math.min(Math.max(totalHours - 8, 0), 2);
      wagePercentages['150%'] = Math.max(totalHours - 10, 0);
    }

    return wagePercentages;
  }

  double _calculateOvertimeWage(
      double hourlyWage, double hours, double limit, double rate) {
    final overtimeHours = Math.min(hours, limit);
    return overtimeHours * hourlyWage * rate;
  }

  bool _isWeekend(AppState appState, DateTime date) {
    if (appState.startOnSunday) {
      return date.weekday == DateTime.saturday;
    } else {
      return date.weekday == DateTime.sunday;
    }
  }

  double _calculateNetWage(double grossWage, double taxDeduction) {
    return grossWage * (1 - taxDeduction / 100);
  }

  void _confirmDeleteShift(BuildContext context, AppState appState, int index) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.confirmDelete),
          content: Text(localizations.deleteShiftConfirmation),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(localizations.delete),
              onPressed: () {
                _deleteShift(appState, index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteShift(AppState appState, int index) {
    appState.deleteShift(index);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(AppLocalizations.of(context)!.deleteShiftConfirmation)),
    );
  }
}
