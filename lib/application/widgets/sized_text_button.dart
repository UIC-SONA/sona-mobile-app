import 'package:flutter/material.dart' show BuildContext, EdgeInsets, FontWeight, SizedBox, StatelessWidget, Text, TextButton, TextStyle, VoidCallback, Widget;

class SizedTextbutton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final double? width;
  final double? height;
  final TextStyle textStyle;
  final bool enabled;

  const SizedTextbutton(
    this.text, {
    super.key,
    this.onPressed,
    this.width,
    this.height,
    this.textStyle = const TextStyle(fontWeight: FontWeight.bold),
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        ),
        onPressed: enabled ? onPressed : null,
        child: Text(text, style: textStyle),
      ),
    );
  }
}
