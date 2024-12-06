import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:sona/domain/models/tip.dart';
import 'package:sona/domain/providers/locale.dart';
import 'package:sona/shared/constants.dart';
import 'package:sona/shared/http/http.dart';
import 'package:sona/shared/schemas/page.dart';

import '../providers/auth.dart';

abstract class TipService {
  //
  Future<List<Tip>> actives();

  Future<Page<Tip>> activesPage([PageQuery? query]);

  Future<Uint8List> tipImage(String tipId);
}

class ApiTipService implements TipService, WebResource {
  //
  final AuthProvider authProvider;
  final LocaleProvider localeProvider;

  ApiTipService({required this.authProvider, required this.localeProvider});

  @override
  http.Client? get client => authProvider.client;

  @override
  Map<String, String> get headers => {
        'Accept-Language': localeProvider.languageCode,
      };

  @override
  String get path => '/content/tips';

  @override
  Uri get uri => apiUri;

  @override
  Future<List<Tip>> actives() async {
    final response = await request(
      uri.replace(path: '$path/actives'),
      client: client,
      method: HttpMethod.get,
      headers: headers,
    );

    return response.getBody<List<Tip>>();
  }

  @override
  Future<Page<Tip>> activesPage([PageQuery? query]) async {
    final response = await request(
      uri.replace(path: '$path/page', queryParameters: query?.toQueryParameters()),
      client: client,
      method: HttpMethod.get,
      headers: headers,
    );

    return response.getBody<PageMap>().as<Tip>();
  }

  @override
  Future<Uint8List> tipImage(String tipId) async {
    final response = await request(
      uri.replace(path: '$path/$tipId/image'),
      client: authProvider.client!,
      method: HttpMethod.get,
      headers: headers,
    );

    return response.bodyBytes;
  }
}
