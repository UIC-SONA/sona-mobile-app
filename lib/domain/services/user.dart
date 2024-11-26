import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:sona/domain/models/message.dart';
import 'package:sona/domain/models/user.dart';
import 'package:sona/domain/services/auth.dart';
import 'package:sona/shared/constants.dart';
import 'package:sona/shared/http/http.dart';

abstract class UserService {
  //
  Future<Message> signUp({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
  });

  Future<Uint8List> profilePicture();

  Future<Message> uploadProfilePicture(String filePath);

  Future<Message> deleteProfilePicture();

  Future<List<User>> users();
}

class ApiUserService implements UserService {
  //
  //
  final AuthProvider authProvider;

  ApiUserService({required this.authProvider});

  @override
  Future<Message> signUp({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final response = await request(
      apiUri.replace(path: '/user/sign-up'),
      method: HttpMethod.post,
      headers: {'Content-Type': 'application/json'},
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
  Future<Uint8List> profilePicture() async {
    final response = await request(
      apiUri.replace(path: '/user/profile-picture'),
      client: authProvider.client!,
      method: HttpMethod.get,
    );

    return response.bodyBytes;
  }

  @override
  Future<Message> uploadProfilePicture(String filePath) async {
    final StreamedResponse response = await multipartRequest(
      apiUri.replace(path: '/user/profile-picture'),
      client: authProvider.client!,
      method: HttpMethod.post,
      factory: (request) async {
        request.files.add(await MultipartFile.fromPath('file', filePath));
      },
    );

    return await response.getBody<Message>();
  }

  @override
  Future<Message> deleteProfilePicture() async {
    final response = await request(
      apiUri.replace(path: '/user/profile-picture'),
      client: authProvider.client!,
      method: HttpMethod.delete,
    );

    return response.getBody<Message>();
  }

  @override
  Future<List<User>> users() async {
    final response = await request(
      apiUri.replace(path: '/chat/users'),
      client: authProvider.client!,
      method: HttpMethod.get,
      headers: {'Content-Type': 'application/json'},
    );

    return response.getBody<List<User>>();
  }
}
