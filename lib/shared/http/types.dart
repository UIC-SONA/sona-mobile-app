import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sona/shared/http/http.dart';

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

abstract class QueryParametrable {
  Map<String, dynamic /*String?|Iterable<String>*/ > toQueryParameters();
}

abstract interface class WebResource {
  Uri get uri;

  http.Client? get client;

  String get path;

  Map<String, String> get headers;
}

Future<http.Response> resource(
  WebResource resource, {
  String path = '',
  HttpMethod method = HttpMethod.get,
  Object? body,
  Map<String, String>? headers,
  Encoding? encoding,
}) async {
  return request(
    resource.uri.replace(path: '/${resource.path}$path'),
    client: resource.client,
    method: method,
    headers: headers,
    body: body,
    encoding: encoding,
  );
}
