import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:sona/ui/widgets/menu.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';

@RoutePage()
class MenuOptionsScreen extends StatelessWidget {
  const MenuOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      actionButton: SonaActionButton.home(),
      body: Column(
        children: [
          GridMenu(
            buttons: [
              MenuButton(
                label: 'Servicios',
                icon: Icons.medical_services,
                onPressed: () => AutoRouter.of(context).push(const ServicesOptionsRoute()),
              ),
              MenuButton(
                label: 'Tips',
                icon: Icons.lightbulb,
                onPressed: () => AutoRouter.of(context).push(const TipsRoute()),
              ),
              const MenuButton(
                label: 'Foro',
                icon: Icons.forum,
                onPressed: null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
