import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http_image_provider/http_image_provider.dart';
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
  final List<String> imagePaths;

  PostDto({
    this.anonymous,
    required this.content,
    required this.imagePaths,
  });

  @override
  String toString() {
    return 'PostDto(anonymous: $anonymous, content: $content, imagePaths: $imagePaths)';
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

  Future<Message> likePost(String postId);

  Future<Message> unlikePost(String postId);

  Future<Message> reportPost(String postId);

  ImageProvider<Object> image(String imagePath);
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
  String get path => '/forum/post';

  @override
  Future<Post> create(PostDto dto) async {
    final reponse = await multipartRequest(
      uri.replace(path: path),
      client: client,
      method: HttpMethod.post,
      headers: {
        ...commonHeaders,
      },
      factory: (request) async {
        request.fields['content'] = dto.content;
        request.fields['anonymous'] = dto.anonymous.toString();
        for (var i = 0; i < dto.imagePaths.length; i++) {
          request.files.add(await http.MultipartFile.fromPath('images', dto.imagePaths[i]));
        }
      },
    );

    return await reponse.getBody<Post>();
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
  Future<Message> likePost(String postId) async {
    final response = await request(
      uri.replace(path: '$path/$postId/like'),
      client: client,
      method: HttpMethod.post,
      headers: commonHeaders,
    );
    return response.getBody<Message>();
  }

  @override
  Future<Message> unlikePost(String postId) async {
    final response = await request(
      uri.replace(path: '$path/$postId/unlike'),
      client: client,
      method: HttpMethod.post,
      headers: commonHeaders,
    );
    return response.getBody<Message>();
  }

  @override
  Future<Message> reportPost(String postId) async {
    final response = await request(
      uri.replace(path: '$path/$postId/report'),
      client: client,
      method: HttpMethod.post,
      headers: commonHeaders,
    );
    return response.getBody<Message>();
  }

  @override
  ImageProvider<Object> image(String imagePath) {
    return HttpImageProvider(
      uri.replace(path: "$path/image", queryParameters: {'imagePath': imagePath}),
      headers: commonHeaders,
      client: client,
    );
  }
}
