import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/models/tip.dart';
import 'package:sona/domain/services/tip.dart';
import 'package:sona/shared/crud.dart';
import 'package:sona/shared/schemas/direction.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:sona/ui/utils/paging.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';

@RoutePage()
class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  final _tipsService = injector.get<TipService>();
  final _pagingController = PagingQueryController<Tip>(firstPage: 0);

  @override
  void initState() {
    super.initState();
    _pagingController.configurePageRequestListener(_loadPageActiveTips);
  }

  Future<List<Tip>> _loadPageActiveTips(int page) async {
    final result = await _tipsService.actives(PageQuery(
      page: page,
      sort: [
        Sort('createdDate', Direction.desc),
      ],
    ));
    return result.content;
  }

  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
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
      body: RefreshIndicator(
        onRefresh: () => Future.sync(_pagingController.refresh),
        child: PagedListView<int, Tip>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<Tip>(
            noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('No se encontraron tips.')),
            itemBuilder: (context, tip, index) {
              final notifier = ValueNotifier(tip);
              return _TipCard(notifier: notifier);
            },
          ),
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final ValueNotifier<Tip> notifier;

  const _TipCard({required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Tip>(
      valueListenable: notifier,
      builder: (context, tip, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
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
                        onPressed: () => context.router.push(TipDetailsRoute(
                          tip: tip,
                          notifier: notifier,
                        )),
                        child: const Text('Ver más'),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${tip.averageRate.toStringAsFixed(1)} (${tip.totalRate})',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
