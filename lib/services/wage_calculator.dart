import '../models/shift.dart';
import '../models/overtime_rule.dart';

class WageCalculator {
  final double baseHourlyWage;
  final double taxDeductionPercentage;
  final List<OvertimeRule> overtimeRules;
  final bool startWorkWeekOnSunday;

  WageCalculator({
    required this.baseHourlyWage,
    required this.taxDeductionPercentage,
    required this.overtimeRules,
    this.startWorkWeekOnSunday = true,
  });

  /// Calculates the gross wage for a given shift based on the shift duration, hourly wage, and overtime rules.
  ///
  /// For a regular workday (non-special day), the calculations are:
  /// - First 8 hours at regular rate (1x): baseHourlyWage * hours (up to 8 hours)
  /// - Next 2 hours (8-10 hours) at 1.25x: (hours - 8) * baseHourlyWage * 1.25
  /// - Hours beyond 10 at 1.5x: (hours - 10) * baseHourlyWage * 1.5
  ///
  /// Example (Regular Workday, 12 hours, hourly wage = 40.04):
  ///   8 hours: 8 * 40.04 = 320.32
  ///   2 hours at 1.25x: 2 * 40.04 * 1.25 = 100.10
  ///   2 hours at 1.5x: 2 * 40.04 * 1.5 = 120.12
  ///   Total = 320.32 + 100.10 + 120.12 = 540.54
  ///
  /// For a weekend or special day, the calculations are:
  /// - First 8 hours at 1.5x: baseHourlyWage * hours * 1.5 (up to 8 hours)
  /// - Next 2 hours (8-10 hours) at 1.75x: (hours - 8) * baseHourlyWage * 1.75
  /// - Hours beyond 10 at 2x: (hours - 10) * baseHourlyWage * 2.0
  ///
  /// Example (Weekend/Special Day, 12 hours, hourly wage = 40.04):
  ///   8 hours: 8 * 40.04 * 1.5 = 480.48
  ///   2 hours at 1.75x: 2 * 40.04 * 1.75 = 140.14
  ///   2 hours at 2x: 2 * 40.04 * 2.0 = 160.16
  ///   Total = 480.48 + 140.14 + 160.16 = 780.78

  double calculateShiftWage(Shift shift) {
    if (shift.startTime == null || shift.endTime == null) {
      return 0.0;
    }

    // Handle overnight shift duration calculation
    DateTime endTime = shift.endTime!;
    if (endTime.isBefore(shift.startTime!)) {
      // If end time is before start time, add 1 day to end time
      endTime = endTime.add(const Duration(days: 1));
    }

    final duration = endTime.difference(shift.startTime!);
    final hours = duration.inMinutes / 60.0;
    const double baseHours = 8.0;
    double wage = 0.0;

    // Check if shift crosses midnight
    bool crossesMidnight = shift.endTime!.day != shift.startTime!.day;

    // Determine if this is a special day (weekend or marked special)
    bool isWeekend = _isWeekend(shift.date);
    bool isSpecial = shift.isSpecialDay || isWeekend;

    print('\n=== DETAILED WAGE CALCULATION FOR ${shift.date} ===');
    print('Start time: ${shift.startTime}');
    print('End time: ${shift.endTime}');
    print('Adjusted end time: $endTime');
    print('Crosses midnight: $crossesMidnight');
    print('Hours worked: $hours');
    print('Base hourly wage: ₪$baseHourlyWage');
    print('Is weekend: $isWeekend');
    print('Is marked special: ${shift.isSpecialDay}');
    print('Final isSpecial: $isSpecial');
    print('Start day: ${shift.date.weekday}');
    if (crossesMidnight) {
      print('End day: ${shift.endTime!.weekday}');
    }

    if (isSpecial) {
      // Special day calculation (weekends/holidays)
      print('\nSPECIAL DAY CALCULATION:');

      // First 8 hours at 1.5x
      double baseHours = hours <= 8.0 ? hours : 8.0;
      double baseHoursPay = baseHours * baseHourlyWage * 1.5;
      wage += baseHoursPay;
      print('1. First 8 hours at 1.5x:');
      print('   Hours: $baseHours');
      print('   Rate: 1.5x');
      print('   Amount: ₪$baseHoursPay');

      if (hours > 8.0) {
        // Hours 8-10 at 1.75x
        double overtimeHours = hours <= 10.0 ? hours - 8.0 : 2.0;
        double overtimePay = overtimeHours * baseHourlyWage * 1.75;
        wage += overtimePay;
        print('\n2. Hours 8-10 at 1.75x:');
        print('   Hours: $overtimeHours');
        print('   Rate: 1.75x');
        print('   Amount: ₪$overtimePay');

        // Hours beyond 10 at 2.0x
        if (hours > 10.0) {
          double extraHours = hours - 10.0;
          double extraPay = extraHours * baseHourlyWage * 2.0;
          wage += extraPay;
          print('\n3. Hours beyond 10 at 2.0x:');
          print('   Hours: $extraHours');
          print('   Rate: 2.0x');
          print('   Amount: ₪$extraPay');
        }
      }
    } else {
      // Regular day calculation
      print('\nREGULAR DAY CALCULATION:');

      // First 8 hours at regular rate
      double baseHours = hours <= 8.0 ? hours : 8.0;
      double baseHoursPay = baseHours * baseHourlyWage;
      wage += baseHoursPay;
      print('1. First 8 hours at 1.0x:');
      print('   Hours: $baseHours');
      print('   Rate: 1.0x');
      print('   Amount: ₪$baseHoursPay');

      if (hours > 8.0) {
        // Hours 8-10 at 1.25x
        double overtimeHours = hours <= 10.0 ? hours - 8.0 : 2.0;
        double overtimePay = overtimeHours * baseHourlyWage * 1.25;
        wage += overtimePay;
        print('\n2. Hours 8-10 at 1.25x:');
        print('   Hours: $overtimeHours');
        print('   Rate: 1.25x');
        print('   Amount: ₪$overtimePay');

        // Hours beyond 10 at 1.5x
        if (hours > 10.0) {
          double extraHours = hours - 10.0;
          double extraPay = extraHours * baseHourlyWage * 1.5;
          wage += extraPay;
          print('\n3. Hours beyond 10 at 1.5x:');
          print('   Hours: $extraHours');
          print('   Rate: 1.5x');
          print('   Amount: ₪$extraPay');
        }
      }
    }

    print('\nFINAL CALCULATION:');
    print('Total Gross Wage: ₪$wage');
    print('===============================\n');
    return wage;
  }

  double calculateNetWage(double grossWage) {
    final taxDeduction = grossWage * (taxDeductionPercentage / 100);
    return grossWage - taxDeduction;
  }

  Map<String, double> calculateWeeklyWages(List<Shift> shifts) {
    double totalGrossWage = 0.0;
    double totalNetWage = 0.0;
    double totalHours = 0.0;
    Map<double, double> hoursPerRate = {
      1.0: 0.0, // Regular rate
      1.25: 0.0, // First overtime rate
      1.5: 0.0, // Second overtime rate / Special day base
      1.75: 0.0, // Special day first overtime
      2.0: 0.0 // Special day second overtime
    };

    for (final shift in shifts) {
      if (shift.startTime == null || shift.endTime == null) continue;

      final duration = shift.duration;
      final hours = (duration?.inMinutes ?? 0) / 60.0;
      totalHours += hours;

      bool isSpecialDay = shift.isSpecialDay || _isWeekend(shift.date);

      if (isSpecialDay) {
        // Special day hours breakdown
        if (hours <= 8) {
          hoursPerRate[1.5] = (hoursPerRate[1.5] ?? 0.0) + hours;
        } else if (hours <= 10) {
          hoursPerRate[1.5] = (hoursPerRate[1.5] ?? 0.0) + 8;
          hoursPerRate[1.75] = (hoursPerRate[1.75] ?? 0.0) + (hours - 8);
        } else {
          hoursPerRate[1.5] = (hoursPerRate[1.5] ?? 0.0) + 8;
          hoursPerRate[1.75] = (hoursPerRate[1.75] ?? 0.0) + 2;
          hoursPerRate[2.0] = (hoursPerRate[2.0] ?? 0.0) + (hours - 10);
        }
      } else {
        // Regular day hours breakdown
        if (hours <= 8) {
          hoursPerRate[1.0] = (hoursPerRate[1.0] ?? 0.0) + hours;
        } else if (hours <= 10) {
          hoursPerRate[1.0] = (hoursPerRate[1.0] ?? 0.0) + 8;
          hoursPerRate[1.25] = (hoursPerRate[1.25] ?? 0.0) + (hours - 8);
        } else {
          hoursPerRate[1.0] = (hoursPerRate[1.0] ?? 0.0) + 8;
          hoursPerRate[1.25] = (hoursPerRate[1.25] ?? 0.0) + 2;
          hoursPerRate[1.5] = (hoursPerRate[1.5] ?? 0.0) + (hours - 10);
        }
      }

      totalGrossWage += calculateShiftWage(shift);
    }

    totalNetWage = calculateNetWage(totalGrossWage);

    return {
      'grossWage': totalGrossWage,
      'netWage': totalNetWage,
      'totalHours': totalHours,
      ...hoursPerRate.map((rate, hours) =>
          MapEntry('hoursAt${(rate * 100).toInt()}Percent', hours)),
    };
  }

  bool _shouldApplyRule(OvertimeRule rule, Shift shift) {
    bool isSpecialDay = shift.isSpecialDay || _isWeekend(shift.date);
    return isSpecialDay ? rule.isForSpecialDays : !rule.isForSpecialDays;
  }

  bool _isWeekend(DateTime date) {
    print('\nChecking weekend for date: ${date}');
    print('Day of week: ${date.weekday}');
    print('Start work week on Sunday: $startWorkWeekOnSunday');

    if (startWorkWeekOnSunday) {
      // For Israel (work week starts on Sunday)
      // Only Saturday (7) is weekend
      bool isWeekend = date.weekday == DateTime.saturday;
      print('Is weekend (Saturday only): $isWeekend');
      return isWeekend;
    } else {
      // For other countries (work week starts on Monday)
      // Both Saturday (7) and Sunday (1) are weekend
      bool isWeekend =
          date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
      print('Is weekend (Saturday or Sunday): $isWeekend');
      return isWeekend;
    }
  }

  DateTime getStartOfWeek(DateTime date) {
    final weekday = date.weekday;
    final daysToSubtract = startWorkWeekOnSunday
        ? weekday == DateTime.sunday
            ? 0
            : weekday
        : weekday - 1;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysToSubtract));
  }

  DateTime getEndOfWeek(DateTime date) {
    final startOfWeek = getStartOfWeek(date);
    return startOfWeek
        .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
  }

  double calculateExampleWage() {
    double mondayWage = 0.0;
    double saturdayWage = 0.0;

    // Monday calculation (7 hours, regular day)
    mondayWage = 7 * baseHourlyWage;
    print('Monday Wage (7 hours): $mondayWage');

    // Saturday calculation (12 hours, special day)
    double saturdayBaseHours = 8.0;
    double saturdayOvertimeHours = 12 - saturdayBaseHours;
    double saturdayWageBase = saturdayBaseHours * baseHourlyWage * 1.5;
    double saturdayWageOvertime = 0.0;

    if (saturdayOvertimeHours > 0) {
      double firstTierHours =
          saturdayOvertimeHours > 2 ? 2 : saturdayOvertimeHours;
      saturdayWageOvertime += firstTierHours * baseHourlyWage * 1.75;
      saturdayOvertimeHours -= firstTierHours;

      if (saturdayOvertimeHours > 0) {
        saturdayWageOvertime += saturdayOvertimeHours * baseHourlyWage * 2.0;
      }
    }

    saturdayWage = saturdayWageBase + saturdayWageOvertime;
    print('Saturday Wage (12 hours): $saturdayWage');

    return mondayWage + saturdayWage;
  }
}
