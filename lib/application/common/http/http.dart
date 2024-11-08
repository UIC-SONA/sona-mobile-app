import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:sona/application/common/http/boundary_characters.dart';
import 'package:sona/application/common/json/json.dart';
import 'package:sona/application/common/utils/extensions.dart';

Duration kHttpRequestTimeout = const Duration(seconds: 60);
Logger _log = Logger(level: Level.debug);

enum HttpMethod {
  get("GET"),
  post("POST"),
  put("PUT"),
  delete("DELETE"),
  patch("PATCH");

  final String value;

  const HttpMethod(this.value);

  @override
  String toString() => value;
}

enum HttpStatusClass {
  informational,
  success,
  redirection,
  clientError,
  serverError;

  static HttpStatusClass fromStatusCode(int code) {
    if (code >= 100 && code < 200) return HttpStatusClass.informational;
    if (code >= 200 && code < 300) return HttpStatusClass.success;
    if (code >= 300 && code < 400) return HttpStatusClass.redirection;
    if (code >= 400 && code < 500) return HttpStatusClass.clientError;
    if (code >= 500 && code < 600) return HttpStatusClass.serverError;
    throw Exception('Status code $code not found in StatusCode enum');
  }
}

enum HttpStatusCode {
  continue_(100, "Continue"),
  switchingProtocols(101, "Switching Protocols"),
  processing(102, "Processing"),
  earlyHints(103, "Early Hints"),
  ok(200, "OK"),
  created(201, "Created"),
  accepted(202, "Accepted"),
  nonAuthoritativeInformation(203, "Non-Authoritative Information"),
  noContent(204, "No Content"),
  resetContent(205, "Reset Content"),
  partialContent(206, "Partial Content"),
  multiStatus(207, "Multi-Status"),
  alreadyReported(208, "Already Reported"),
  imUsed(226, "IM Used"),
  multipleChoices(300, "Multiple Choices"),
  movedPermanently(301, "Moved Permanently"),
  found(302, "Found"),
  seeOther(303, "See Other"),
  notModified(304, "Not Modified"),
  useProxy(305, "Use Proxy"),
  switchProxy(306, "Switch Proxy"),
  temporaryRedirect(307, "Temporary Redirect"),
  permanentRedirect(308, "Permanent Redirect"),
  badRequest(400, "Bad Request"),
  unauthorized(401, "Unauthorized"),
  paymentRequired(402, "Payment Required"),
  forbidden(403, "Forbidden"),
  notFound(404, "Not Found"),
  methodNotAllowed(405, "Method Not Allowed"),
  notAcceptable(406, "Not Acceptable"),
  proxyAuthenticationRequired(407, "Proxy Authentication Required"),
  requestTimeout(408, "Request Timeout"),
  conflict(409, "Conflict"),
  gone(410, "Gone"),
  lengthRequired(411, "Length Required"),
  preconditionFailed(412, "Precondition Failed"),
  payloadTooLarge(413, "Payload Too Large"),
  uriTooLong(414, "URI Too Long"),
  unsupportedMediaType(415, "Unsupported Media Type"),
  rangeNotSatisfiable(416, "Range Not Satisfiable"),
  expectationFailed(417, "Expectation Failed"),
  imATeapot(418, "I'm a teapot"),
  misdirectedRequest(421, "Misdirected Request"),
  unprocessableEntity(422, "Unprocessable Entity"),
  locked(423, "Locked"),
  failedDependency(424, "Failed Dependency"),
  tooEarly(425, "Too Early"),
  upgradeRequired(426, "Upgrade Required"),
  preconditionRequired(428, "Precondition Required"),
  tooManyRequests(429, "Too Many Requests"),
  requestHeaderFieldsTooLarge(431, "Request Header Fields Too Large"),
  unavailableForLegalReasons(451, "Unavailable For Legal Reasons"),
  internalServerError(500, "Internal Server Error"),
  notImplemented(501, "Not Implemented"),
  badGateway(502, "Bad Gateway"),
  serviceUnavailable(503, "Service Unavailable"),
  gatewayTimeout(504, "Gateway Timeout"),
  versionNotSupported(505, "HTTP Version Not Supported"),
  variantAlsoNegotiates(506, "Variant Also Negotiates"),
  insufficientStorage(507, "Insufficient Storage"),
  loopDetected(508, "Loop Detected"),
  notExtended(510, "Not Extended"),
  networkAuthenticationRequired(511, "Network Authentication Required");

  final int code;
  final String message;

  const HttpStatusCode(this.code, this.message);

  bool isCode(int code) => this.code == code;

  @override
  String toString() => "$code: $message";

  HttpStatusClass get statusClass => HttpStatusClass.fromStatusCode(code);

  static HttpStatusCode fromCode(int code) {
    for (HttpStatusCode status in HttpStatusCode.values) {
      if (status.isCode(code)) return status;
    }
    throw Exception('Status code $code not found in StatusCode enum');
  }
}

extension HttpResponse on Response {
  //
  get informational => status.statusClass == HttpStatusClass.informational;

  get successful => status.statusClass == HttpStatusClass.success;

  get redirection => status.statusClass == HttpStatusClass.redirection;

  get clientError => status.statusClass == HttpStatusClass.clientError;

  get serverError => status.statusClass == HttpStatusClass.serverError;

  get ok => [HttpStatusClass.informational, HttpStatusClass.success, HttpStatusClass.redirection].contains(status.statusClass);

  get error => [HttpStatusClass.clientError, HttpStatusClass.serverError].contains(status.statusClass);

  HttpStatusCode get status => HttpStatusCode.fromCode(statusCode);

  dynamic get json => jsonDecode(body);

  T getBody<T>() {
    if (T == Uint8List) return bodyBytes as T;
    if (T == String) return body as T;
    if (T == dynamic) return json as T;
    if (StringExtension.supportParse(T)) {
      return _typeIsNullable(T) ? body.tryParse<T>() as T : body.parse<T>();
    }
    return Json.deserialize<T>(body);
  }
}

class HttpException implements Exception {
  final String description;
  final Object? innerError;
  final Response? response;

  String get message {
    return innerError == null ? description : innerError.toString();
  }

  HttpException(this.description, {this.innerError, this.response}) {
    if (innerError is HttpException) throw Exception('Inner error cannot be HttpException');
  }
}

bool _typeIsNullable(Type type) => type.toString().endsWith('?');

Future<Response> request(
  Uri url, {
  HttpMethod method = HttpMethod.get,
  Object? body,
  List<MultipartFile>? files,
  Map<String, String>? headers,
  Encoding? encoding,
  Client? client,
  bool truncateLogBody = true,
}) async {
  try {
    _log.d("Send request to $url: \nMethod: $method\nHeaders: $headers\nBody: $body");

    var response = await _sendRequest(url, method, headers, body, encoding, client).timeout(
      kHttpRequestTimeout,
      onTimeout: () => throw TimeoutException("Time out occurred while sending request $method to $url", kHttpRequestTimeout),
    );

    final logBody = truncateLogBody ? response.body.truncate() : response.body;

    if (response.error) {
      final description = "Error response (${response.status}): \n$logBody";
      _log.w(description);
      throw HttpException(description, response: response);
    }

    _log.d("Response body:\n$logBody");
    return response;
  } on HttpException {
    rethrow;
  } catch (e, s) {
    final description = "${e.runtimeType} error occurred";
    _log.d(description, error: e, stackTrace: s);
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

typedef ProgressCallback = void Function(int bytes, int totalBytes);

class RequesPart {
  final String field;
  final List<int> value;
  final String? filename;
  final String contentType;

  RequesPart(this.field, this.value, this.filename, {this.contentType = 'application/octet-stream'});
}

class MultipartRequest extends BaseRequest {
  static const int _boundaryLength = 70;

  static final Random _random = Random();
  final fields = <String, String>{};
  final files = <MultipartFile>[];
  final parts = <RequesPart>[];
  final ProgressCallback? onProgress;

  MultipartRequest(super.method, super.url, {this.onProgress});

  void addField(String name, String value) {
    fields[name] = value;
  }

  void addAllFields(Map<String, String> fields) {
    this.fields.addAll(fields);
  }

  void addFile(String name, MultipartFile file) {
    files.add(file);
  }

  void addAllFiles(List<MultipartFile> files) {
    this.files.addAll(files);
  }

  void addFiles(String name, List<MultipartFile> files) {
    this.files.addAll(files);
  }

  void addBytes(String name, List<int> value, {String? filename, String contentType = 'application/octet-stream'}) {
    parts.add(RequesPart(name, value, filename, contentType: contentType));
  }

  void addPart(String name, List<int> value, {String? filename, String contentType = 'application/octet-stream'}) {
    parts.add(RequesPart(name, value, filename, contentType: contentType));
  }

  @override
  int get contentLength {
    var length = 0;
    var endLineLength = '\r\n'.length;
    var separatorBoundaryLength = '--'.length + _boundaryLength + endLineLength;
    var closeBoundaryLength = '--'.length + _boundaryLength + '--'.length + endLineLength;

    for (var field in fields.entries) {
      length += separatorBoundaryLength + utf8.encode(_headerForField(field.key, field.value)).length + utf8.encode(field.value).length + endLineLength;
    }
    for (var file in files) {
      length += separatorBoundaryLength + utf8.encode(_headerForFile(file)).length + file.length + endLineLength;
    }
    for (var part in parts) {
      length += separatorBoundaryLength + utf8.encode(_headerForPart(part)).length + part.value.length + endLineLength;
    }

    return length + closeBoundaryLength;
  }

  @override
  set contentLength(int? value) {
    throw UnsupportedError('Cannot set the contentLength property of multipart requests.');
  }

  @override
  ByteStream finalize() {
    super.finalize();

    final boundary = _boundaryString();
    headers['content-type'] = 'multipart/form-data; boundary=$boundary';

    final stream = _finalize(boundary);

    final total = contentLength;
    var bytes = 0;

    final transformer = StreamTransformer.fromHandlers(
      handleData: (List<int> data, EventSink<List<int>> sink) {
        bytes += data.length;
        onProgress?.call(bytes, total);
        _log.d("Upload progress [${url.path}]: (${(bytes / total * 100).toStringAsFixed(2)}%)");
        sink.add(data);
      },
      handleDone: (sink) => sink.close(),
      handleError: (error, stackTrace, sink) => sink.addError(error, stackTrace),
    );

    return ByteStream(stream.transform(transformer));
  }

  Stream<List<int>> _finalize(String boundary) async* {
    const line = [13, 10]; // \r\n
    final separator = utf8.encode('--$boundary\r\n');
    final close = utf8.encode('--$boundary--\r\n');

    Stream<List<int>> getStream<T>(Iterable<T> list, Stream<List<int>> Function(T) stream) async* {
      for (T item in list) {
        yield separator;
        yield* stream(item);
        yield line;
      }
    }

    yield* getStream(fields.entries, (field) async* {
      yield utf8.encode(_headerForField(field.key, field.value));
      yield utf8.encode(field.value);
    });

    yield* getStream(files, (file) async* {
      yield utf8.encode(_headerForFile(file));
      yield* file.finalize();
    });

    yield* getStream(parts, (part) async* {
      yield utf8.encode(_headerForPart(part));
      yield* ByteStream.fromBytes(part.value);
    });

    yield close;
  }

  String _headerForField(String name, String value) {
    return _headerFor(name, headers: () => isPlainAscii(value) ? null : {'content-type': 'text/plain; charset=utf-8', 'content-transfer-encoding': 'binary'});
  }

  String _headerForFile(MultipartFile file) {
    return _headerFor(file.field, contentType: file.contentType.toString(), filename: file.filename);
  }

  String _headerForPart(RequesPart part) {
    return _headerFor(part.field, contentType: part.contentType, filename: part.filename);
  }

  String _headerFor(String field, {String? contentType, String? filename, Map<String, String>? Function()? headers}) {
    var header = 'content-disposition: form-data; name="${_browserEncode(field)}; ${filename != null ? 'filename="${_browserEncode(filename)}"' : ''}"';
    if (contentType != null) header = '$header\r\ncontent-type: $contentType';
    headers?.call()?.forEach((key, value) => header = '$header\r\n$key: $value');
    return '$header\r\n\r\n';
  }

  String _browserEncode(String value) => value.replaceAll(_newlineRegExp, '%0D%0A').replaceAll('"', '%22');

  String _boundaryString() {
    var prefix = 'dart-http-boundary-';
    var list = List<int>.generate(_boundaryLength - prefix.length, (index) => boundaryCharacters[_random.nextInt(boundaryCharacters.length)], growable: false);
    return '$prefix${String.fromCharCodes(list)}';
  }
}

final _newlineRegExp = RegExp(r'\r\n|\r|\n');
final _asciiOnly = RegExp(r'^[\x00-\x7F]+$');

bool isPlainAscii(String string) => _asciiOnly.hasMatch(string);
