import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/providers/auth.dart';
import 'package:sona/domain/providers/locale.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/shared/constants.dart';
import 'package:sona/shared/http/http.dart';
import 'package:http/http.dart' as http;
import 'package:sona/ui/widgets/menstrual_cycle/menstrual_cycle.dart';

final dateFormat = DateFormat('yyyy-MM-dd');

abstract class MenstrualCycleService {
//  UserService get userService;

  Future<CycleData> getCycleData();

  Future<void> saveCycleDetails({required int periodDuration, required int cycleLength});

  Future<void> savePeriodDates(List<DateTime> periodDates);
}

class MenstrualCycleServiceImpl extends MenstrualCycleService implements WebResource {
//
  final UserService userService;
  final AuthProvider authProvider;
  final LocaleProvider localeProvider;

  MenstrualCycleServiceImpl({
    required this.userService,
    required this.authProvider,
    required this.localeProvider,
  });

  @override
  http.Client? get client => authProvider.client;

  @override
  String get path => '/menstrual-cycle';

  @override
  Uri get uri => apiUri;

  @override
  Map<String, String> get commonHeaders => {'Accept-Language': localeProvider.languageCode};

  @override
  Future<CycleData> getCycleData() async {
    return onNotFound(
      fetch: () async {
        final response = await request(
          uri.replace(path: path),
          client: client,
          method: HttpMethod.get,
          headers: commonHeaders,
        );
        return response.getBody<CycleData>();
      },
      onNotFound: () {
        return CycleData(
          periodDuration: defaultPeriodLength,
          cycleLength: defaultCycleLength,
        );
      },
    );
  }

  @override
  Future<void> saveCycleDetails({required int periodDuration, required int cycleLength}) async {
    await request(
      uri.replace(path: '$path/details'),
      client: client,
      method: HttpMethod.post,
      headers: {
        ...commonHeaders,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'periodDuration': periodDuration,
        'cycleLength': cycleLength,
      }),
    );
  }

  @override
  Future<void> savePeriodDates(List<DateTime> periodDates) async {
    await request(
      uri.replace(path: '$path/period-logs'),
      client: client,
      method: HttpMethod.post,
      headers: {
        ...commonHeaders,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(periodDates.map(dateFormat.format).toList()),
    );
  }
}
