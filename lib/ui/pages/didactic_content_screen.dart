import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/models/models.dart';

import 'package:sona/domain/services/services.dart';
import 'package:sona/shared/crud.dart';
import 'package:sona/shared/schemas/direction.dart';
import 'package:sona/ui/utils/paging.dart';

import 'package:sona/ui/widgets/full_state_widget.dart';
import 'package:sona/ui/widgets/image_builder.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';

@RoutePage()
class DidacticContentScreen extends StatefulWidget {
  const DidacticContentScreen({super.key});

  @override
  State<DidacticContentScreen> createState() => _DidacticContentScreenState();
}

class _DidacticContentScreenState extends FullState<DidacticContentScreen> {
  final _didacticContentService = injector.get<DidacticContentService>();
  final _pagingController = PagingQueryController<DidaticContent>(firstPage: 0);

  @override
  void initState() {
    super.initState();
    _pagingController.configurePageRequestListener(_loadPageDidacticContent);
  }

  Future<List<DidaticContent>> _loadPageDidacticContent(int page) async {
    final result = await _didacticContentService.page(PageQuery(
      page: page,
      properties: ['createdDate'],
      direction: Direction.desc,
    ));

    return result.content;
  }

  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      actionButton: const SizedBox(),
      padding: 20,
      body: _buildDidacticContent(),
    );
  }

  Widget _buildDidacticContent() {
    return RefreshIndicator(
      onRefresh: () {
        return Future.sync(_pagingController.refresh);
      },
      child: PagedListView<int, DidaticContent>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<DidaticContent>(
          noItemsFoundIndicatorBuilder: (context) {
            return const Center(
              child: Text('No se encontraron contenidos didácticos'),
            );
          },
          itemBuilder: (context, didaticContent, index) {
            return DidacticContentExpansionTile(
              didaticContent: didaticContent,
            );
          },
        ),
      ),
    );
  }
}

class DidacticContentExpansionTile extends StatefulWidget {
  final DidaticContent didaticContent;

  const DidacticContentExpansionTile({
    super.key,
    required this.didaticContent,
  });

  @override
  State<DidacticContentExpansionTile> createState() => _DidacticContentExpansionTileState();
}

class _DidacticContentExpansionTileState extends State<DidacticContentExpansionTile> with SingleTickerProviderStateMixin {
  final _didacticContentService = injector.get<DidacticContentService>();
  late AnimationController _iconController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _iconController.forward();
      } else {
        _iconController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const fontFamily = 'Raleway';
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: Text(
                widget.didaticContent.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
          ),
          // Content preview row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ImageBuilder(
                  provider: _didacticContentService.image(widget.didaticContent.id),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    color: Colors.white,
                    onPressed: _toggleExpand,
                    icon: Icon(
                      _isExpanded ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.all(20.0),
              child: MarkdownBody(
                data: _isExpanded ? widget.didaticContent.content : '',
                styleSheet: MarkdownStyleSheet(
                  textAlign: WrapAlignment.spaceEvenly,
                  p: const TextStyle(fontFamily: fontFamily, fontSize: 16),
                  h1: const TextStyle(fontFamily: fontFamily, fontSize: 24, fontWeight: FontWeight.bold),
                  h2: const TextStyle(fontFamily: fontFamily, fontSize: 22, fontWeight: FontWeight.bold),
                  h3: const TextStyle(fontFamily: fontFamily, fontSize: 20, fontWeight: FontWeight.bold),
                  h4: const TextStyle(fontFamily: fontFamily, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
