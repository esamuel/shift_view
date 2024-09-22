import 'package:intl/intl.dart';

class Shift {
  final DateTime? startTime;
  final DateTime? endTime;

  Shift({this.startTime, this.endTime});

  String? get dayOfWeek => startTime != null ? DateFormat('E').format(startTime!) : null;
  Duration? get duration => startTime != null && endTime != null ? endTime!.difference(startTime!) : null;

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time']) : null,
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
    );
  }
}
