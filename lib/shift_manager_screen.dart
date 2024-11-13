// File: lib/shift_manager_screen.dart

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

class _ShiftManagerScreenState extends State<ShiftManagerScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  bool _showCurrentMonthOnly = true;
  String? _shiftNote;

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
                TextField(
                  decoration: InputDecoration(
                    labelText: localizations.addNote,
                    hintText: localizations.addNoteHint,
                  ),
                  textDirection: Directionality.of(context),
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  onChanged: (value) {
                    setState(() {
                      _shiftNote = value;
                    });
                  },
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
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
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
                Row(
                  children: [
                    Text('${localizations.startTime}: '),
                    Text(_formatTime(shift.startTime)),
                    Text(' - ${localizations.endTime}: '),
                    Text(_formatTime(shift.endTime)),
                  ],
                ),
                Row(
                  children: [
                    Text('${localizations.totalHours}: '),
                    Text(shift.totalHours.toStringAsFixed(2)),
                  ],
                ),
                Row(
                  children: [
                    Text('${localizations.grossWage}: '),
                    Text('${appState.getCurrencySymbol()}${shift.grossWage.toStringAsFixed(2)}'),
                  ],
                ),
                Row(
                  children: [
                    Text('${localizations.netWage}: '),
                    Text('${appState.getCurrencySymbol()}${shift.netWage.toStringAsFixed(2)}'),
                  ],
                ),
                if (shift.note?.isNotEmpty == true)
                  Text('${localizations.note}: ${shift.note}'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.star,
                        color: shift.isSpecialDay ? Colors.amber : Colors.grey,
                      ),
                      onPressed: () => _toggleSpecialDay(shift),
                      tooltip: localizations.toggleSpecialDay,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editShift(context, appState, shift),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDeleteShift(context, appState, shift),
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

  void _addShift() {
    final appState = Provider.of<AppState>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;

    final newShift = _createShift(appState);
    newShift.note = _shiftNote;

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

  // Part 6: Shift management methods
  Shift _createShift(AppState appState) {
    final totalHours = _calculateTotalHours(_selectedDate, _startTime, _endTime);
    final grossWage = _calculateGrossWage(appState, _selectedDate, _startTime, _endTime);
    final netWage = _calculateNetWage(grossWage, appState.taxDeduction);

    return Shift(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _selectedDate,
      startTime: _startTime,
      endTime: _endTime,
      totalHours: totalHours,
      grossWage: grossWage,
      netWage: netWage,
      wagePercentages: _calculateWagePercentages(appState, _selectedDate, _startTime, _endTime),
      note: _shiftNote,
      isSpecialDay: false,
    );
  }

  void _editShift(BuildContext context, AppState appState, Shift shift) async {
    final localizations = AppLocalizations.of(context)!;
    DateTime editDate = shift.date;
    TimeOfDay editStartTime = shift.startTime;
    TimeOfDay editEndTime = shift.endTime;
    String? editNote = shift.note;

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(localizations.editShift),
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildButton(
                          context,
                          '${localizations.startTime}: ${_formatTime(editStartTime)}',
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildButton(
                          context,
                          '${localizations.endTime}: ${_formatTime(editEndTime)}',
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
                  const SizedBox(height: 16),
                  TextField(
                    controller: TextEditingController(text: editNote)
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: editNote?.length ?? 0),
                      ),
                    decoration: InputDecoration(
                      labelText: localizations.editNote,
                      hintText: localizations.addNoteHint,
                    ),
                    textDirection: Directionality.of(context),
                    textAlign: TextAlign.start,
                    maxLines: 2,
                    onChanged: (value) {
                      setState(() {
                        editNote = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text(localizations.cancel),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text(localizations.save),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      final updatedShift = Shift(
        id: shift.id,
        date: editDate,
        startTime: editStartTime,
        endTime: editEndTime,
        totalHours: _calculateTotalHours(editDate, editStartTime, editEndTime),
        grossWage: _calculateGrossWage(appState, editDate, editStartTime, editEndTime),
        netWage: _calculateNetWage(
            _calculateGrossWage(appState, editDate, editStartTime, editEndTime),
            appState.taxDeduction),
        wagePercentages: _calculateWagePercentages(
            appState, editDate, editStartTime, editEndTime),
        note: editNote,
        isSpecialDay: shift.isSpecialDay,
      );
      appState.updateShift(appState.shifts.indexOf(shift), updatedShift);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.shiftUpdatedSuccessfully)),
      );
    }
  }

  void _confirmDeleteShift(BuildContext context, AppState appState, Shift shift) {
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
                appState.deleteShift(appState.shifts.indexOf(shift));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(localizations.shiftDeletedSuccessfully)),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Part 7: Calculation methods
  double _calculateTotalHours(DateTime date, TimeOfDay startTime, TimeOfDay endTime) {
    final startDateTime = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);
    var endDateTime = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);

    if (endDateTime.isBefore(startDateTime)) {
      endDateTime = endDateTime.add(const Duration(days: 1));
    }

    return endDateTime.difference(startDateTime).inMinutes / 60.0;
  }

  double _calculateGrossWage(AppState appState, DateTime date, TimeOfDay startTime, TimeOfDay endTime, {bool isSpecialDay = false}) {
    final totalHours = _calculateTotalHours(date, startTime, endTime);
    final hourlyWage = appState.hourlyWage;
    final isWeekend = _isWeekend(appState, date);
    final isFestiveDay = _isFestiveDay(appState, date);
    final isSpecialDayFinal = isSpecialDay || isWeekend || isFestiveDay;

    double wage = 0;
    double remainingHours = totalHours;

    // Determine base hours and base rate
    final baseHours = isSpecialDayFinal ? appState.baseHoursSpecialDay : appState.baseHoursWeekday;
    final baseRate = isSpecialDayFinal ? 1.5 : 1.0;

    // Apply base rate to base hours
    if (remainingHours > 0) {
      final hoursAtBaseRate = Math.min(remainingHours, baseHours);
      wage += hoursAtBaseRate * hourlyWage * baseRate;
      remainingHours -= hoursAtBaseRate;
    }

    // Sort overtime rules by hours threshold
    final applicableRules = appState.overtimeRules
        .where((rule) => rule.isForSpecialDays == isSpecialDayFinal)
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

    // If there are still remaining hours, apply them at the base rate
    if (remainingHours > 0) {
      wage += remainingHours * hourlyWage * baseRate;
    }

    return wage;
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

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

  List<Shift> _getCurrentMonthShifts(List<Shift> shifts) {
    final now = DateTime.now();
    return shifts.where((shift) =>
        shift.date.year == now.year && shift.date.month == now.month).toList();
  }

  String _getLocalizedDayMonth(BuildContext context, DateTime date) {
    final localizations = AppLocalizations.of(context)!;
    final dayName = DateFormat('EEEE', localizations.localeName).format(date);
    final monthName = DateFormat('MMMM', localizations.localeName).format(date);
    return '$dayName, ${date.day} $monthName';
  }

  double _calculateNetWage(double grossWage, double taxDeduction) {
    return grossWage * (1 - taxDeduction / 100);
  }

  Map<String, double> _calculateWagePercentages(AppState appState, DateTime date, TimeOfDay startTime, TimeOfDay endTime) {
    // Implement wage percentage calculation logic here
    return {};
  }

  bool _isWeekend(AppState appState, DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  bool _isFestiveDay(AppState appState, DateTime date) {
    // Implement festive day check logic here
    return false;
  }

  void _toggleSpecialDay(Shift shift) {
    final appState = Provider.of<AppState>(context, listen: false);
    
    final updatedShift = Shift(
      id: shift.id,
      date: shift.date,
      startTime: shift.startTime,
      endTime: shift.endTime,
      totalHours: shift.totalHours,
      grossWage: _calculateGrossWage(
        appState, 
        shift.date, 
        shift.startTime, 
        shift.endTime,
        isSpecialDay: !shift.isSpecialDay
      ),
      netWage: _calculateNetWage(
        _calculateGrossWage(
          appState, 
          shift.date, 
          shift.startTime, 
          shift.endTime,
          isSpecialDay: !shift.isSpecialDay
        ),
        appState.taxDeduction
      ),
      wagePercentages: _calculateWagePercentages(
        appState, 
        shift.date, 
        shift.startTime, 
        shift.endTime
      ),
      note: shift.note,
      isSpecialDay: !shift.isSpecialDay,
    );

    appState.updateShift(appState.shifts.indexOf(shift), updatedShift);
  }

  bool _isSpecialDay(AppState appState, Shift shift) {
    return shift.isSpecialDay || 
           _isWeekend(appState, shift.date) || 
           _isFestiveDay(appState, shift.date);
  }
}