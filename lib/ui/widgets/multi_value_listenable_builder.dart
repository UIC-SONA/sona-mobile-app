import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class MultiValueListenableBuilder extends StatelessWidget {
  final List<ValueListenable> valueListenables;
  final Widget Function(BuildContext context, List<dynamic> values, Widget? child) builder;
  final Widget? child;
  const MultiValueListenableBuilder({
    super.key,
    required this.valueListenables,
    required this.builder,
    this.child,
  });
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<dynamic>(
      valueListenable: valueListenables[0],
      builder: (context, value, _) {
        return _buildNested(context, [value], 1);
      },
    );
  }
  Widget _buildNested(BuildContext context, List<dynamic> values, int index) {
    if (index >= valueListenables.length) {
      return builder(context, values, child);
    }
    return ValueListenableBuilder<dynamic>(
      valueListenable: valueListenables[index],
      builder: (context, value, _) {
        return _buildNested(context, [...values, value], index + 1);
      },
    );
  }
}