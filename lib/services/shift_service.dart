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
    final filtered = _shifts
        .where(
            (shift) => shift.startTime != null && shift.startTime!.isAfter(now))
        .toList();

    // Sort in descending order (next day first)
    filtered.sort((a, b) => b.startTime!.compareTo(a.startTime!));

    // Take only the first 'count' shifts
    return filtered.take(count).toList();
  }

  // Add this method to initialize with some sample shifts
  void addSampleShifts() {
    final now = DateTime.now();

    // Day 1
    final day1Start = now.add(const Duration(days: 1));
    final day1End = now.add(const Duration(days: 1, hours: 8));
    final day1Hours = day1End.difference(day1Start).inMinutes / 60.0;

    // Day 2
    final day2Start = now.add(const Duration(days: 2));
    final day2End = now.add(const Duration(days: 2, hours: 8));
    final day2Hours = day2End.difference(day2Start).inMinutes / 60.0;

    // Day 3
    final day3Start = now.add(const Duration(days: 3));
    final day3End = now.add(const Duration(days: 3, hours: 8));
    final day3Hours = day3End.difference(day3Start).inMinutes / 60.0;

    // Create shifts with all required parameters
    addShift(Shift(
      date: day1Start,
      startTime: day1Start,
      endTime: day1End,
      totalHours: day1Hours,
      grossWage: 0.0,
      netWage: 0.0,
    ));

    addShift(Shift(
      date: day2Start,
      startTime: day2Start,
      endTime: day2End,
      totalHours: day2Hours,
      grossWage: 0.0,
      netWage: 0.0,
    ));

    addShift(Shift(
      date: day3Start,
      startTime: day3Start,
      endTime: day3End,
      totalHours: day3Hours,
      grossWage: 0.0,
      netWage: 0.0,
    ));

    print('Added ${_shifts.length} sample shifts');
  }
}
