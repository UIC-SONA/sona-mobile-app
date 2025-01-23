import 'package:flutter/material.dart' hide Page;
import 'package:http/http.dart' as http;
import 'package:http_image_provider/http_image_provider.dart';
import 'package:sona/domain/models/tip.dart';
import 'package:sona/domain/providers/locale.dart';
import 'package:sona/shared/constants.dart';
import 'package:sona/shared/crud.dart';
import 'package:sona/shared/http/http.dart';
import 'package:sona/shared/rest_crud.dart';
import 'package:sona/shared/schemas/message.dart';
import 'package:sona/shared/schemas/page.dart';

import '../providers/auth.dart';

abstract class TipService implements ReadOperations<Tip, String> {
  Future<Page<Tip>> actives([PageQuery? query]);

  ImageProvider<Object> image(Tip tip);

  Future<Message> rate(Tip tip, int value);
}

class ApiTipService extends RestReadOperations<Tip, String> implements TipService, WebResource {
  //
  final AuthProvider authProvider;
  final LocaleProvider localeProvider;

  ApiTipService({required this.authProvider, required this.localeProvider});

  @override
  http.Client? get client => authProvider.client;

  @override
  Map<String, String> get commonHeaders => {
        'Accept-Language': localeProvider.languageCode,
      };

  @override
  String get path => '/content/tips';

  @override
  Uri get uri => apiUri;

  @override
  Future<Page<Tip>> actives([PageQuery? query]) async {
    final response = await request(
      uri.replace(path: '$path/actives', queryParameters: query?.toQueryParameters()),
      client: client,
      method: HttpMethod.get,
      headers: commonHeaders,
    );

    return response.getBody<PageMap>().as<Tip>();
  }

  @override
  ImageProvider<Object> image(Tip tip) {
    return HttpImageProvider(
      uri.replace(path: '$path/${tip.id}/image'),
      headers: commonHeaders,
      client: client,
    );
  }

  @override
  Future<Message> rate(Tip tip, int value) async {
    final response = await request(
      uri.replace(path: '$path/rate/${tip.id}'),
      client: client,
      method: HttpMethod.post,
      headers: commonHeaders,
      body: {
        'value': value.toString(),
      },
    );

    return response.getBody<Message>();
  }
}
