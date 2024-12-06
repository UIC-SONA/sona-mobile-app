import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:sona/ui/widgets/menu.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';

@RoutePage()
class ServicesOptionsScreen extends StatelessWidget {
  const ServicesOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      actionButton: SonaActionButton.home(),
      body: Column(
        children: [
          GridMenu(
            buttons: [
              MenuButton(label: 'Chatbot', icon: Icons.android, onPressed: () => AutoRouter.of(context).push(const ChatBotRoute())),
              MenuButton(
                label: 'Chat con Profesionales',
                icon: Icons.chat,
                onPressed: () => AutoRouter.of(context).push(const ChatRoute()),
              ),
              MenuButton(
                label: 'Agendamiento de Citas',
                icon: Icons.calendar_today,
                onPressed: () => AutoRouter.of(context).pushNamed('/appointments'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
