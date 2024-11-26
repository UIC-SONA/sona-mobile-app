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
  final Widget? loadingIndicator;

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
    this.loadingIndicator,
  });

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  @override
  Widget build(BuildContext context) {
    Color iconColor = Theme.of(context).colorScheme.onPrimary; // Color del indicador de carga según el tema

    Widget loadingWidget = widget.loadingIndicator ??
        SizedBox(
          width: 24.0,
          height: 24.0,
          child: CircularProgressIndicator(
            color: iconColor,
            strokeWidth: 2.2,
          ),
        );

    return ElevatedButton(
      onPressed: widget.loading ? null : widget.onPressed,
      onLongPress: widget.loading ? null : widget.onLongPress,
      onHover: widget.onHover,
      onFocusChange: widget.onFocusChange,
      style: widget.style,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      clipBehavior: widget.clipBehavior,
      child: widget.loading
          ? Stack(
              alignment: Alignment.center, // Centra el indicador de carga
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      loadingWidget,
                      const SizedBox(width: 8),
                      widget.child,
                    ] else ...[
                      loadingWidget,
                      Opacity(
                        opacity: 0.0, // Hace invisible el child
                        child: widget.child,
                      ),
                    ]
                  ],
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  widget.icon!,
                  const SizedBox(width: 8),
                ],
                widget.child,
              ],
            ),
    );
  }
}
