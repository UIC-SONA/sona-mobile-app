import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sona/application/common/http/http.dart';
import 'package:sona/application/common/models/models.dart';

final apiUri = Uri.parse(dotenv.env['API_URI']!);

Future<Message> signup({
  required String username,
  required String password,
  required String firstName,
  required String lastName,
  required String email,
}) async {
  final response = await request(
    apiUri.replace(path: '/user/sign-up'),
    method: HttpMethod.post,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'username': username,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    }),
  );

  return response.getBody<Message>();
}
