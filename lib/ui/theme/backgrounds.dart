import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  //
  final Widget child;
  final Gradient gradient;
  final bool hideLogo;

  const Background({
    super.key,
    required this.child,
    required this.gradient,
    this.hideLogo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: gradient,
          ),
        ),
        if (!hideLogo)
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 40.0,
              mainAxisSpacing: 40.0,
              childAspectRatio: 1,
            ),
            itemCount: 25, // Número total de imágenes
            itemBuilder: (context, index) {
              return Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/only_logo.png'),
                    fit: BoxFit.cover, //
                    opacity: 0.05,
                  ),
                ),
              );
            },
          ),
        child, // Aquí va el contenido principal
      ],
    );
  }
}
