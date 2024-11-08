import 'package:flutter/material.dart';

class LoadingButton extends StatefulWidget {
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onHover;
  final ValueChanged<bool>? onFocusChange;
  final ButtonStyle? style;
  final FocusNode? focusNode;
  final bool autofocus;
  final Clip clipBehavior;
  final bool loading;
  final Widget child;
  final Widget? icon;
  final Widget loadingIndicator;

  const LoadingButton({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.loading = false,
    required this.child,
    this.icon,
    this.loadingIndicator = const CircularProgressIndicator(),
  });

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  @override
  Widget build(BuildContext context) {
    final loading = widget.loading;
    return ElevatedButton(
      onPressed: loading ? null : widget.onPressed,
      onLongPress: loading ? null : widget.onLongPress,
      onHover: widget.onHover,
      onFocusChange: widget.onFocusChange,
      style: widget.style,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      clipBehavior: widget.clipBehavior,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading) widget.loadingIndicator else
            if (widget.icon != null) widget.icon!,
          if (loading || widget.icon != null) const SizedBox(width: 4),
          widget.child,
        ],
      ),
    );
  }
}
