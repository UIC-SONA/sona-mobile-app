import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
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
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png', width: MediaQuery.of(context).size.height * 0.3),
                  const SizedBox(height: 30),
                  _text(),
                  const SizedBox(height: 30),
                  GridMenu(
                    buttons: [
                      MenuButton(
                        label: 'Calendario Menstrual',
                        icon: Icons.calendar_today,
                        onPressed: () => AutoRouter.of(context).push(const MenstrualCalendarRoute()),
                      ),
                      MenuButton(
                        label: 'Información Didáctica',
                        icon: Icons.menu_book,
                        onPressed: () => AutoRouter.of(context).pushNamed('/information'),
                      ),
                    ],
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
          '¡Bienvenido a ',
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
