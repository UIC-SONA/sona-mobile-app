import 'package:flutter/material.dart';

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
  final IconData icon;
  final String? description;

  const MenuButton({
    super.key,
    this.onPressed,
    required this.label,
    required this.icon,
    this.description,
  });

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
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  side: BorderSide(color: Colors.white, width: 2),
                ),
              ),
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return Colors.grey;
                }
                return null;
              })),
          onPressed: widget.onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 80),
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
    );
  }
}
