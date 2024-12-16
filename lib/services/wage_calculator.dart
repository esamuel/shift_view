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

  double calculateShiftWage(Shift shift) {
    if (shift.startTime == null || shift.endTime == null) {
      return 0.0;
    }

    final hours = shift.duration.inMinutes / 60.0;
    double totalWage = 0.0;
    double remainingHours = hours;

    // Sort overtime rules by threshold
    final sortedRules = List<OvertimeRule>.from(overtimeRules)
      ..sort((a, b) => a.hoursThreshold.compareTo(b.hoursThreshold));

    // Apply overtime rules
    for (final rule in sortedRules) {
      if (_shouldApplyRule(rule, shift)) {
        if (remainingHours > rule.hoursThreshold) {
          final overtimeHours = remainingHours - rule.hoursThreshold;
          totalWage += overtimeHours * baseHourlyWage * rule.rate;
          remainingHours = rule.hoursThreshold;
        }
      }
    }

    // Add base wage for remaining hours
    totalWage += remainingHours * baseHourlyWage;

    return totalWage;
  }

  double calculateNetWage(double grossWage) {
    final taxDeduction = grossWage * (taxDeductionPercentage / 100);
    return grossWage - taxDeduction;
  }

  Map<String, double> calculateWeeklyWages(List<Shift> shifts) {
    double totalGrossWage = 0.0;
    double totalNetWage = 0.0;
    double totalHours = 0.0;
    Map<double, double> hoursPerRate = {};

    for (final shift in shifts) {
      if (shift.startTime == null || shift.endTime == null) continue;

      final hours = shift.duration.inMinutes / 60.0;
      totalHours += hours;

      final grossWage = calculateShiftWage(shift);
      totalGrossWage += grossWage;

      // Calculate hours at different rates
      double remainingHours = hours;
      for (final rule in overtimeRules) {
        if (_shouldApplyRule(rule, shift)) {
          if (remainingHours > rule.hoursThreshold) {
            final overtimeHours = remainingHours - rule.hoursThreshold;
            hoursPerRate[rule.rate] = (hoursPerRate[rule.rate] ?? 0.0) + overtimeHours;
            remainingHours = rule.hoursThreshold;
          }
        }
      }
      hoursPerRate[1.0] = (hoursPerRate[1.0] ?? 0.0) + remainingHours;
    }

    totalNetWage = calculateNetWage(totalGrossWage);

    return {
      'grossWage': totalGrossWage,
      'netWage': totalNetWage,
      'totalHours': totalHours,
      ...hoursPerRate.map((rate, hours) => MapEntry('hoursAt${(rate * 100).toInt()}Percent', hours)),
    };
  }

  bool _shouldApplyRule(OvertimeRule rule, Shift shift) {
    if (rule.isForSpecialDays) {
      if (shift.isSpecialDay) return true;
      if (rule.appliesOnWeekends && _isWeekend(shift.date)) return true;
      // Add more conditions for festive days if needed
      return false;
    }
    return true;
  }

  bool _isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  DateTime getStartOfWeek(DateTime date) {
    final weekday = date.weekday;
    final daysToSubtract = startWorkWeekOnSunday
        ? weekday == DateTime.sunday ? 0 : weekday
        : weekday - 1;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: daysToSubtract));
  }

  DateTime getEndOfWeek(DateTime date) {
    final startOfWeek = getStartOfWeek(date);
    return startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
  }
} 