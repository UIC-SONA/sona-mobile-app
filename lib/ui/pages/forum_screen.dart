import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sona/shared/crud.dart';
import 'package:sona/shared/schemas/direction.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:sona/ui/utils/helpers/post_service_widget_helper.dart';
import 'package:sona/ui/utils/helpers/user_service_widget_helper.dart';
import 'package:sona/ui/utils/paging.dart';

import 'package:sona/ui/widgets/full_state_widget.dart';
import 'package:sona/ui/widgets/forum_card.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';

@RoutePage()
class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends FullState<ForumScreen> with UserServiceWidgetHelper, PostServiceWidgetHelper {
  final _pagingController = PagingQueryController<PostWithUser>(firstPage: 0);

  @override
  void initState() {
    super.initState();
    _pagingController.configurePageRequestListener(_loadPagePostWihtUser);
  }

  Future<List<PostWithUser>> _loadPagePostWihtUser(int page) async {
    final result = await pagePostWithUser(PageQuery(
      page: page,
      properties: ['createdAt'],
      direction: Direction.desc,
    ));
    return result.content;
  }

  void _openCommentsScreen(ValueNotifier<PostWithUser> forum) async {
    context.router.push(
      ForumPostCommentsRoute(
        post: forum.value,
        onPop: (result) {
          forum.value = result;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      actionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: const Text(
          'Foro',
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildForum(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.router.push(const ForumNewPostRoute());
          _pagingController.refresh();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildForum() {
    return RefreshIndicator(
      onRefresh: () {
        return Future.sync(_pagingController.refresh);
      },
      child: PagedListView<int, PostWithUser>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<PostWithUser>(
          noItemsFoundIndicatorBuilder: (context) {
            return const Center(
              child: Text('No hay publicaciones'),
            );
          },
          itemBuilder: (context, post, index) {
            final notifier = ValueNotifier(post);
            return PostCard(
              notifier: notifier,
              onComment: () => _openCommentsScreen(notifier),
            );
          },
        ),
      ),
    );
  }
}
