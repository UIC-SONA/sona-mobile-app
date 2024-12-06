import 'dart:convert';

import 'package:sona/domain/models/menstrual_cycle.dart';
import 'package:sona/shared/schemas/message.dart';
import 'package:sona/domain/providers/locale.dart';
import 'package:sona/shared/constants.dart' as user;
import 'package:sona/shared/http/http.dart';

import '../providers/auth.dart';

abstract class MenstrualCalendarService {
  Future<Message> saveCycle(MenstrualCycle cycle);

  Future<MenstrualCycle> getCycle();
}

class ApiMenstrualCalendarService implements MenstrualCalendarService {
  final AuthProvider authProvider;
  final LocaleProvider localeProvider;

  ApiMenstrualCalendarService({required this.authProvider, required this.localeProvider});

  @override
  Future<Message> saveCycle(MenstrualCycle cycle) async {
    final response = await request(
      user.apiUri.replace(path: '/menstrual-calendar/cycle'),
      client: authProvider.client!,
      method: HttpMethod.post,
      headers: {
        'Content-Type': 'application/json',
        'Accept-Language': localeProvider.languageCode,
      },
      body: jsonEncode(cycle),
    );

    return response.getBody<Message>();
  }

  @override
  Future<MenstrualCycle> getCycle() async {
    final response = await request(
      user.apiUri.replace(path: '/menstrual-calendar/cycle'),
      client: authProvider.client!,
      headers: {
        'Accept-Language': localeProvider.languageCode,
      },
      method: HttpMethod.get,
    );

    return response.getBody<MenstrualCycle>();
  }
}
