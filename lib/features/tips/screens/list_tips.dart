import 'package:flutter/material.dart';
import 'package:sona/application/widgets/full_state_widget.dart';
import 'package:sona/application/widgets/sona_scaffold.dart';

import 'package:sona/features/tips/services.dart' as service;

class ListTips extends StatefulWidget {
  const ListTips({super.key});

  @override
  State<ListTips> createState() => _ListTipsState();
}

class _ListTipsState extends FullState<ListTips> {
  //
  late final _tips = fetchState(service.listActiveTips);

  @override
  void initState() {
    super.initState();
    _tips.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      actionButton: SonaActionButton.options(),
      body: _tips.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error) => Center(child: Text(error.toString())),
        data: (tips) => ListView.builder(
          itemCount: tips.length,
          itemBuilder: (context, index) {
            final tip = tips[index];
            return ListTile(
              title: Text(tip.title),
              subtitle: Text(tip.description),
              onTap: () => showAlertDialog(
                title: tip.title,
                message: tip.description,
              ),
            );
          },
        ),
      ),
    );
  }
}
