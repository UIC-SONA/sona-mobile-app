import 'package:flutter/material.dart';
import 'package:http_image_provider/http_image_provider.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/providers/auth.dart';
import 'package:sona/domain/providers/locale.dart';
import 'package:sona/shared/constants.dart';
import 'package:sona/shared/crud.dart';
import 'package:sona/shared/rest_crud.dart';
import 'package:http/http.dart';

mixin DidacticContentService implements ReadOperations<DidaticContent, String> {
  ImageProvider<Object> image(String didaticContentId);
}

class ApiDidacticContentService extends RestReadOperations<DidaticContent, String> with DidacticContentService {
  final AuthProvider authProvider;
  final LocaleProvider localeProvider;

  ApiDidacticContentService({required this.authProvider, required this.localeProvider});

  @override
  Client? get client => authProvider.client;

  @override
  Uri get uri => apiUri;

  @override
  Map<String, String> get commonHeaders => {'Accept-Language': localeProvider.languageCode};

  @override
  String get path => '/content/didactic';

  @override
  ImageProvider<Object> image(String didaticContentId) {
    return HttpImageProvider(
      uri.replace(path: '$path/$didaticContentId/image'),
      client: client,
      headers: commonHeaders,
    );
  }
}
