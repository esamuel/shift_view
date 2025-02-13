import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Shift {
  final String id;
  final DateTime date;
  final DateTime? startTime;
  final DateTime? endTime;
  final double totalHours;
  final double grossWage;
  final double netWage;
  final String note;
  final bool isSpecialDay;

  Shift({
    String? id,
    required this.date,
    this.startTime,
    this.endTime,
    required this.totalHours,
    required this.grossWage,
    required this.netWage,
    this.note = '',
    this.isSpecialDay = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  String? get dayOfWeek =>
      startTime != null ? DateFormat('E').format(startTime!) : null;

  Duration? get duration {
    if (startTime == null || endTime == null) return null;

    // Handle overnight shifts
    DateTime adjustedEndTime = endTime!;
    if (endTime!.isBefore(startTime!)) {
      // If end time is before start time, add 1 day to end time
      adjustedEndTime = endTime!.add(const Duration(days: 1));
    }

    return adjustedEndTime.difference(startTime!);
  }

  TimeOfDay? get startTimeOfDay => startTime != null
      ? TimeOfDay(hour: startTime!.hour, minute: startTime!.minute)
      : null;

  TimeOfDay? get endTimeOfDay => endTime != null
      ? TimeOfDay(hour: endTime!.hour, minute: endTime!.minute)
      : null;

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'totalHours': totalHours,
      'grossWage': grossWage,
      'netWage': netWage,
      'note': note,
      'isSpecialDay': isSpecialDay,
    };
  }

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] as String?,
      date: DateTime.parse(json['date'] as String),
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      totalHours: (json['totalHours'] as num).toDouble(),
      grossWage: (json['grossWage'] as num).toDouble(),
      netWage: (json['netWage'] as num).toDouble(),
      note: json['note'] as String? ?? '',
      isSpecialDay: json['isSpecialDay'] as bool? ?? false,
    );
  }

  Shift copyWith({
    String? id,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    double? totalHours,
    double? grossWage,
    double? netWage,
    String? note,
    bool? isSpecialDay,
  }) {
    return Shift(
      id: id ?? this.id,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalHours: totalHours ?? this.totalHours,
      grossWage: grossWage ?? this.grossWage,
      netWage: netWage ?? this.netWage,
      note: note ?? this.note,
      isSpecialDay: isSpecialDay ?? this.isSpecialDay,
    );
  }

  static DateTime? combineDateWithTimeOfDay(
      DateTime date, TimeOfDay? timeOfDay) {
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
