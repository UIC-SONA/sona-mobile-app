import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:sona/ui/utils/helpers/post_service_widget_helper.dart';
import 'package:sona/ui/utils/paging.dart';
import 'package:sona/ui/widgets/forum_card.dart';

class PostListView extends StatelessWidget {
  final PagingQueryController<PostWithUser> controller;

  const PostListView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, PostWithUser>(
      pagingController: controller,
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
            onComment: () => _openCommentsScreen(notifier, context),
          );
        },
      ),
    );
  }
}

class PostSliverList extends StatelessWidget {
  final PagingQueryController<PostWithUser> controller;

  const PostSliverList({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return PagedSliverList<int, PostWithUser>(
      pagingController: controller,
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
            onComment: () => _openCommentsScreen(notifier, context),
          );
        },
      ),
    );
  }
}

void _openCommentsScreen(ValueNotifier<PostWithUser> forum, BuildContext context) async {
  context.router.push(ForumPostCommentsRoute(
    post: forum.value,
    onPop: (result) {
      forum.value = result;
    },
  ));
}
