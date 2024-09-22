import 'package:flutter/foundation.dart';
import '../models/shift.dart';
import 'dart:collection';

class ShiftService extends ChangeNotifier {
  final List<Shift> _shifts = [];

  UnmodifiableListView<Shift> get shifts => UnmodifiableListView(_shifts);

  void addShift(Shift shift) {
    if (shift.startTime != null && shift.endTime != null) {
      _shifts.add(shift);
      _shifts.sort((a, b) => a.startTime!.compareTo(b.startTime!));
      notifyListeners();
    } else {
      print('Warning: Attempted to add a shift with null startTime or endTime');
    }
  }

  List<Shift> getUpcomingShifts(int count) {
    final now = DateTime.now();
    return _shifts
        .where((shift) => shift.startTime != null && shift.startTime!.isAfter(now))
        .take(count)
        .toList();
  }

  // Add this method to initialize with some sample shifts
  void addSampleShifts() {
    final now = DateTime.now();
    addShift(Shift(startTime: now.add(const Duration(days: 1)), endTime: now.add(const Duration(days: 1, hours: 8))));
    addShift(Shift(startTime: now.add(const Duration(days: 2)), endTime: now.add(const Duration(days: 2, hours: 8))));
    addShift(Shift(startTime: now.add(const Duration(days: 3)), endTime: now.add(const Duration(days: 3, hours: 8))));
    print('Added ${_shifts.length} sample shifts');
  }
}