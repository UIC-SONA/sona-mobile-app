import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/shared/errors.dart';
import 'package:sona/shared/http/http.dart';
import 'package:sona/ui/utils/dialogs.dart';

void formStateInvalidator(
  BuildContext context, {
  required FormBuilderState formState,
  required Object error,
}) {
  if (error is HttpException && error.response != null) {
    final details = error.response!.getBody<ProblemDetails>();
    final errors = details.extensions['errors'] as List<dynamic>?;
    if (errors == null) {
      showAlertErrorDialog(context, error: details);
    } else {
      forEachValidationError(errors, (field, messages) {
        formState.fields[field]?.invalidate(messages.first);
      });
    }
  } else {
    showAlertErrorDialog(context, error: error);
  }
}
