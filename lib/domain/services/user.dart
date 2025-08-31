import 'dart:convert';

import 'package:flutter/material.dart' hide Page;
import 'package:http/http.dart';
import 'package:http_image_provider/http_image_provider.dart';
import 'package:sona/shared/rest_crud.dart';
import 'package:sona/shared/crud.dart';
import 'package:sona/shared/schemas/message.dart';
import 'package:sona/domain/models/user.dart';
import 'package:sona/domain/providers/auth.dart';
import 'package:sona/domain/providers/locale.dart';
import 'package:sona/shared/constants.dart';
import 'package:sona/shared/http/http.dart';

mixin UserService implements ReadOperations<User, int> {
  User? _currentUser;

  User get currentUser => _currentUser ?? notFound;

  //
  Future<Message> signUp({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
  });

  ImageProvider<Object> profilePicture({int? userId});

  String profilePictureUrl(int userId);

  Future<Message> uploadProfilePicture(String filePath);

  Future<Message> deleteProfilePicture();

  Future<User> profile();

  Future<Message> anonymize(bool anonymize);

  Future<Message> changePassword({required String newPassword});

  Future<Message> resetPassword({required String emailOrUsername});

  Future<void> refreshCurrentUser() async {
    _currentUser = await profile();
  }

  static User notFound = User(
    id: -1,
    firstName: 'Usuario',
    lastName: 'no encontrado',
    username: '',
    email: '',
    keycloakId: '',
    authorities: [],
    anonymous: false,
    hasProfilePicture: false,
  );
}

class ApiUserService extends RestReadOperations<User, int> with UserService {
  //
  final AuthProvider authProvider;
  final LocaleProvider localeProvider;

  ApiUserService({required this.authProvider, required this.localeProvider});

  @override
  Uri get uri => apiUri;

  @override
  Client? get client => authProvider.client;

  @override
  Map<String, String> get commonHeaders => {'Accept-Language': localeProvider.languageCode};

  @override
  String get path => '/user';

  @override
  Future<Message> signUp({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final response = await request(
      uri.replace(path: '$path/sign-up'),
      method: HttpMethod.post,
      headers: {
        'Content-Type': 'application/json',
        ...commonHeaders,
      },
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'password': password,
        'email': email,
      }),
    );

    return response.getBody<Message>();
  }

  @override
  ImageProvider<Object> profilePicture({int? userId}) {
    return HttpImageProvider(
      uri.replace(
        path: userId != null ? '$path/$userId/profile-picture' : '$path/profile-picture',
      ),
      headers: commonHeaders,
      client: client,
    );
  }

  @override
  String profilePictureUrl(int userId) {
    return uri.replace(path: '$path/$userId/profile-picture').toString();
  }

  @override
  Future<Message> uploadProfilePicture(String filePath) async {
    final StreamedResponse response = await multipartRequest(
      uri.replace(path: '$path/profile-picture'),
      client: client,
      method: HttpMethod.post,
      headers: commonHeaders,
      factory: (request) async {
        request.files.add(await MultipartFile.fromPath('photo', filePath));
      },
    );
    return await response.getBody<Message>();
  }

  @override
  Future<Message> deleteProfilePicture() async {
    final response = await request(
      uri.replace(path: '$path/profile-picture'),
      client: client,
      method: HttpMethod.delete,
      headers: commonHeaders,
    );
    return response.getBody<Message>();
  }

  @override
  Future<User> profile() async {
    final response = await request(
      uri.replace(path: '$path/profile'),
      client: client,
      method: HttpMethod.get,
      headers: commonHeaders,
    );

    return response.getBody<User>();
  }

  @override
  Future<Message> anonymize(bool anonymize) async {
    final response = await request(
      uri.replace(path: '$path/anonymize'),
      client: client,
      method: HttpMethod.post,
      headers: commonHeaders,
      body: {'anonymize': anonymize.toString()},
    );

    return response.getBody<Message>();
  }

  @override
  Future<Message> changePassword({required String newPassword}) async {
    final response = await request(
      uri.replace(path: '$path/password'),
      client: client,
      method: HttpMethod.put,
      headers: {
        ...commonHeaders,
      },
      body: {'newPassword': newPassword},
    );

    return response.getBody<Message>();
  }

  @override
  Future<Message> resetPassword({required String emailOrUsername}) async {
    final response = await request(
      uri.replace(path: '$path/password-reset'),
      client: client,
      method: HttpMethod.post,
      headers: {
        ...commonHeaders,
      },
      body: {'emailOrUsername': emailOrUsername},
    );

    return response.getBody<Message>();
  }
}
