import 'dart:async';

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

  FetchState<R> fetchState<R>(Fetcher<R> fetcher, {Function(Object)? onError}) {
    return FetchState<R>(fetcher: fetcher, setState: safeUpdateState, onError: onError);
  }
}

typedef Fetcher<R> = Future<R> Function([List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments]);

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
    required T Function() initial,
  }) {
    if (_loading) return loading();
    if (_error != null) return error(_error!);
    if (_data != null) return data(_data as R);
    return initial();
  }
}

// Clase para manejar la consulta de datos (lectura)
class FetchState<R> extends BaseStateResult<R> {
  //
  final Fetcher<R> fetcher;

  FetchState({required this.fetcher, required super.setState, super.onError});

  Future<void> fetch([List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments]) async {
    _reset();
    _loading = true;
    setState(() {});
    try {
      _data = await fetcher(positionalArguments, namedArguments);
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
