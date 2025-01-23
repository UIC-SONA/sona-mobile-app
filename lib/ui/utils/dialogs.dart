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
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
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

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String cancelText = 'Cancelar',
  String confirmText = 'Aceptar',
}) async {
  final result = await showAlertDialog<bool>(
    context,
    title: title,
    message: message,
    actions: {
      cancelText: () => Navigator.of(context).pop(false),
      confirmText: () => Navigator.of(context).pop(true),
    },
  );

  return result ?? false;
}

Future<String?> showInputDialog(
  BuildContext context, {
  required String title,
  required String message,
  int? maxLength,
  int? maxLines,
  int? minLines,
  TextInputType? keyboardType,
}) {
  final TextEditingController controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            TextField(
              controller: controller,
              maxLength: maxLength,
              maxLines: maxLines,
              keyboardType: keyboardType,
              minLines: minLines,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Aceptar'),
          ),
        ],
      );
    },
  );
}

Future<FF?> showAlertErrorDialog<FF>(
  BuildContext context, {
  required Object error,
  String? title,
  ErrorExtractor errorDetailExtractor = extractError,
}) {
  final Error err = errorDetailExtractor(error);
  return showAlertDialog(
    context,
    title: title ?? err.title,
    message: err.message,
  );
}

void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    },
  );
}
