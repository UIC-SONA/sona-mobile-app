import 'package:flutter/material.dart';
import 'package:sona/shared/errors.dart';

typedef SFController = ScaffoldFeatureController<SnackBar, SnackBarClosedReason>;

SFController? showSnackBarError(BuildContext context, String message) {
  return showSnackBar(
    context,
    content: Text(message),
    backgroundColor: Theme.of(context).colorScheme.error,
  );
}

SFController? showSnackBarFromError(BuildContext context, {required Object error, ErrorExtractor errorExtractor = extractError}) {
  final Error errr = errorExtractor(error);
  return showSnackBarError(context, errr.message);
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

Future<FF?> showAlertDialog<FF>(BuildContext context, {required String title, required String message, Map<String, VoidCallback>? actions}) {
  return showDialog<FF>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          for (final entry in actions?.entries ?? [MapEntry('OK', () => Navigator.of(context).pop())])
            TextButton(
              onPressed: entry.value,
              child: Text(entry.key),
            ),
        ],
      );
    },
  );
}

Future<FF?> showAlertErrorDialog<FF>(BuildContext context, {required Object error, ErrorExtractor errorDetailExtractor = extractError}) {
  final Error err = errorDetailExtractor(error);
  return showAlertDialog(context, title: err.title, message: err.message);
}
