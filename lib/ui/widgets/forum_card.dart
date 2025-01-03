import 'package:flutter/material.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/shared/utils/time_formatters.dart';
import 'package:sona/ui/utils/cached_user_screen.dart';
import 'package:sona/ui/utils/dialogs.dart';
import 'package:sona/ui/widgets/full_state_widget.dart';

class PostCard extends StatefulWidget {
  final ValueNotifier<Post> notifier;
  final VoidCallback? onComment;

  const PostCard({
    super.key,
    required this.notifier,
    this.onComment,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends FullState<PostCard> with UserServiceWidgetHelper {
  final _userService = injector.get<UserService>();
  final _forumService = injector.get<PostService>();

  @override
  UserService get userService => _userService;

  ValueNotifier<Post> get notifier => widget.notifier;

  void _toggleLike(bool isLiked) async {
    final post = notifier.value;
    await (isLiked ? _forumService.unlikePost(post) : _forumService.likePost(post));
    notifier.value = await _forumService.find(post.id);
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
      await _forumService.reportPost(notifier.value);
      if (!mounted) return;
      showSnackBar(context, content: const Text('Publicación reportada'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _userService.currentUser;

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
      child: post.author != null ? buildProfilePicture(post.author!) : const Icon(Icons.person),
    );
  }

  Widget _buildAuthorName() {
    final author = notifier.value.author;
    if (author == null) {
      return const Text(
        'Anónimo',
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    }

    return FutureBuilder(
      future: getUser(author),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Icon(Icons.person, color: Colors.black);
        }
        if (snapshot.hasError) {
          return const Icon(Icons.error, color: Colors.black);
        }
        final user = snapshot.data as User;
        return Text(
          user.username,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}
