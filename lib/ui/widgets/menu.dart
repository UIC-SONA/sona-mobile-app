import 'package:flutter/material.dart';
import 'package:sona/ui/theme/colors.dart';

import 'full_state_widget.dart';

class GridMenu extends StatelessWidget {
  final List<MenuButton> buttons;

  const GridMenu({
    super.key,
    required this.buttons,
  }) : assert(buttons.length != 0);

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;

    return GridView.count(
      crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
      clipBehavior: Clip.none,
      shrinkWrap: true,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      children: buttons,
    );
  }
}

class MenuButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final dynamic icon;
  final String? description;
  final Gradient? gradient;

  const MenuButton({
    super.key,
    this.onPressed,
    required this.label,
    required this.icon,
    this.description,
    this.gradient,
  }) : assert(icon is IconData || icon is Widget);

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends FullState<MenuButton> {
  var _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    _scale = 1.05;
    refresh();
  }

  void _onTapUp(TapUpDetails details) {
    _scale = 1.0;
    refresh();
  }

  void _onTapCancel() {
    _scale = 1.0;
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale, // Aplica la animación de escala
        duration: const Duration(milliseconds: 100), // Duración de la animación
        child: ElevatedButton(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(EdgeInsets.zero), // Elimina el padding interno
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(35)),
              ),
            ),
          ),
          onPressed: widget.onPressed,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            decoration: widget.gradient != null
                ? BoxDecoration(
                    gradient: widget.gradient,
                    borderRadius: BorderRadius.circular(35),
                  )
                : BoxDecoration(
                    color: deepMagenta,
                    borderRadius: BorderRadius.circular(35),
                  ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon is IconData)
                  Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 80,
                  )
                else
                  widget.icon,
                const SizedBox(height: 10),
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (widget.description != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    widget.description!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
