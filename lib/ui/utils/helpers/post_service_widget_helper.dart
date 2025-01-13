import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/services/post.dart';
import 'package:sona/shared/crud.dart';
import 'package:sona/shared/schemas/page.dart';
import 'package:sona/ui/utils/helpers/user_service_widget_helper.dart';

class PostWithUser extends Post {
  final User? userAuthor;
  final List<CommentWithUser> commentsWithUser;

  PostWithUser({
    required this.userAuthor,
    required this.commentsWithUser,
    required super.id,
    required super.content,
    required super.comments,
    required super.likedBy,
    required super.createdAt,
    required super.author,
  });
}

class CommentWithUser extends Comment {
  final User? userAuthor;

  CommentWithUser({
    required this.userAuthor,
    required super.id,
    required super.content,
    required super.likedBy,
    required super.createdAt,
    required super.author,
  });
}

mixin PostServiceWidgetHelper on UserServiceWidgetHelper {
  //
  PostService get postService;

  Future<PostWithUser> findPostWithUser(String postId) async {
    final post = await postService.find(postId);
    return await _findAuthors(post);
  }

  Future<Page<PostWithUser>> pagePostWithUser(PageQuery query) async {
    final page = await postService.page(query);
    final posts = <PostWithUser>[];
    for (final post in page.content) {
      posts.add(await _findAuthors(post));
    }
    return Page(
      content: posts,
      page: page.page,
    );
  }

  Future<PostWithUser> _findAuthors(Post post) async {
    final user = post.author != null ? await findUser(post.author!) : null;
    final comments = <CommentWithUser>[];
    for (final comment in post.comments) {
      comments.add(CommentWithUser(
        userAuthor: comment.author != null ? await findUser(comment.author!) : null,
        id: comment.id,
        content: comment.content,
        likedBy: comment.likedBy,
        createdAt: comment.createdAt,
        author: comment.author,
      ));
    }

    return PostWithUser(
      userAuthor: user,
      commentsWithUser: comments,
      id: post.id,
      content: post.content,
      comments: post.comments,
      likedBy: post.likedBy,
      createdAt: post.createdAt,
      author: post.author,
    );
  }
}
