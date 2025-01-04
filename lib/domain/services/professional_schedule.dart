import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/providers/auth.dart';
import 'package:sona/domain/providers/locale.dart';
import 'package:sona/shared/constants.dart';
import 'package:sona/shared/http/http.dart';
import 'package:http/http.dart' as http;

abstract class ProfessionalScheduleService {
  //
  Future<List<ProfessionalSchedule>> professionalSchedules(User professional, DateTime from, DateTime to);
}

class ApiProfessionalScheduleService extends ProfessionalScheduleService implements WebResource {
  //
  final AuthProvider authProvider;
  final LocaleProvider localeProvider;

  ApiProfessionalScheduleService({required this.authProvider, required this.localeProvider});

  @override
  Uri get uri => apiUri;

  @override
  http.Client? get client => authProvider.client;

  @override
  Map<String, String> get commonHeaders => {};

  @override
  String get path => '/professional-schedule';

  @override
  Future<List<ProfessionalSchedule>> professionalSchedules(User professional, DateTime from, DateTime to) async {
    final response = await request(
      apiUri.replace(path: '$path/professional/${professional.id}', queryParameters: {
        'professionalId': professional.id.toString(),
        'from': from.toIso8601String().split('T').first,
        'to': to.toIso8601String().split('T').first,
      }),
      client: client!,
      headers: commonHeaders,
    );

    return response.getBody<List<ProfessionalSchedule>>();
  }
}
