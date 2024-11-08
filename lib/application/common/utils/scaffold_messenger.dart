import 'package:flutter/material.dart';
import 'package:sona/application/common/http/http.dart';
import 'package:sona/application/common/models/models.dart';

typedef SFController = ScaffoldFeatureController<SnackBar, SnackBarClosedReason>;

SFController? showSnackBarError(BuildContext context, String message) {
  return showSnackBar(
    context,
    content: Text(message),
    backgroundColor: Theme.of(context).colorScheme.error,
  );
}

SFController? showSnackBarErrorFromHttpException(BuildContext context, HttpException e) {
  if (e.response != null) {
    var problem = e.response!.getBody<ProblemDetails>();
    return showSnackBarError(context, problem.detail);
  }
  return showSnackBarError(context, 'Error: ${e.message}');
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
