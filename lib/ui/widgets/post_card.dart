import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/ui/utils/cached_user_screen.dart';
import 'package:sona/ui/utils/dialogs.dart';
import 'package:sona/ui/widgets/full_state_widget.dart';
import 'package:sona/ui/widgets/image_builder.dart';

class PostCard extends StatefulWidget {
  final ValueNotifier<Post>? notifier;
  final Post? post;
  final bool showImages;
  final bool truncateContent;

  const PostCard({
    super.key,
    this.post,
    this.notifier,
    required this.showImages,
    required this.truncateContent,
  })  : assert(post != null || notifier != null, 'Either post or notifier must be provided'),
        assert(post == null || notifier == null, 'Only one of post or notifier must be provided');

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends FullState<PostCard> with UserServiceWidgetHelper {
  final _userService = injector.get<UserService>();
  final _postService = injector.get<PostService>();
  late ValueNotifier<Post> _post;

  @override
  UserService get userService => _userService;

  @override
  void initState() {
    super.initState();
    _post = widget.notifier ?? ValueNotifier(widget.post!);
  }

  void _toggleLike(bool isLiked) async {
    final post = _post.value;
    await (isLiked ? _postService.unlikePost(post.id) : _postService.likePost(post.id));
    _post.value = await _postService.find(post.id);
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
      await _postService.reportPost(_post.value.id);
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
                        _formatDate(_post.value.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder(
              valueListenable: _post,
              builder: (context, post, _) {
                return Text(
                  post.content,
                  maxLines: widget.truncateContent ? 3 : null,
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
            const SizedBox(height: 12),
            // Imágenes si existen
            if (widget.showImages && _post.value.images.isNotEmpty) ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _post.value.images.length,
                itemBuilder: (context, index) {
                  final image = _post.value.images[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ImageBuilder(
                      provider: _postService.image(image),
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],

            // Contador de likes y comentarios
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ValueListenableBuilder(
                  valueListenable: _post,
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
                  valueListenable: _post,
                  builder: (context, post, _) {
                    return TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.comment_outlined),
                      label: Text('${post.comments.length}'),
                    );
                  },
                ),
                const SizedBox(width: 16),
                ValueListenableBuilder(
                  valueListenable: _post,
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
    final post = _post.value;
    return CircleAvatar(
      child: post.author != null ? buildProfilePicture(post.author!) : const Icon(Icons.person),
    );
  }

  Widget _buildAuthorName() {
    final author = _post.value.author;
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
          user.representation.username,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMM, yyyy').format(date);
  }
}
