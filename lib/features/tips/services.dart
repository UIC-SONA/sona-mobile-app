
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sona/application/common/auth/oauth2.dart' as oauth2;
import 'package:sona/application/common/http/http.dart';

import 'models.dart';

final apiUri = Uri.parse(dotenv.env['API_URI']!);

Future<List<Tip>> listActiveTips() async {
  final response = await request(
    apiUri.replace(path: '/content/tips/active'),
    client: await oauth2.getInstance(),
    method: HttpMethod.get,
    headers: {'Content-Type': 'application/json'},
  );

  return response.getBody<List<Tip>>();
}
