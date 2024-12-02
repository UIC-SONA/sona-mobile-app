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

ErrorExtractorNullable httpErrorExtractor = (e) {
  if (e is HttpException) {
    final response = e.response;
    if (response != null) {
      try {
        final body = response.getBody<ProblemDetails>();
        return Error(body.title, body.detail);
      } catch (e) {
        return Error(response.status.message, response.body);
      }

    }
    return Error('Error', e.message);
  }
  return null;
};

List<ErrorExtractorNullable> errorExtractors = [
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
