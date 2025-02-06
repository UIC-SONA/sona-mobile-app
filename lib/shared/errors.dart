import 'package:sona/domain/models/problem_details.dart';
import 'package:sona/shared/http/http.dart';

typedef ErrorExtractorNullable = Error? Function(Object e);
typedef ErrorExtractor = Error Function(Object e);

class Error {
  final String title;
  final String message;

  Error(this.title, this.message);

  @override
  String toString() => '$title: $message';
}

ErrorExtractorNullable defaultErrorExtractor = (e) => Error('Error', e.toString());

ErrorExtractorNullable problemDetailsErrorExtractor = (e) {
  if (e is ProblemDetails) {
    return Error(e.title, e.detail);
  }
  return null;
};

ErrorExtractorNullable httpErrorExtractor = (e) {
  if (e is HttpException) {
    final response = e.response;
    if (response != null) {
      try {
        final body = response.getBody<ProblemDetails>();
        return Error(HttpStatusCode.fromCode(body.status).spanish, body.detail);
      } catch (e) {
        return Error(response.status.message, response.body);
      }
    }
    return Error('Error', e.message);
  }
  return null;
};

List<ErrorExtractorNullable> errorExtractors = [
  problemDetailsErrorExtractor,
  httpErrorExtractor,
  defaultErrorExtractor,
];

Error extractError(Object e) {
  for (final extractor in errorExtractors) {
    final error = extractor(e);
    if (error != null) return error;
  }
  throw Exception('Error detail extractor not found');
}

void forEachValidationError(List<dynamic> errors, void Function(String field, List<String> messages) callback) {
  for (var error in errors) {
    final field = error['field'] as String;
    final messages = (error['messages'] as List<dynamic>).map((e) => e as String).toList();
    callback(field, messages);
  }
}
