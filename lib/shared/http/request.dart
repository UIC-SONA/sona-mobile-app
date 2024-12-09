import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:sona/shared/http/extensions.dart';

import 'exceptions.dart';
import 'types.dart';

const Duration kHttpRequestTimeout = Duration(seconds: 60);
final Logger _log = Logger(level: Level.error);

Future<Response> request(Uri url, {
  HttpMethod method = HttpMethod.get,
  Object? body,
  Map<String, String>? headers,
  Encoding? encoding,
  Client? client,
  bool truncateLogBody = false,
}) async {
  try {
    _log.d("Send request to $url: \nMethod: $method\nHeaders: $headers\nBody: $body");

    final Response response = await _sendRequest(url, method, headers, body, encoding, client).timeout(
      kHttpRequestTimeout,
      onTimeout: () => throw TimeoutException("Time out occurred while sending request $method to $url", kHttpRequestTimeout),
    );

    if (response.error) {
      throw HttpException(response.status.message, response: response);
    }

    return response;
  } on HttpException {
    rethrow;
  } catch (e, s) {
    final description = "${e.runtimeType} error occurred";
    _log.e(description, error: e, stackTrace: s);
    throw HttpException(description, innerError: e);
  }
}

Future<Response> _sendRequest(Uri url, HttpMethod method, Map<String, String>? headers, Object? body, Encoding? encoding, Client? client) async {
  return await switch (method) {
    HttpMethod.get => client == null ? get(url, headers: headers) : client.get(url, headers: headers),
    HttpMethod.post => client == null ? post(url, headers: headers, body: body, encoding: encoding) : client.post(url, headers: headers, body: body, encoding: encoding),
    HttpMethod.put => client == null ? put(url, headers: headers, body: body, encoding: encoding) : client.put(url, headers: headers, body: body, encoding: encoding),
    HttpMethod.delete => client == null ? delete(url, headers: headers) : client.delete(url, headers: headers),
    HttpMethod.patch => client == null ? patch(url, headers: headers, body: body, encoding: encoding) : client.patch(url, headers: headers, body: body, encoding: encoding),
  };
}
