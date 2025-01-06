import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sona/config/dependency_injection.dart';

import 'package:sona/domain/models/tip.dart';
import 'package:sona/domain/services/tip.dart';
import 'package:sona/shared/crud.dart';
import 'package:sona/shared/schemas/direction.dart';
import 'package:sona/ui/utils/paging.dart';

import 'package:sona/ui/widgets/full_state_widget.dart';
import 'package:sona/ui/widgets/image_builder.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';

@RoutePage()
class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends FullState<TipsScreen> {
  final _tipsService = injector.get<TipService>();
  final _pagingController = PagingQueryController<Tip>(firstPage: 0);

  Tip? selectedTip;

  @override
  void initState() {
    super.initState();
    _pagingController.configurePageRequestListener(_loadPageActiveTips);
  }

  Future<List<Tip>> _loadPageActiveTips(int page) async {
    final result = await _tipsService.actives(PageQuery(
      page: page,
      properties: ['createdDate'],
      direction: Direction.desc,
    ));
    return result.content;
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
    return RefreshIndicator(
      onRefresh: () => Future.sync(_pagingController.refresh),
      child: PagedListView<int, Tip>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Tip>(
          noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('No se encontraron tips.')),
          itemBuilder: _tipBuilder,
        ),
      ),
    );
  }

  Widget _tipBuilder(context, tip, index) {
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
                subtitle: Text(
                  tip.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: ElevatedButton(
                onPressed: () => _selectTip(tip),
                child: const Text('Ver más'),
              ),
            ),
          ],
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
                          styleSheet: MarkdownStyleSheet(textAlign: WrapAlignment.spaceEvenly, p: const TextStyle(fontSize: 15)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ImageBuilder(
                      provider: _tipsService.image(tip),
                    ),
                  ),
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

// Widget _buildImage(Tip tip) {
//   return FutureBuilder<Uint8List>(
//     future: _service.tipImage(tip.id),
//     builder: (context, snapshot) {
//       if (snapshot.connectionState == ConnectionState.waiting) {
//         return const Center(child: CircularProgressIndicator());
//       }
//       if (snapshot.hasError) {
//         return Text(
//           'Error al cargar la imagen: ${snapshot.error}',
//           style: const TextStyle(color: Colors.red),
//         );
//       }
//       if (snapshot.hasData && snapshot.data != null) {
//         return Image.memory(
//           snapshot.data!,
//           fit: BoxFit.cover,
//         );
//       }
//       return const Text('No se pudo cargar la imagen.');
//     },
//   );
// }
}
