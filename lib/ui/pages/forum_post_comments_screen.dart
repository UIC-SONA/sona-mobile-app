import 'package:auto_route/annotations.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/models/models.dart';

import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/shared/utils/time_formatters.dart';
import 'package:sona/ui/utils/helpers/post_service_widget_helper.dart';
import 'package:sona/ui/utils/helpers/user_service_widget_helper.dart';
import 'package:sona/ui/utils/dialogs.dart';
import 'package:sona/ui/widgets/full_state_widget.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';

@RoutePage()
class ForumPostCommentsScreen extends StatefulWidget {
  final PostWithUser post;
  final void Function(PostWithUser) onPop;

  const ForumPostCommentsScreen({
    super.key,
    required this.post,
    required this.onPop,
  });

  @override
  State<ForumPostCommentsScreen> createState() => _ForumPostCommentsScreenState();
}

class _ForumPostCommentsScreenState extends FullState<ForumPostCommentsScreen> with UserServiceWidgetHelper, PostServiceWidgetHelper {
  @override
  final postService = injector.get<PostService>();
  @override
  final userService = injector.get<UserService>();
  final commentController = TextEditingController();

  late PostWithUser post = widget.post;
  bool _sendingComment = false;

  @override
  dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (commentController.text.trim().isEmpty) return;

    try {
      Future<void> createComment(bool anonymous) async {
        _sendingComment = true;
        refresh();
        await postService.createComment(
          postId: post.id,
          content: commentController.text,
          anonymous: anonymous,
        );
      }

      if (userService.currentUser.anonymous) {
        await createComment(true);
      } else {
        final anonymous = await showAlertDialog<bool>(
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
      post = await findPostWithUser(post.id);
      commentController.clear();
    } catch (e) {
      if (!mounted) return;
      showAlertErrorDialog(context, error: e);
    } finally {
      _sendingComment = false;
      refresh();
    }
  }

  void _toggleLike(bool isLiked, Comment comment) async {
    if (isLiked) {
      await postService.unlikeComment(post, comment);
    } else {
      await postService.likeComment(post, comment);
    }
    post = await findPostWithUser(post.id);
    refresh();
  }

  void _reportComment(Comment comment) async {
    final confirmed = await showAlertDialog<bool>(
      context,
      title: 'Reportar comentario',
      message: '¿Estás seguro de que deseas reportar este comentario?',
      actions: {
        'Cancelar': () => Navigator.of(context).pop(false),
        'Reportar': () => Navigator.of(context).pop(true),
      },
    );
    if (confirmed == true) {
      await postService.reportComment(post, comment);
      if (!mounted) return;
      showSnackBar(context, content: const Text('Comentario reportado'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = userService.currentUser;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          widget.onPop(post);
        }
      },
      child: SonaScaffold(
        actionButton: SonaActionButton.home(),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: buildComments(post.comments),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end, // Alinea los elementos al final
                children: [
                  buildUserAvatar(user),
                  const SizedBox(width: 12),
                  // Expanded para que el TextField tome el espacio disponible
                  Expanded(
                    child: TextField(
                      enabled: !_sendingComment,
                      controller: commentController,
                      decoration: InputDecoration(
                          hintText: 'Agregar un comentario...',
                          suffixIcon: IconButton(
                            onPressed: _submitComment,
                            icon: const Icon(Icons.send),
                          )),
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildComments(List<Comment> comments) {
    final primaryColor = Theme.of(context).primaryColor;

    return comments.reversed.map((comment) {
      final isLiked = comment.likedBy.contains(userService.currentUser.id);

      return Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              child: comment.author != null ? buildFutureUserPicture(comment.author!) : const Icon(Icons.person),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
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
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(comment.content),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDate(comment.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => _toggleLike(isLiked, comment),
                            iconSize: 20,
                            padding: const EdgeInsets.all(0),
                            icon: isLiked ? Icon(Icons.thumb_up, color: primaryColor) : const Icon(Icons.thumb_up_outlined),
                          ),
                          Text(comment.likedBy.length.toString()),
                        ],
                      ),
                      IconButton(
                        onPressed: () => _reportComment(comment),
                        iconSize: 20,
                        padding: const EdgeInsets.all(0),
                        icon: const Icon(Icons.flag_outlined),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const Divider(),
          ],
        ),
      );
    }).toList();
  }
}
