import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';

import '../../theme/icons.dart';

@RoutePage()
class AppointmentMenuScreen extends StatelessWidget {
  const AppointmentMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      actionButton: SonaActionButton.home(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestión de Citas',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona una opción para continuar',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
            const SizedBox(height: 24),
            _MenuCard(
              title: 'Agendar Nueva Cita',
              description: 'Programa una cita con un profesional',
              icon: SonaIcons.calendar,
              onTap: () => AutoRouter.of(context).push(const NewAppointmentRoute()),
            ),
            const SizedBox(height: 16),
            _MenuCard(
              title: 'Mis Citas',
              description: 'Ver y gestionar tus citas programadas',
              icon: SonaIcons.clock,
              onTap: () => AutoRouter.of(context).push(const MyAppointmentsRoute()),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withAlpha(50),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(description),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
