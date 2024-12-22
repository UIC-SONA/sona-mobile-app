import 'package:auto_route/annotations.dart';
import 'package:intl/intl.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/models/models.dart';

import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/ui/utils/cached_user_screen.dart';
import 'package:sona/ui/utils/dialogs.dart';
import 'package:sona/ui/widgets/full_state_widget.dart';
import 'package:sona/ui/widgets/loading_button.dart';
import 'package:sona/ui/widgets/post_card.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';

@RoutePage()
class ForumPostScreen extends StatefulWidget {
  final ValueNotifier<Post> notifier;

  const ForumPostScreen({super.key, required this.notifier});

  @override
  State<ForumPostScreen> createState() => _ForumPostScreenState();
}

class _ForumPostScreenState extends FullState<ForumPostScreen> with UserServiceWidgetHelper {
  final _postService = injector.get<PostService>();
  final _userService = injector.get<UserService>();
  final _commentController = TextEditingController();

  bool _sendingComment = false;

  @override
  dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  UserService get userService => _userService;

  ValueNotifier<Post> get notifier => widget.notifier;

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      final post = notifier.value;
      Future<void> createComment(bool anonymous) async {
        _sendingComment = true;
        refresh();
        await _postService.createComment(
          postId: post.id,
          content: _commentController.text,
          anonymous: anonymous,
        );
      }

      if (_userService.currentUser.anonymous) {
        await createComment(true);
      } else {
        final anonymous = await showAlertDialog<bool?>(
          context,
          title: 'Comentario anónimo',
          message: 'Actualmente tienes el modo anonimo desactivado, ¿Deseas comentar de forma anónima?',
          actions: {
            'Sí': () => Navigator.of(context).pop(true),
            'No': () => Navigator.of(context).pop(false),
          },
        );
        if (anonymous == null) return;
        await createComment(anonymous);
      }
      notifier.value = await _postService.find(post.id);
      _commentController.clear();
    } catch (e) {
      if (!mounted) return;
      showAlertErrorDialog(context, error: e);
    } finally {
      _sendingComment = false;
      refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _userService.currentUser;

    return SonaScaffold(
      actionButton: SonaActionButton.home(),
      body: ListView(
        children: [
          PostCard(
            notifier: notifier,
            showImages: true,
            truncateContent: false,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(child: buildProfilePicture(user.id)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextField(
                          enabled: !_sendingComment,
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Agregar un comentario...',
                          ),
                          maxLines: 3,
                          minLines: 1,
                        ),
                        const SizedBox(height: 8),
                        LoadingButton(
                          loading: _sendingComment,
                          onPressed: _submitComment,
                          icon: const Icon(Icons.send),
                          child: const Text('Comentar'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder(
            valueListenable: notifier,
            builder: (context, post, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...buildComments(post.comments),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Iterable<Widget> buildComments(List<Comment> comments) {
    return comments.reversed.map(
      (comment) => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              child: comment.author != null ? buildProfilePicture(comment.author!) : const Icon(Icons.person),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                margin: const EdgeInsets.all(0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          comment.author != null
                              ? buildUserName(comment.author!)
                              : const Text(
                                  'Anónimo',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(comment.createdAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(comment.content),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMM, yyyy').format(date);
  }
}
