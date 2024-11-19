import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final _log = Logger();

abstract class FullState<T extends StatefulWidget> extends State<T> {
  void refresh() {
    safeUpdateState(() {});
  }

  void safeUpdateState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  // Muestra un cuadro de diálogo de alerta
  Future<T2?> showAlertDialog<T2>({
    required String title,
    required String message,
    Map<String, VoidCallback>? actions,
  }) {
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

  FetchState<R, F> fetchState<R, F extends Function>(F fetcher, {Function(Object)? onError}) {
    return FetchState<R, F>(fetcher: fetcher, setState: safeUpdateState, onError: onError);
  }
}

// Clase base para almacenar los resultados de operaciones
class BaseStateResult<R> {
  R? _data;
  Object? _error;
  bool _loading = false;
  final StateSetter setState;
  final Function(Object)? onError;

  BaseStateResult({required this.setState, this.onError});

  // Getters para los valores de datos y error
  R? get data => _data;

  Object? get error => _error;

  void _reset() {
    _data = null;
    _error = null;
    _loading = false;
  }

  bool get hasError => _error != null;

  bool get isLoading => _loading;

  T when<T>({
    required T Function() loading,
    required T Function(Object) error,
    required T Function(R) data,
  }) {
    if (_loading) return loading();
    if (_error != null) return error(_error!);
    return data(_data as R);
  }
}

// Clase para manejar la consulta de datos (lectura)
class FetchState<R, F extends Function> extends BaseStateResult<R> {
  //
  final F fetcher;

  FetchState({required this.fetcher, required super.setState, super.onError});

  Future<void> fetch([List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments]) async {
    _reset();
    _loading = true;
    setState(() {});
    try {
      _data = await Function.apply(fetcher, positionalArguments, namedArguments);
    } catch (e, s) {
      _log.e("Error fetching data", error: e, stackTrace: s);
      _error = e;
      if (onError != null) onError!(e);
    } finally {
      _loading = false;
      setState(() {});
    }
  }
}
