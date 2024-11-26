import 'package:http/http.dart';

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
