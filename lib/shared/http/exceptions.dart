import 'package:http/http.dart';

class HttpException implements Exception {
  final String description;
  final Object? innerError;
  final Response? response;

  String get message => innerError == null ? description : innerError.toString();

  HttpException(this.description, {this.innerError, this.response}) {
    if (innerError is HttpException) throw Exception('Inner error cannot be HttpException');
  }

  @override
  String toString() {
    return 'HttpException: $description \nResponse: ${_reponse(response)} \nInnerError: $innerError';
  }
}

String? _reponse(Response? response) {
  if (response == null) return null;
  return response.body;
}
