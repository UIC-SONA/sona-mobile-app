import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sona/local_notifications.dart';
import 'package:sona/ui/widgets/full_state_widget.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';

@RoutePage()
class SchedulePushScreen extends StatefulWidget {
  const SchedulePushScreen({super.key});

  @override
  State<SchedulePushScreen> createState() => _SchedulePushScreenState();
}

class _SchedulePushScreenState extends FullState<SchedulePushScreen> {
  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      actionButton: SonaActionButton.home(),
      body: Column(
        children: [
          LocalNotifications.buildScheduledNotificationsList(),
        ],
      ),
    );
  }
}
