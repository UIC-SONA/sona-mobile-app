import 'dart:async';

class Debouncing {
  final Duration duration;
  final void Function() callback;
  Timer? _timer;

  Debouncing({required this.duration, required this.callback});

  void _call() {
    if (_timer?.isActive ?? false) _timer?.cancel();
    _timer = Timer(duration, callback);
  }

  void Function() get listenner => _call;

  factory Debouncing.debounce(Duration duration, void Function() callback) {
    return Debouncing(duration: duration, callback: callback);
  }

  static void Function() build(Duration duration, void Function() callback) {
    return Debouncing.debounce(duration, callback).listenner;
  }
}

extension DebouncingExtension on void Function() {
  void Function() debounce(Duration duration) => Debouncing.build(duration, this);
}
