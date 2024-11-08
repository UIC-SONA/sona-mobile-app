import 'package:flutter/material.dart';
import 'package:sona/application/widgets/menu.dart';
import 'package:sona/application/widgets/sona_scaffold.dart';

class ServicesOptions extends StatelessWidget {
  const ServicesOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      actionButton: SonaActionButton.home(),
      body: Column(
        children: [
          const Text(
            'Servicios',
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          GridMenu(
            buttons: [
              MenuButton(
                label: 'Chatbot',
                icon: Icons.android,
                onPressed: () => Navigator.of(context).pushNamed('/chatbot'),
              ),
              MenuButton(
                label: 'Chat con Profesionales',
                icon: Icons.chat,
                onPressed: () => Navigator.of(context).pushNamed('/chat'),
              ),
              MenuButton(
                label: 'Agendamiento de Citas',
                icon: Icons.calendar_today,
                onPressed: () => Navigator.of(context).pushNamed('/appointments'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
