import 'package:sona/domain/models/models.dart';

class ProfessionalSchedule {
  DateTime date;
  int fromHour;
  int toHour;
  User professional;

  ProfessionalSchedule({
    required this.date,
    required this.fromHour,
    required this.toHour,
    required this.professional,
  });

  factory ProfessionalSchedule.fromJson(Map<String, dynamic> json) {
    return ProfessionalSchedule(
      date: DateTime.parse(json['date'] as String),
      fromHour: json['fromHour'] as int,
      toHour: json['toHour'] as int,
      professional: User.fromJson(json['professional'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'fromHour': fromHour,
      'toHour': toHour,
      'professional': professional.toJson(),
    };
  }
}
