import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:sona/config/dependency_injection.dart';

import 'package:sona/domain/models/tip.dart';
import 'package:sona/domain/services/tip.dart';

import 'package:sona/ui/widgets/full_state_widget.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';

@RoutePage()
class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends FullState<TipsScreen> {
  final _service = injector.get<TipService>();

  late final _activeTipsState = fetchState(([positionalArguments, namedArguments]) => _service.activeTips());

  Tip? selectedTip;

  @override
  void initState() {
    super.initState();
    _activeTipsState.fetch();
  }

  void _clearSelection() {
    selectedTip = null;
    refresh();
  }

  void _selectTip(Tip tip) {
    selectedTip = tip;
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: selectedTip == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _clearSelection();
      },
      child: SonaScaffold(
        actionButton: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: const Text(
            'Tips',
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: selectedTip == null ? _buildTipsList() : _buildTipDetails(selectedTip!),
      ),
    );
  }

  Widget _buildTipsList() {
    return _activeTipsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error) => Center(child: Text(error.toString())),
      data: (tips) => RefreshIndicator(
        onRefresh: _activeTipsState.fetch,
        child: ListView.builder(
          itemCount: tips.length,
          itemBuilder: (context, index) {
            final tip = tips[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(0),
                        title: Text(
                          tip.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(tip.summary),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _selectTip(tip),
                      child: const Text('Ver más'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTipDetails(Tip tip) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(
                          tip.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        MarkdownBody(
                          data: tip.description,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildImage(tip),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 6.0,
                    children: [
                      for (final tag in tip.tags) Chip(label: Text(tag)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(Tip tip) {
    return FutureBuilder<Uint8List>(
      future: _service.tipImage(tip.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Text(
            'Error al cargar la imagen: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
          );
        } else {
          return const Text('No se pudo cargar la imagen.');
        }
      },
    );
  }
}
