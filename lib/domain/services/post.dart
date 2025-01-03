import 'dart:convert';

import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/providers/auth.dart';
import 'package:sona/domain/providers/locale.dart';
import 'package:sona/shared/constants.dart';
import 'package:sona/shared/crud.dart';
import 'package:sona/shared/http/http.dart';
import 'package:sona/shared/rest_crud.dart';
import 'package:sona/shared/schemas/message.dart';
import 'package:http/http.dart' as http;

class PostDto {
  final bool? anonymous;
  final String content;

  PostDto({
    this.anonymous,
    required this.content,
  });

  @override
  String toString() {
    return 'PostDto(anonymous: $anonymous, content: $content)';
  }

  Map<String, dynamic> toJson() {
    return {
      'anonymous': anonymous,
      'content': content,
    };
  }
}

abstract class PostService implements CrudOperations<Post, PostDto, String> {
  Future<Comment> createComment({
    required String postId,
    required String content,
    bool? anonymous,
  });

  Future<Message> deleteComment({
    required String postId,
    required String commentId,
  });

  Future<Message> likePost(Post post);

  Future<Message> unlikePost(Post post);

  Future<Message> reportPost(Post post);

  Future<Message> likeComment(Post post, Comment comment);

  Future<Message> unlikeComment(Post post, Comment comment);

  Future<Message> reportComment(Post post, Comment comment);
}

class ApiPostService extends RestCrudOperations<Post, PostDto, String> implements PostService {
  //
  final AuthProvider authProvider;
  final LocaleProvider localeProvider;

  ApiPostService({required this.authProvider, required this.localeProvider});

  @override
  Uri get uri => apiUri;

  @override
  http.Client? get client => authProvider.client;

  @override
  Map<String, String> get commonHeaders => {'Accept-Language': localeProvider.languageCode};

  @override
  String get path => '/forum';

  @override
  Future<Post> create(PostDto dto) async {
    final response = await request(
      uri.replace(path: path),
      client: client,
      method: HttpMethod.post,
      headers: {
        ...commonHeaders,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(dto.toJson()),
    );

    return response.getBody<Post>();
  }

  @override
  Future<Comment> createComment({required String postId, required String content, bool? anonymous}) async {
    final response = await request(
      uri.replace(path: '$path/$postId/comments'),
      client: client,
      method: HttpMethod.post,
      headers: {
        ...commonHeaders,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'content': content,
        'anonymous': anonymous,
      }),
    );
    return response.getBody<Comment>();
  }

  @override
  Future<Message> deleteComment({required String postId, required String commentId}) async {
    final response = await request(
      uri.replace(path: '$path/$postId/comments/$commentId'),
      client: client,
      method: HttpMethod.delete,
      headers: commonHeaders,
    );
    return response.getBody<Message>();
  }

  @override
  Future<Message> likePost(Post post) async {
    final response = await request(
      uri.replace(path: '$path/${post.id}/like'),
      client: client,
      method: HttpMethod.post,
      headers: commonHeaders,
    );
    return response.getBody<Message>();
  }

  @override
  Future<Message> unlikePost(Post post) async {
    final response = await request(
      uri.replace(path: '$path/${post.id}/unlike'),
      client: client,
      method: HttpMethod.post,
      headers: commonHeaders,
    );
    return response.getBody<Message>();
  }

  @override
  Future<Message> reportPost(Post post) async {
    final response = await request(
      uri.replace(path: '$path/${post.id}/report'),
      client: client,
      method: HttpMethod.post,
      headers: commonHeaders,
    );
    return response.getBody<Message>();
  }

  @override
  Future<Message> likeComment(Post post, Comment comment) async {
    final response = await request(
      uri.replace(path: '$path/${post.id}/comments/${comment.id}/like'),
      client: client,
      method: HttpMethod.post,
      headers: commonHeaders,
    );
    return response.getBody<Message>();
  }

  @override
  Future<Message> unlikeComment(Post post, Comment comment) async {
    final response = await request(
      uri.replace(path: '$path/${post.id}/comments/${comment.id}/unlike'),
      client: client,
      method: HttpMethod.post,
      headers: commonHeaders,
    );
    return response.getBody<Message>();
  }

  @override
  Future<Message> reportComment(Post post, Comment comment) async {
    final response = await request(
      uri.replace(path: '$path/${post.id}/comments/${comment.id}/report'),
      client: client,
      method: HttpMethod.post,
      headers: commonHeaders,
    );
    return response.getBody<Message>();
  }
}
