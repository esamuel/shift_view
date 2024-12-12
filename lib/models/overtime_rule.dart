class OvertimeRule {
  final String id;
  final double hoursThreshold;
  final double rate;
  final bool isForSpecialDays;
  final bool appliesOnWeekends;
  final bool appliesOnFestiveDays;

  OvertimeRule({
    required this.id,
    required this.hoursThreshold,
    required this.rate,
    this.isForSpecialDays = false,
    this.appliesOnWeekends = false,
    this.appliesOnFestiveDays = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hoursThreshold': hoursThreshold,
      'rate': rate,
      'isForSpecialDays': isForSpecialDays,
      'appliesOnWeekends': appliesOnWeekends,
      'appliesOnFestiveDays': appliesOnFestiveDays,
    };
  }

  factory OvertimeRule.fromJson(Map<String, dynamic> json) {
    return OvertimeRule(
      id: json['id'],
      hoursThreshold: json['hoursThreshold']?.toDouble() ?? 0.0,
      rate: json['rate']?.toDouble() ?? 1.0,
      isForSpecialDays: json['isForSpecialDays'] ?? false,
      appliesOnWeekends: json['appliesOnWeekends'] ?? false,
      appliesOnFestiveDays: json['appliesOnFestiveDays'] ?? false,
    );
  }

  @override
  String toString() {
    return 'OvertimeRule(id: $id, hoursThreshold: $hoursThreshold, rate: $rate, isForSpecialDays: $isForSpecialDays, appliesOnWeekends: $appliesOnWeekends, appliesOnFestiveDays: $appliesOnFestiveDays)';
  }
}
