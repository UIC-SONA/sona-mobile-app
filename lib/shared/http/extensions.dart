import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:sona/shared/extensions.dart';
import 'package:sona/shared/json.dart';

import 'types.dart';

extension BaseResponseExtension on BaseResponse {
  //
  get informational => status.statusClass == HttpStatusClass.informational;

  get successful => status.statusClass == HttpStatusClass.success;

  get redirection => status.statusClass == HttpStatusClass.redirection;

  get clientError => status.statusClass == HttpStatusClass.clientError;

  get serverError => status.statusClass == HttpStatusClass.serverError;

  get ok => [HttpStatusClass.informational, HttpStatusClass.success, HttpStatusClass.redirection].contains(status.statusClass);

  get error => [HttpStatusClass.clientError, HttpStatusClass.serverError].contains(status.statusClass);

  HttpStatusCode get status => HttpStatusCode.fromCode(statusCode);
}

extension ResponseExtension on Response {
  T getBody<T>() {
    if (T == Uint8List) return bodyBytes as T;
    return _getBodyFromString<T>(body);
  }
}

extension StreamedResponseExtension on StreamedResponse {
  //
  Future<T> getBody<T>() async {
    final body = await stream.toBytes();
    if (T == Uint8List) return body as T;
    return _getBodyFromString<T>(utf8.decode(body));
  }
}

T _getBodyFromString<T>(String body) {
  if (T == String) return body as T;
  if (T == dynamic) return jsonDecode(body) as T;
  if (StringExtension.supportParse(T)) {
    return _typeIsNullable(T) ? body.tryParse<T>() as T : body.parse<T>();
  }
  return Json.deserialize<T>(body);
}

bool _typeIsNullable(Type type) => type.toString().endsWith('?');
