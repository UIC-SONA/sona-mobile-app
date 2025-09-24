import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/providers/auth.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:sona/ui/theme/colors.dart';
import 'package:sona/ui/utils/dialogs.dart';

import 'full_state_widget.dart';

class GridMenu extends StatelessWidget {
  final List<MenuButton> buttons;

  const GridMenu({
    super.key,
    required this.buttons,
  }) : assert(buttons.length != 0);

  int _calculateCrossAxisCount(double width) {
    if (width < 600) return 2;
    if (width < 900) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    if (kDebugMode) {
      print('Screen width: $width');
    }

    final crossAxisCount = _calculateCrossAxisCount(width);

    return GridView.count(
      crossAxisCount: crossAxisCount,
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
  final bool requiresAuth;

  const MenuButton({
    super.key,
    this.onPressed,
    required this.label,
    required this.icon,
    this.description,
    this.gradient,
    this.requiresAuth = false,
  }) : assert(icon is IconData || icon is Widget);

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends FullState<MenuButton> {
  var _scale = 1.0;

  final authProvider = injector.get<AuthProvider>();

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

  void _onPressed() {
    if (widget.requiresAuth && !authProvider.isAuthenticatedSync()) {
      // Mostrar mensaje de error
      showAlertDialog(context,
        title: 'Autenticación requerida',
        message: 'Debes iniciar sesión para acceder a esta función.',
        actions: {
          'Autenticar': () {
            AutoRouter.of(context).push(const LoginRoute());
          },
          'Cancelar': () {
            Navigator.of(context).pop();
          }
        },
      );
      return;
    }
    if (widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {

    final isAuthenticated = authProvider.isAuthenticatedSync();
    final needsLock = widget.requiresAuth && !isAuthenticated;

    if (kDebugMode) {
      print('isAuthenticated: $isAuthenticated');
    }

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
          onPressed: _onPressed,
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
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        widget.icon,
                        color: Colors.white.withValues(alpha: needsLock ? 0.4 : 1.0),
                        size: 80,
                      ),
                      if (needsLock)
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: Icon(
                            Icons.lock,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  )
                else
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: needsLock ? 0.4 : 1.0,
                        child: widget.icon,
                      ),
                      if (needsLock)
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: Icon(
                            Icons.lock,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
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
