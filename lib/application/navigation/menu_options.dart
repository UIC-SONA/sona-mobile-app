import 'package:flutter/material.dart';
import 'package:sona/application/widgets/menu.dart';
import 'package:sona/application/widgets/sona_scaffold.dart';

class MenuOptions extends StatelessWidget {
  const MenuOptions({super.key});

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
                onPressed: () => Navigator.of(context).pushNamed('/services'),
              ),
              MenuButton(
                label: 'Tips',
                icon: Icons.lightbulb,
                onPressed: () => Navigator.of(context).pushNamed('/tips'),
              ),
              MenuButton(
                label: 'Foro',
                icon: Icons.forum,
                onPressed: () => Navigator.of(context).pushNamed('/forum'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
