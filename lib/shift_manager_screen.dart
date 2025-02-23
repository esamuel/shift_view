// File: lib/shift_manager_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'models/shift.dart';
import 'models/overtime_rule.dart';
import 'app_state.dart';

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
  final bool _isSpecialDay = false;

  @override
  void initState() {
    super.initState();
    // Initialize shifts when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.ensureShiftsStreamInitialized();
      appState.refreshShifts(); // Force immediate refresh
    });
  }

  double _calculateTotalHours(
      DateTime date, TimeOfDay startTime, TimeOfDay endTime) {
    final start = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );

    DateTime end = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );

    // Handle overnight shifts
    if (end.isBefore(start)) {
      end = end.add(const Duration(days: 1));
    }

    return end.difference(start).inMinutes / 60.0;
  }

  double _calculateGrossWage(
      AppState appState, DateTime date, TimeOfDay startTime, TimeOfDay endTime,
      {bool isSpecialDay = false}) {
    final totalHours = _calculateTotalHours(date, startTime, endTime);

    print('\n=== WAGE CALCULATION DEBUG ===');
    print('Date: $date');
    print('Is Special Day: $isSpecialDay');
    print('Total Hours: $totalHours');
    print('Base Hourly Wage: ${appState.hourlyWage}');

    double wage = 0.0;

    if (isSpecialDay) {
      // Special day calculation (weekends/holidays)
      if (totalHours <= 8.0) {
        // First 8 hours at 1.5x
        wage = totalHours * appState.hourlyWage * 1.5;
        print('All hours at 1.5x: $wage');
      } else if (totalHours <= 10.0) {
        // First 8 hours at 1.5x
        wage = 8.0 * appState.hourlyWage * 1.5;
        print('First 8 hours at 1.5x: $wage');

        // Remaining hours at 1.75x
        double overtimeHours = totalHours - 8.0;
        double overtimePay = overtimeHours * appState.hourlyWage * 1.75;
        wage += overtimePay;
        print('Additional ${overtimeHours}h at 1.75x: $overtimePay');
      } else {
        // First 8 hours at 1.5x
        wage = 8.0 * appState.hourlyWage * 1.5;
        print('First 8 hours at 1.5x: $wage');

        // Next 2 hours at 1.75x
        wage += 2.0 * appState.hourlyWage * 1.75;
        print('Next 2 hours at 1.75x: ${2.0 * appState.hourlyWage * 1.75}');

        // Remaining hours at 2.0x
        double extraHours = totalHours - 10.0;
        double extraPay = extraHours * appState.hourlyWage * 2.0;
        wage += extraPay;
        print('Additional ${extraHours}h at 2.0x: $extraPay');
      }
    } else {
      // Regular day calculation
      if (totalHours <= 8.0) {
        // First 8 hours at regular rate
        wage = totalHours * appState.hourlyWage;
        print('All hours at 1.0x: $wage');
      } else if (totalHours <= 10.0) {
        // First 8 hours at regular rate
        wage = 8.0 * appState.hourlyWage;
        print('First 8 hours at 1.0x: $wage');

        // Remaining hours at 1.25x
        double overtimeHours = totalHours - 8.0;
        double overtimePay = overtimeHours * appState.hourlyWage * 1.25;
        wage += overtimePay;
        print('Additional ${overtimeHours}h at 1.25x: $overtimePay');
      } else {
        // First 8 hours at regular rate
        wage = 8.0 * appState.hourlyWage;
        print('First 8 hours at 1.0x: $wage');

        // Next 2 hours at 1.25x
        wage += 2.0 * appState.hourlyWage * 1.25;
        print('Next 2 hours at 1.25x: ${2.0 * appState.hourlyWage * 1.25}');

        // Remaining hours at 1.5x
        double extraHours = totalHours - 10.0;
        double extraPay = extraHours * appState.hourlyWage * 1.5;
        wage += extraPay;
        print('Additional ${extraHours}h at 1.5x: $extraPay');
      }
    }

    print('Total Wage: $wage');
    print('===========================\n');

    return wage;
  }

  Map<String, double> _calculateWagePercentages(
      AppState appState, DateTime date, TimeOfDay startTime, TimeOfDay endTime,
      {bool isSpecialDay = false}) {
    Map<String, double> percentages = {'base': 1.0};

    // Apply special day rate if it's a special day
    if (isSpecialDay) {
      percentages['special'] = appState.baseHoursSpecialDay;
    }

    // Apply overtime rules
    for (var rule in appState.overtimeRules) {
      if (rule.isForSpecialDays == isSpecialDay) {
        final totalHours = _calculateTotalHours(date, startTime, endTime);
        if (totalHours > rule.hoursThreshold) {
          percentages['overtime'] = rule.rate;
        }
      }
    }

    return percentages;
  }

  Shift _createShift(AppState appState) {
    final totalHours =
        _calculateTotalHours(_selectedDate, _startTime, _endTime);

    // Determine if it's a weekend based on app settings
    bool isWeekend = false;
    if (appState.startOnSunday) {
      // For Israel (work week starts on Sunday)
      isWeekend = _selectedDate.weekday == DateTime.saturday;
    } else {
      // For other countries (work week starts on Monday)
      isWeekend = _selectedDate.weekday == DateTime.saturday ||
          _selectedDate.weekday == DateTime.sunday;
    }

    // Calculate gross wage with special day rates if it's a weekend
    final grossWage = _calculateGrossWage(
        appState, _selectedDate, _startTime, _endTime,
        isSpecialDay: isWeekend);

    final netWage = grossWage * (1 - appState.taxDeduction / 100);

    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    return Shift(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _selectedDate,
      startTime: startDateTime,
      endTime: endDateTime,
      note: _shiftNote ?? '',
      totalHours: totalHours,
      grossWage: grossWage,
      netWage: netWage,
      isSpecialDay: isWeekend, // Set isSpecialDay based on weekend status
    );
  }

  void _addShift() {
    final appState = Provider.of<AppState>(context, listen: false);
    final localizations = AppLocalizations.of(context);

    final newShift = _createShift(appState);

    bool isDuplicate = appState.shifts.any((shift) =>
        shift.date.year == newShift.date.year &&
        shift.date.month == newShift.date.month &&
        shift.date.day == newShift.date.day &&
        shift.startTime?.hour == newShift.startTime?.hour &&
        shift.startTime?.minute == newShift.startTime?.minute &&
        shift.endTime?.hour == newShift.endTime?.hour &&
        shift.endTime?.minute == newShift.endTime?.minute);

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

  Future<void> _editShift(
      BuildContext context, AppState appState, Shift shift) async {
    DateTime editDate = shift.date;
    TimeOfDay editStartTime = shift.startTime != null
        ? TimeOfDay(
            hour: shift.startTime!.hour, minute: shift.startTime!.minute)
        : const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay editEndTime = shift.endTime != null
        ? TimeOfDay(hour: shift.endTime!.hour, minute: shift.endTime!.minute)
        : const TimeOfDay(hour: 17, minute: 0);
    String? editNote = shift.note;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context).edit),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(DateFormat('dd-MM-yyyy').format(editDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: editDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() => editDate = date);
                      }
                    },
                  ),
                  ListTile(
                    title: Text(_formatTime(editStartTime)),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: editStartTime,
                      );
                      if (time != null) {
                        setState(() => editStartTime = time);
                      }
                    },
                  ),
                  ListTile(
                    title: Text(_formatTime(editEndTime)),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: editEndTime,
                      );
                      if (time != null) {
                        setState(() => editEndTime = time);
                      }
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).note,
                    ),
                    controller: TextEditingController(text: editNote),
                    onChanged: (value) => editNote = value,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text(AppLocalizations.of(context).cancel),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text(AppLocalizations.of(context).save),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      ),
    );

    if (result == true) {
      final totalHours =
          _calculateTotalHours(editDate, editStartTime, editEndTime);
      final grossWage =
          _calculateGrossWage(appState, editDate, editStartTime, editEndTime);
      final netWage = grossWage * (1 - appState.taxDeduction / 100);

      final startDateTime = DateTime(
        editDate.year,
        editDate.month,
        editDate.day,
        editStartTime.hour,
        editStartTime.minute,
      );

      final endDateTime = DateTime(
        editDate.year,
        editDate.month,
        editDate.day,
        editEndTime.hour,
        editEndTime.minute,
      );

      final updatedShift = Shift(
        id: shift.id,
        date: editDate,
        startTime: startDateTime,
        endTime: endDateTime,
        totalHours: totalHours,
        grossWage: grossWage,
        netWage: netWage,
        note: editNote ?? '',
        isSpecialDay: shift.isSpecialDay,
      );

      final index = appState.shifts.indexWhere((s) => s.id == shift.id);
      if (index != -1) {
        appState.updateShift(index, updatedShift);
      }
    }
  }

  void _toggleSpecialDay(Shift shift) {
    final appState = Provider.of<AppState>(context, listen: false);
    final startTimeOfDay = shift.startTime != null
        ? TimeOfDay(
            hour: shift.startTime!.hour, minute: shift.startTime!.minute)
        : const TimeOfDay(hour: 8, minute: 0);
    final endTimeOfDay = shift.endTime != null
        ? TimeOfDay(hour: shift.endTime!.hour, minute: shift.endTime!.minute)
        : const TimeOfDay(hour: 17, minute: 0);

    final newIsSpecialDay = !shift.isSpecialDay;

    // Calculate wages with the new special day status
    final grossWage = _calculateGrossWage(
        appState, shift.date, startTimeOfDay, endTimeOfDay,
        isSpecialDay: newIsSpecialDay);

    final netWage = grossWage * (1 - appState.taxDeduction / 100);
    final totalHours =
        _calculateTotalHours(shift.date, startTimeOfDay, endTimeOfDay);

    final updatedShift = Shift(
      id: shift.id,
      date: shift.date,
      startTime: shift.startTime,
      endTime: shift.endTime,
      totalHours: totalHours,
      grossWage: grossWage,
      netWage: netWage,
      note: shift.note,
      isSpecialDay: newIsSpecialDay,
    );

    final index = appState.shifts.indexWhere((s) => s.id == shift.id);
    if (index != -1) {
      appState.updateShift(index, updatedShift);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newIsSpecialDay
              ? 'Changed to special day with overtime rules'
              : 'Changed to regular day with overtime rules'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _confirmDeleteShift(
    BuildContext context,
    AppState appState,
    Shift shift,
  ) async {
    final localizations = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.confirmDelete),
        content: Text(localizations.deleteShiftConfirmation),
        actions: [
          TextButton(
            child: Text(localizations.cancel),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text(localizations.delete),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (result == true) {
      final index = appState.shifts.indexWhere((s) => s.id == shift.id);
      if (index != -1) {
        appState.deleteShift(index);
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  List<Shift> _getCurrentMonthShifts(List<Shift> shifts) {
    return shifts
        .where((shift) =>
            shift.date.year == _selectedDate.year &&
            shift.date.month == _selectedDate.month)
        .toList();
  }

  String _getLocalizedDayMonth(BuildContext context, DateTime date) {
    final localizations = AppLocalizations.of(context);
    final weekday = DateFormat('EEEE').format(date);
    final day = date.day.toString();
    final month = date.month.toString();
    return localizations.shiftDateFormat(weekday, day, month);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

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

  Widget _buildButton(
      BuildContext context, String text, VoidCallback onPressed) {
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
    return StreamBuilder<List<Shift>>(
      stream: appState.shiftsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${snapshot.error}'),
                ElevatedButton(
                  onPressed: () => appState.refreshShifts(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            appState.shifts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Use either stream data or current state data
        List<Shift> shifts = snapshot.data ?? appState.shifts;

        // Filter shifts based on the switch state
        if (_showCurrentMonthOnly) {
          final now = DateTime.now();
          shifts = shifts
              .where((shift) =>
                  shift.date.year == now.year && shift.date.month == now.month)
              .toList();
        }

        // Sort shifts by date (newest first)
        shifts.sort((a, b) => b.date.compareTo(a.date));

        if (shifts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _showCurrentMonthOnly
                    ? '${localizations.currentMonth} - ${localizations.existingShifts} (0)'
                    : localizations.existingShifts,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: shifts.length,
          itemBuilder: (context, index) {
            final shift = shifts[index];
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
                        Text(_formatTime(TimeOfDay(
                          hour: shift.startTime?.hour ?? 8,
                          minute: shift.startTime?.minute ?? 0,
                        ))),
                        Text(' - ${localizations.endTime}: '),
                        Text(_formatTime(TimeOfDay(
                          hour: shift.endTime?.hour ?? 17,
                          minute: shift.endTime?.minute ?? 0,
                        ))),
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
                        Text(
                            '${appState.getCurrencySymbol()}${shift.grossWage.toStringAsFixed(2)}'),
                      ],
                    ),
                    Row(
                      children: [
                        Text('${localizations.netWage}: '),
                        Text(
                            '${appState.getCurrencySymbol()}${shift.netWage.toStringAsFixed(2)}'),
                      ],
                    ),
                    if (shift.note.isNotEmpty)
                      Text('${localizations.note}: ${shift.note}'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.star,
                            color:
                                shift.isSpecialDay ? Colors.amber : Colors.grey,
                            size: 24,
                          ),
                          onPressed: () => _toggleSpecialDay(shift),
                          tooltip: shift.isSpecialDay
                              ? 'Special day'
                              : 'Regular day',
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editShift(context, appState, shift),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _confirmDeleteShift(context, appState, shift),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
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
}
