import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sona/config/dependency_injection.dart';

import 'package:sona/domain/models/tip.dart';
import 'package:sona/domain/services/tip.dart';
import 'package:sona/local_notifications.dart';
import 'package:sona/shared/crud.dart';
import 'package:sona/shared/schemas/direction.dart';
import 'package:sona/ui/utils/paging.dart';

import 'package:sona/ui/widgets/full_state_widget.dart';
import 'package:sona/ui/widgets/image_builder.dart';
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
      body: LocalNotifications.buildScheduledNotificationsList(),
    );
  }
}
