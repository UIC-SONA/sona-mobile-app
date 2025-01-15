import 'package:flutter/material.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/shared/utils/time_formatters.dart';
import 'package:sona/ui/utils/helpers/post_service_widget_helper.dart';
import 'package:sona/ui/utils/helpers/user_service_widget_helper.dart';
import 'package:sona/ui/utils/dialogs.dart';
import 'package:sona/ui/widgets/full_state_widget.dart';

class PostCard extends StatefulWidget {
  final ValueNotifier<PostWithUser> notifier;
  final VoidCallback? onComment;

  const PostCard({
    super.key,
    required this.notifier,
    this.onComment,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends FullState<PostCard> with UserServiceWidgetHelper, PostServiceWidgetHelper {
  @override
  final userService = injector.get<UserService>();
  @override
  final postService = injector.get<PostService>();

  ValueNotifier<PostWithUser> get notifier => widget.notifier;

  void _toggleLike(bool isLiked) async {
    final post = notifier.value;
    await (isLiked ? postService.unlikePost(post) : postService.likePost(post));
    notifier.value = await findPostWithUser(post.id);
  }

  void _reportPost() async {
    final confirmed = await showAlertDialog<bool>(
      context,
      title: 'Reportar publicación',
      message: '¿Estás seguro de que deseas reportar esta publicación?',
      actions: {
        'Cancelar': () => Navigator.of(context).pop(false),
        'Reportar': () => Navigator.of(context).pop(true),
      },
    );
    if (confirmed == true) {
      await postService.reportPost(notifier.value);
      if (!mounted) return;
      showSnackBar(context, content: const Text('Publicación reportada'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = userService.currentUser;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAuthorAvatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAuthorName(),
                      Text(
                        formatDate(notifier.value.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder(
              valueListenable: notifier,
              builder: (context, post, _) {
                return Text(
                  post.content,
                  maxLines: null,
                  softWrap: true,
                );
              },
            ),
            // Contador de likes y comentarios
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ValueListenableBuilder(
                  valueListenable: notifier,
                  builder: (context, post, _) {
                    final isLiked = post.likedBy.contains(user.id);
                    return TextButton.icon(
                      onPressed: () => _toggleLike(isLiked),
                      icon: isLiked
                          ? const Icon(Icons.thumb_up)
                          : const Icon(
                              Icons.thumb_up_outlined,
                              color: Colors.black,
                            ),
                      label: Text('${post.likedBy.length}'),
                    );
                  },
                ),
                //comentarios
                const SizedBox(width: 16),
                ValueListenableBuilder(
                  valueListenable: notifier,
                  builder: (context, post, _) {
                    return TextButton.icon(
                      onPressed: widget.onComment,
                      icon: const Icon(Icons.comment_outlined),
                      label: Text('${post.comments.length}'),
                    );
                  },
                ),
                const SizedBox(width: 16),
                ValueListenableBuilder(
                  valueListenable: notifier,
                  builder: (context, post, _) {
                    return IconButton(
                      color: Theme.of(context).primaryColor,
                      icon: const Icon(Icons.flag_outlined),
                      onPressed: _reportPost,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorAvatar() {
    final post = notifier.value;
    return CircleAvatar(
      child: post.author != null ? buildFutureUserPicture(post.author!) : const Icon(Icons.person),
    );
  }

  Widget _buildAuthorName() {
    final author = notifier.value.userAuthor;
    if (author == null) {
      return const Text(
        'Anónimo',
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    }

    return Text(
      author.username,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
