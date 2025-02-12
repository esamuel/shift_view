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
      id: json['id'] as String? ?? '',
      hoursThreshold: (json['hoursThreshold'] as num?)?.toDouble() ?? 0.0,
      rate: (json['rate'] as num?)?.toDouble() ?? 1.0,
      isForSpecialDays: json['isForSpecialDays'] as bool? ?? false,
      appliesOnWeekends: json['appliesOnWeekends'] ?? false,
      appliesOnFestiveDays: json['appliesOnFestiveDays'] ?? false,
    );
  }

  @override
  String toString() {
    return 'OvertimeRule(id: $id, hoursThreshold: $hoursThreshold, rate: $rate, isForSpecialDays: $isForSpecialDays, appliesOnWeekends: $appliesOnWeekends, appliesOnFestiveDays: $appliesOnFestiveDays)';
  }

  OvertimeRule copyWith({
    String? id,
    double? hoursThreshold,
    double? rate,
    bool? isForSpecialDays,
    bool? appliesOnWeekends,
    bool? appliesOnFestiveDays,
  }) {
    return OvertimeRule(
      id: id ?? this.id,
      hoursThreshold: hoursThreshold ?? this.hoursThreshold,
      rate: rate ?? this.rate,
      isForSpecialDays: isForSpecialDays ?? this.isForSpecialDays,
      appliesOnWeekends: appliesOnWeekends ?? this.appliesOnWeekends,
      appliesOnFestiveDays: appliesOnFestiveDays ?? this.appliesOnFestiveDays,
    );
  }
}
