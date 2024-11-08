import 'package:flutter/material.dart';

abstract class FullState<T extends StatefulWidget> extends State<T> {
  void refresh() {
    if (mounted) setState(() {});
  }

  Future<T2?> showAlertDialog<T2>({required String title, required String message, Map<String, VoidCallback>? actions}) {
    if (!mounted) return Future.value();

    return showDialog<T2>(
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

  void safeSetState(VoidCallback fn) {
    if (mounted) setState(fn);
  }
}
