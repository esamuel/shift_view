import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Shift {
  final String id;
  final DateTime date;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? note;
  final double totalHours;
  final double grossWage;
  final double netWage;
  final bool isSpecialDay;
  final Map<String, double>? wagePercentages;

  Shift({
    required this.id,
    required this.date,
    this.startTime,
    this.endTime,
    this.note,
    this.totalHours = 0.0,
    this.grossWage = 0.0,
    this.netWage = 0.0,
    this.isSpecialDay = false,
    this.wagePercentages,
  });

  String? get dayOfWeek => startTime != null ? DateFormat('E').format(startTime!) : null;
  Duration? get duration => startTime != null && endTime != null ? endTime!.difference(startTime!) : null;

  TimeOfDay? get startTimeOfDay => startTime != null 
      ? TimeOfDay(hour: startTime!.hour, minute: startTime!.minute) 
      : null;

  TimeOfDay? get endTimeOfDay => endTime != null 
      ? TimeOfDay(hour: endTime!.hour, minute: endTime!.minute) 
      : null;

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'],
      date: DateTime.parse(json['date']),
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time']) : null,
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      note: json['note'],
      totalHours: json['total_hours']?.toDouble() ?? 0.0,
      grossWage: json['gross_wage']?.toDouble() ?? 0.0,
      netWage: json['net_wage']?.toDouble() ?? 0.0,
      isSpecialDay: json['is_special_day'] ?? false,
      wagePercentages: json['wage_percentages'] != null 
          ? Map<String, double>.from(json['wage_percentages'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'note': note,
      'total_hours': totalHours,
      'gross_wage': grossWage,
      'net_wage': netWage,
      'is_special_day': isSpecialDay,
      'wage_percentages': wagePercentages,
    };
  }

  static DateTime? combineDateWithTimeOfDay(DateTime date, TimeOfDay? timeOfDay) {
    if (timeOfDay == null) return null;
    return DateTime(
      date.year,
      date.month,
      date.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
  }
}
