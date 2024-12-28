import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:menstrual_cycle_widget/menstrual_cycle_widget.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/providers/auth.dart';
import 'package:sona/domain/providers/locale.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/shared/constants.dart';
import 'package:sona/shared/http/http.dart';
import 'package:http/http.dart' as http;

final dateFormat = DateFormat('yyyy-MM-dd');
final _log = Logger();

abstract class MenstrualCycleService {
  UserService get userService;

  late final MenstrualCycleWidget instance;

  MenstrualCycleService() {
    final instance = MenstrualCycleWidget.instance;
    if (instance == null) {
      throw Exception('MenstrualCycleWidget not initialized');
    }
    this.instance = instance;
  }

  Future<void> init() async {
    try {
      final cycleData = await getCycleData();
      _log.d('Initializing MenstrualCycleWidget with cycleData: $cycleData');

      instance.updateConfiguration(
        cycleLength: cycleData.cycleLength,
        periodDuration: cycleData.periodDuration,
        customerId: userService.currentUser.keycloakId,
      );

      final periodLogs = cycleData.periodDates;
      await instance.clearPeriodLog();
      final dbHelper = MenstrualCycleDbHelper.instance;
      await dbHelper.insertPeriodLog(periodLogs);
    } catch (e, s) {
      _log.e('Error initializing MenstrualCycleWidget', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<CycleData> getCycleData() async {
    final cycleDetails = await _getCycleData();
    if (cycleDetails == null) {
      return CycleData(
        periodDuration: defaultPeriodDuration,
        cycleLength: defaultCycleLength,
      );
    }
    return cycleDetails;
  }

  Future<void> saveCycleDetails({required int periodDuration, required int cycleLength}) async {
    await _saveCycleDetails(
      cycleLength: cycleLength,
      periodDuration: periodDuration,
    );
    instance.updateConfiguration(
      cycleLength: cycleLength,
      periodDuration: periodDuration,
      customerId: userService.currentUser.keycloakId,
    );
  }

  Future<void> savePeriodDates() async {
    final dbHelper = MenstrualCycleDbHelper.instance;
    final periodDates = (await dbHelper.getPastPeriodDates()).map(dateFormat.parse).toList();
    await _savePeriodDates(periodDates);
  }

  Future<CycleData?> _getCycleData();

  Future<void> _saveCycleDetails({required int periodDuration, required int cycleLength});

  Future<void> _savePeriodDates(List<DateTime> periodDates);
}

class MenstrualCycleServiceImpl extends MenstrualCycleService implements WebResource {
  @override
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
  Future<CycleData?> _getCycleData() async {
    return onNotFound(
      fetch: () async {
        final response = await request(
          uri.replace(path: path),
          client: client,
          method: HttpMethod.get,
          headers: commonHeaders,
        );
        print("asdsadsad---> ${response.body}");

        return response.getBody<CycleData>();
      },
      onNotFound: () {
        _log.w('Cycle data not found');
        return null;
      },
    );
  }

  @override
  Future<void> _saveCycleDetails({required int periodDuration, required int cycleLength}) async {
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
  Future<void> _savePeriodDates(List<DateTime> periodDates) async {
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
