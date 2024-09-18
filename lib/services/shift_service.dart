import 'package:flutter/foundation.dart';
import '../models/shift.dart';

class ShiftService extends ChangeNotifier {
  final List<Shift> _shifts = [];

  ShiftService() {
    print('DEBUG: ShiftService constructor called');
    _addSampleShifts(); // Add this line
  }

  void _addSampleShifts() {
    final now = DateTime.now();
    _shifts.addAll([
      Shift(startTime: now.add(Duration(days: 1)), endTime: now.add(Duration(days: 1, hours: 8))),
      Shift(startTime: now.add(Duration(days: 2)), endTime: now.add(Duration(days: 2, hours: 8))),
      Shift(startTime: now.add(Duration(days: 3)), endTime: now.add(Duration(days: 3, hours: 8))),
      Shift(startTime: now.add(Duration(days: 4)), endTime: now.add(Duration(days: 4, hours: 8))),
    ]);
    print('DEBUG: Added ${_shifts.length} sample shifts');
  }

  List<Shift> getUpcomingShifts(int count) {
    print('DEBUG: getUpcomingShifts called with count: $count');
    final now = DateTime.now();
    final upcomingShifts = _shifts
      .where((shift) => shift.startTime.isAfter(now))
      .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    
    print('Total shifts: ${_shifts.length}, Upcoming shifts: ${upcomingShifts.length}');
    
    return upcomingShifts.take(count).toList();
  }
}