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
import 'package:sona/ui/widgets/post_card.dart';
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
  final _pagingController = PagingQueryController<ValueNotifier<Post>>(firstPage: 0);

  @override
  UserService get userService => _userService;

  @override
  void initState() {
    super.initState();
    _pagingController.configureFetcher(_fetcher);
  }

  Future<Page<ValueNotifier<Post>>> _fetcher(PageQuery query) async {
    final page = await _postService.page(query.copyWith(properties: ['createdAt'], direction: Direction.desc));
    return page.map((post) => ValueNotifier(post));
  }

  void _openPostScreen(ValueNotifier<Post> postNotifier) async {
    context.router.push(ForumPostRoute(notifier: postNotifier));
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
      body: _buildForumPost(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.router.push(const ForumNewPostRoute());
          _pagingController.refresh();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildForumPost() {
    return RefreshIndicator(
      onRefresh: () {
        return Future.sync(_pagingController.refresh);
      },
      child: PagedListView<int, ValueNotifier<Post>>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<ValueNotifier<Post>>(
          noItemsFoundIndicatorBuilder: (context) {
            return const Center(
              child: Text('No hay publicaciones'),
            );
          },
          itemBuilder: (context, notifier, index) {
            return GestureDetector(
              child: PostCard(
                notifier: notifier,
                showImages: false,
                truncateContent: true,
              ),
              onTap: () => _openPostScreen(notifier),
            );
          },
        ),
      ),
    );
  }
}
