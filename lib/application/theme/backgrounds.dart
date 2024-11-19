import 'package:flutter/material.dart';
import 'package:sona/application/theme/colors.dart';

import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;

  const Background({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: bgGradientLight,
          ),
        ),
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
                  opacity: 0.025,
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
