import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:sona/ui/theme/backgrounds.dart';
import 'package:sona/ui/theme/colors.dart';
import 'package:sona/ui/widgets/menu.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        gradient: bgGradientLight,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: MediaQuery.of(context).size.height * 0.3,
                  ),
                  const SizedBox(height: 30),
                  _text(),
                  const SizedBox(height: 30),
                  Expanded(
                    child: GridMenu(
                      buttons: [
                        MenuButton(
                          label: 'Calendario Menstrual',
                          icon: SvgPicture.asset(
                            'assets/icons/ICON1.svg',
                            height: 80,
                          ),
                          gradient: bgGradientButton1,
                          onPressed: () => AutoRouter.of(context).push(const MenstrualCalendarRoute()),
                          requiresAuth: true,
                        ),
                        MenuButton(
                          label: 'Tips',
                          icon: SvgPicture.asset('assets/icons/ICON7.svg', height: 90,),
                          onPressed: () => AutoRouter.of(context).push(const TipsRoute()),
                          gradient: bgGradientButton1,
                        ),
                        MenuButton(
                          label: 'Contenido Didáctico',
                          icon: SvgPicture.asset(
                            'assets/icons/ICON2.svg',
                            height: 80,
                          ),
                          gradient: bgGradientButton1,
                          onPressed: () => AutoRouter.of(context).push(const DidacticContentRoute()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _text() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¡Bienvenida ',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        Text(
          'SONA',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: deepMagenta),
        ),
        Text(
          '!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
