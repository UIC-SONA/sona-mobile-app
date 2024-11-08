import 'dart:async';
import 'dart:ui' show VoidCallback;

class Debouncing {
  final Duration duration;
  final VoidCallback callback;
  Timer? _timer;

  Debouncing({
    required this.duration,
    required this.callback,
  });

  void _call() {
    if (_timer?.isActive ?? false) _timer?.cancel();
    _timer = Timer(duration, callback);
  }

  VoidCallback get listenner => _call;

  factory Debouncing.debounce(Duration duration, VoidCallback callback) {
    return Debouncing(duration: duration, callback: callback);
  }
}

extension DebouncingExtension on VoidCallback {
  VoidCallback debounce(Duration duration) => Debouncing.debounce(duration, this).listenner;
}
