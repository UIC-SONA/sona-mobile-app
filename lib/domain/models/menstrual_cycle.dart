import 'package:intl/intl.dart';

final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

class CycleData {
  final int periodDuration;
  final int cycleLength;
  final List<DateTime> periodDates;

  CycleData({
    required this.periodDuration,
    required this.cycleLength,
    this.periodDates = const [],
  });

  factory CycleData.fromJson(Map<String, dynamic> json) {
    print("asdsadsad $json");
    return CycleData(
      periodDuration: json['periodDuration'],
      cycleLength: json['cycleLength'],
      periodDates: (json['periodDates'] as List).map((e) => dateFormat.parse(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'periodDuration': periodDuration,
      'cycleLength': cycleLength,
      'periodDates': periodDates.map((e) => dateFormat.format(e)).toList(),
    };
  }

  @override
  String toString() {
    return 'CycleData(periodDuration: $periodDuration, cycleLength: $cycleLength, periodDates: $periodDates)';
  }
}
