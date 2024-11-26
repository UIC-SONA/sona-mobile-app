class MenstrualCycle {
  final int periodDuration;
  final int cycleDuration;
  final DateTime lastPeriodDate;

  MenstrualCycle({
    required this.periodDuration,
    required this.cycleDuration,
    required this.lastPeriodDate,
  });

  factory MenstrualCycle.fromJson(Map<String, dynamic> json) {
    return MenstrualCycle(
      periodDuration: json['periodDuration'],
      cycleDuration: json['cycleDuration'],
      lastPeriodDate: DateTime.parse(json['lastPeriodDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'periodDuration': periodDuration,
      'cycleDuration': cycleDuration,
      'lastPeriodDate': lastPeriodDate.toIso8601String(),
    };
  }
}
