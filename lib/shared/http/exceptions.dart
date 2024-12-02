import 'package:http/http.dart';
import 'package:sona/domain/models/problem_details.dart';
import 'package:sona/shared/errors.dart';
import 'package:sona/shared/http/extensions.dart';

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
    return 'HttpException: ${_getErrorDetail()}';
  }

  Error _getErrorDetail() {
    if (response != null) {
      final body = response!.getBody<ProblemDetails>();
      return Error(body.title, body.detail);
    }
    return Error('Error', message);
  }
}
