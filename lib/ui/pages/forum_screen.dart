import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/models/models.dart';

import 'package:sona/domain/services/services.dart';
import 'package:sona/shared/crud.dart';
import 'package:sona/shared/schemas/direction.dart';
import 'package:sona/shared/schemas/page.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:sona/ui/utils/cached_user_screen.dart';
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

class _ForumScreenState extends FullState<ForumScreen> with UserServiceWidgetHelper {
  final _postService = injector.get<PostService>();
  final _userService = injector.get<UserService>();
  final _pagingController = PagingQueryController<Post>(firstPage: 0);

  @override
  UserService get userService => _userService;

  @override
  void initState() {
    super.initState();
    _pagingController.configureFetcher(_fetcher);
  }

  Future<Page<Post>> _fetcher(PageQuery query) async {
    return await _postService.page(query.copyWith(properties: ['createdAt'], direction: Direction.desc));
  }

  void _openCommentsScreen(ValueNotifier<Post> forum) async {
    context.router.push<Post>(
      ForumCommentsRoute(
        forum: forum.value,
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
      child: PagedListView<int, Post>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Post>(
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
