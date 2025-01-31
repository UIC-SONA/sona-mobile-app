import 'package:flutter/material.dart';
import 'package:sona/ui/theme/colors.dart';

class RoundedButtonWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Gradient gradient;

  const RoundedButtonWidget({
    super.key,
    required this.child,
    required this.onPressed,
    this.gradient = bgGradientAppBar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ElevatedButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
