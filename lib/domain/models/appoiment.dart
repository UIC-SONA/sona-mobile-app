import 'package:sona/domain/models/models.dart';
import 'package:sona/shared/extensions.dart';

class Appointment {
  final String id;
  final DateTime date;
  final int hour;
  final bool canceled;
  final String? cancelReason;
  final AppointmentType type;
  final User attendant;
  final User professional;

  Appointment({
    required this.id,
    required this.date,
    required this.hour,
    required this.canceled,
    required this.cancelReason,
    required this.type,
    required this.attendant,
    required this.professional,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      date: DateTime.parse(json['date']),
      hour: json['hour'],
      canceled: json['canceled'],
      cancelReason: json['cancelReason'],
      type: AppointmentType.values.firstWhere((e) => e.javaName == json['type']),
      attendant: User.fromJson(json['attendant']),
      professional: User.fromJson(json['professional']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'hour': hour,
      'canceled': canceled,
      'cancelReason': cancelReason,
      'type': type.toString(),
      'attendant': attendant.toJson(),
      'professional': professional.toJson(),
    };
  }
}

enum AppointmentType {
  virtual,
  presential,
}

class AppointmentRange {
  final DateTime from;
  final DateTime to;

  AppointmentRange({
    required this.from,
    required this.to,
  });

  factory AppointmentRange.fromJson(Map<String, dynamic> json) {
    return AppointmentRange(
      from: DateTime.parse(json['from']),
      to: DateTime.parse(json['to']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
    };
  }
}
