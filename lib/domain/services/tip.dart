import 'dart:typed_data';

import 'package:sona/domain/models/tip.dart';
import 'package:sona/shared/constants.dart';
import 'package:sona/shared/http/http.dart';

import 'auth.dart';

abstract class TipService {
  //
  Future<List<Tip>> activeTips();

  Future<Uint8List> tipImage(String tipId);
}

class ApiTipService implements TipService {
  //
  final AuthProvider authProvider;

  ApiTipService({required this.authProvider});

  @override
  Future<List<Tip>> activeTips() async {
    final response = await request(
      apiUri.replace(path: '/content/tips/active'),
      client: authProvider.client!,
      method: HttpMethod.get,
      headers: {'Content-Type': 'application/json'},
    );

    return response.getBody<List<Tip>>();
  }

  @override
  Future<Uint8List> tipImage(String tipId) async {
    final response = await request(
      apiUri.replace(path: '/content/tips/$tipId/image'),
      client: authProvider.client!,
      method: HttpMethod.get,
    );

    return response.bodyBytes;
  }
}
