import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sona/application/common/auth/oauth2.dart' as oauth2;
import 'package:sona/application/common/http/http.dart';
import 'package:sona/application/common/models/models.dart';
import 'package:sona/features/menstrualcalendar/models/models.dart';

final apiUri = Uri.parse(dotenv.env['API_URI']!);

Future<Message> saveCycle(MenstrualCycle cycle) async {
  final response = await request(
    apiUri.replace(path: '/menstrual-calendar/cycle'),
    client: await oauth2.getInstance(),
    method: HttpMethod.post,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(cycle),
  );

  return response.getBody<Message>();
}

Future<MenstrualCycle> getCycle() async {
  final response = await request(
    apiUri.replace(path: '/menstrual-calendar/cycle'),
    client: await oauth2.getInstance(),
    method: HttpMethod.get,
  );

  return response.getBody<MenstrualCycle>();
}
