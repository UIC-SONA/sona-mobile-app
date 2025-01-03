import 'dart:convert';

import 'package:http/http.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/providers/auth.dart';
import 'package:sona/domain/providers/locale.dart';
import 'package:sona/shared/constants.dart';
import 'package:sona/shared/crud.dart';
import 'package:sona/shared/http/http.dart';
import 'package:sona/shared/schemas/page.dart';

abstract class AppoinmentService {
  Future<Appointment> program({
    required DateTime date,
    required int hour,
    required AppointmentType type,
    required User professional,
  });

  Future<Appointment> cancel({
    required Appointment appointment,
    required String reason,
  });

  Future<Page<Appointment>> appoiments([PageQuery? query]);

  Future<List<AppointmentRange>> professionalAppointmentsDates({
    required User professional,
    required DateTime from,
    required DateTime to,
  });
}

class ApiAppoinmentService extends AppoinmentService implements WebResource {
  final AuthProvider authProvider;
  final LocaleProvider localeProvider;

  ApiAppoinmentService({required this.authProvider, required this.localeProvider});

  @override
  Uri get uri => apiUri;

  @override
  Client? get client => authProvider.client;

  @override
  Map<String, String> get commonHeaders => {'Accept-Language': localeProvider.languageCode};

  @override
  String get path => '/appoinment';

  @override
  Future<Appointment> program({
    required DateTime date,
    required int hour,
    required AppointmentType type,
    required User professional,
  }) async {
    final response = await request(
      apiUri.replace(path: '$path/program'),
      client: authProvider.client!,
      method: HttpMethod.post,
      headers: {
        ...commonHeaders,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'date': date.toIso8601String(),
        'hour': hour,
        'type': type.toString(),
        'professionalId': professional.id,
      }),
    );

    return response.getBody<Appointment>();
  }

  @override
  Future<Appointment> cancel({
    required Appointment appointment,
    required String reason,
  }) async {
    final response = await request(
      apiUri.replace(path: '$path/cancel'),
      client: authProvider.client!,
      method: HttpMethod.post,
      headers: {
        ...commonHeaders,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'appointmentId': appointment.id,
        'reason': reason,
      }),
    );

    return response.getBody<Appointment>();
  }

  @override
  Future<Page<Appointment>> appoiments([PageQuery? query]) async {
    final response = await request(
      uri.replace(path: '$path/self', queryParameters: query?.toQueryParameters()),
      client: authProvider.client!,
      method: HttpMethod.get,
      headers: commonHeaders,
    );

    return response.getBody<Page<Appointment>>();
  }

  @override
  Future<List<AppointmentRange>> professionalAppointmentsDates({
    required User professional,
    required DateTime from,
    required DateTime to,
  }) async {
    final response = await request(
      uri.replace(path: '$path/professional-dates', queryParameters: {
        'professionalId': professional.id.toString(),
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      }),
      client: authProvider.client!,
      method: HttpMethod.get,
      headers: commonHeaders,
    );

    return response.getBody<List<AppointmentRange>>();
  }
}
