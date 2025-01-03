import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final _log = Logger();

/// Signature for state fetching functions
typedef Fetcher<R> = Future<R> Function([
  List<dynamic>? positionalArguments,
  Map<Symbol, dynamic>? namedArguments,
]);

/// Base class for Flutter stateful widgets with enhanced state management capabilities
abstract class FullState<T extends StatefulWidget> extends State<T> {
  final _stateSubscriptions = <StreamSubscription>[];
  final _mountedCompleter = Completer<void>();

  @override
  void initState() {
    super.initState();
    _mountedCompleter.complete();
  }

  @override
  void dispose() {
    for (final subscription in _stateSubscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  /// Safely updates the widget state if it's still mounted
  void refresh() => safeUpdateState(() {});

  /// Safely executes setState with mounted check
  void safeUpdateState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  /// Creates a new fetch state result with automatic lifecycle management
  FetchStateResult<R> fetchState<R>(
    Fetcher<R> fetcher, {
    Function(Object)? onError,
    R? initialData,
    bool autoFetch = false,
  }) {
    final state = FetchStateResult<R>(
      fetcher: fetcher,
      setState: safeUpdateState,
      onError: onError,
      initialData: initialData,
    );

    if (autoFetch) {
      _mountedCompleter.future.then((_) => state.fetch());
    }

    return state;
  }

  /// Creates a new loading state with automatic lifecycle management
  StateLoadingResult loadingState(
    bool loading, {
    Function(Object)? onError,
  }) {
    return StateLoadingResult(
      loading,
      setState: safeUpdateState,
      onError: onError,
    );
  }

  /// Combines multiple state results
  static T whenAll<T>(
    List<StateResult> states, {
    required T Function() loading,
    required T Function() initial,
    required T Function(Object) error,
    required T Function(List) data,
  }) {
    if (states.any((state) => state.isLoading)) return loading();
    if (states.any((state) => state.hasError)) return error(states.firstWhere((state) => state.hasError).error!);
    if (states.every((state) => state.hasValue)) return data(states.map((state) => state.value).toList());
    return initial();
  }

  /// Combines two state results
  static T combine2<T, A, B>(
    StateResult<A> a,
    StateResult<B> b, {
    required T Function() loading,
    required T Function() initial,
    required T Function(Object) error,
    required T Function(A, B) data,
  }) {
    return whenAll(
      [a, b],
      loading: loading,
      initial: initial,
      error: error,
      data: (list) => data(list[0] as A, list[1] as B),
    );
  }

  /// Combines three state results
  static T combine3<T, A, B, C>(
    StateResult<A> a,
    StateResult<B> b,
    StateResult<C> c, {
    required T Function() loading,
    required T Function() initial,
    required T Function(Object) error,
    required T Function(A, B, C) data,
  }) {
    return whenAll(
      [a, b, c],
      loading: loading,
      initial: initial,
      error: error,
      data: (list) => data(list[0] as A, list[1] as B, list[2] as C),
    );
  }

  /// Combines four state results
  static T combine4<T, A, B, C, D>(
    StateResult<A> a,
    StateResult<B> b,
    StateResult<C> c,
    StateResult<D> d, {
    required T Function() loading,
    required T Function() initial,
    required T Function(Object) error,
    required T Function(A, B, C, D) data,
  }) {
    return whenAll(
      [a, b, c, d],
      loading: loading,
      initial: initial,
      error: error,
      data: (list) => data(list[0] as A, list[1] as B, list[2] as C, list[3] as D),
    );
  }
}

/// Base class for state results with common functionality
abstract class StateResult<R> {
  R? _value;
  Object? _error;
  bool _loading = false;
  final StateSetter setState;
  final Function(Object)? onError;
  final _controller = StreamController<R>.broadcast();

  StateResult({
    required this.setState,
    this.onError,
    R? initialData,
  }) {
    _value = initialData;
  }

  void dispose() {
    _controller.close();
  }

  R? get value => _value;

  Object? get error => _error;

  bool get hasError => _error != null;

  bool get isLoading => _loading;

  bool get hasValue => _value != null;

  Stream<R> get stream => _controller.stream;

  void _reset() {
    _value = null;
    _error = null;
    _loading = false;
  }

  /// Pattern matching for state handling
  T when<T>({
    required T Function() loading,
    required T Function() initial,
    required T Function(Object) error,
    required T Function(R) value,
  }) {
    if (_loading) return loading();
    if (_error != null) return error(_error!);
    if (hasValue) return value(_value as R);
    return initial();
  }
}

/// State result for managing loading states
class StateLoadingResult extends StateResult<void> {
  StateLoadingResult(
    bool loading, {
    required super.setState,
    super.onError,
  }) {
    _loading = loading;
  }

  @override
  bool get hasValue => !_loading;

  void start() {
    if (_loading) return;
    _reset();
    _loading = true;
    setState(() {});
  }

  void stop() {
    if (!_loading) return;
    _reset();
    _loading = false;
    setState(() {});
  }

  void stopWithError(Object error) {
    if (!_loading) return;
    _reset();
    _error = error;
    _loading = false;
    setState(() {});
    if (onError != null) onError!(error);
  }

  /// Executes an operation with automatic loading state management
  Future<R> run<R>(Future<R> Function() operation) async {
    try {
      start();
      return await operation();
    } catch (e) {
      stopWithError(e);
      rethrow;
    } finally {
      stop();
    }
  }
}

/// State result for fetching data
class FetchStateResult<R> extends StateResult<R> {
  final Fetcher<R> fetcher;
  Timer? _debounceTimer;
  bool _isFetching = false;

  FetchStateResult({
    required this.fetcher,
    required super.setState,
    super.onError,
    super.initialData,
  });

  Future<void> fetch([List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments]) async {
    if (_isFetching) return;

    _reset();
    _loading = true;
    _isFetching = true;
    setState(() {});

    try {
      _value = await fetcher(positionalArguments, namedArguments);
      if (_value != null) {
        _controller.add(_value as R);
      }
    } catch (e, s) {
      _log.e("Error fetching data", error: e, stackTrace: s);
      _error = e;
      if (onError != null) onError!(e);
    } finally {
      _loading = false;
      _isFetching = false;
      setState(() {});
    }
  }

  /// Debounces the fetch operation
  void debouncedFetch({
    Duration duration = const Duration(milliseconds: 300),
    List<dynamic>? positionalArguments,
    Map<Symbol, dynamic>? namedArguments,
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      duration,
      () => fetch(positionalArguments, namedArguments),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  String toString() {
    return 'FetchStateResult{value: $_value, error: $_error, loading: $_loading}';
  }
}
