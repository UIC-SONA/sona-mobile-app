import 'package:flutter/material.dart';
import 'package:sona/domain/models/problem_details.dart';
import 'package:sona/shared/http/http.dart';
import 'package:sona/ui/widgets/full_state_widget.dart';

class ErrorDetail {
  final String title;
  final String message;

  ErrorDetail(this.title, this.message);
}

typedef ErrorDetailExtractor = ErrorDetail Function(Object e);
typedef SFController = ScaffoldFeatureController<SnackBar, SnackBarClosedReason>;

SFController? showSnackBarError(BuildContext context, String message) {
  return showSnackBar(
    context,
    content: Text(message),
    backgroundColor: Theme.of(context).colorScheme.error,
  );
}

SFController? showSnackBarFromError(
  BuildContext context, {
  required Object error,
  ErrorDetailExtractor? errorDetailExtractor,
}) {
  final ErrorDetail errorDetail = errorDetailExtractor != null ? errorDetailExtractor(error) : defaultErrorDetailExtractor(error);
  return showSnackBarError(context, errorDetail.message);
}

SFController? showSnackBarSuccess(BuildContext context, String message) {
  return showSnackBar(
    context,
    content: Text(message),
    backgroundColor: Theme.of(context).colorScheme.secondary,
  );
}

SFController? showSnackBar(BuildContext context, {required Widget content, Color? backgroundColor}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: content,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.secondary,
    ),
  );
}

Future<FF?> showAlertErrorDialog<FF>(
  FullState state, {
  required Object error,
  ErrorDetailExtractor? errorDetailExtractor,
}) {
  final ErrorDetail errorDetail = errorDetailExtractor != null ? errorDetailExtractor(error) : defaultErrorDetailExtractor(error);
  return state.showAlertDialog(title: errorDetail.title, message: errorDetail.message);
}

ErrorDetailExtractor defaultErrorDetailExtractor = (e) => ErrorDetail('Error', e.toString());
ErrorDetailExtractor httpErrorDetailExtractor = (e) {
  if (e is HttpException) {
    final response = e.response;
    if (response != null) {
      final body = response.getBody<ProblemDetails>();
      return ErrorDetail(body.title, body.detail);
    }
    return ErrorDetail('Error', e.message);
  }
  return defaultErrorDetailExtractor(e);
};
