import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:sona/shared/extensions.dart';
import 'package:sona/shared/rest_crud.dart';
import 'package:sona/shared/crud.dart';
import 'package:sona/shared/schemas/message.dart';
import 'package:sona/domain/models/user.dart';
import 'package:sona/domain/providers/auth.dart';
import 'package:sona/domain/providers/locale.dart';
import 'package:sona/shared/constants.dart';
import 'package:sona/shared/http/http.dart';
import 'package:sona/shared/schemas/page.dart';

abstract class UserService implements ReadOperations<User, int> {
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

  Future<User> profile();

  Future<List<User>> listByRole(Authority role);

  Future<Page<User>> pageByRole(Authority role, [PageQuery? query]);

  static User notFound = User(
    id: -1,
    representation: UserRepresentation(
      firstName: 'Usuario',
      lastName: 'no encontrado',
      id: '',
      username: '',
      email: '',
      emailVerified: false,
    ),
    keycloakId: '',
    profilePicturePath: '',
    authorities: [],
  );
}

class ApiUserService extends RestReadOperations<User, int> implements UserService {
  //
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
  Future<Uint8List> profilePicture() async {
    final response = await request(
      uri.replace(path: '$path/profile-picture'),
      client: client,
      method: HttpMethod.get,
      headers: commonHeaders,
    );

    return response.bodyBytes;
  }

  @override
  Future<Message> uploadProfilePicture(String filePath) async {
    final StreamedResponse response = await multipartRequest(
      uri.replace(path: '$path/profile-picture'),
      client: client,
      method: HttpMethod.post,
      headers: commonHeaders,
      factory: (request) async {
        request.files.add(await MultipartFile.fromPath('file', filePath));
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
  Future<List<User>> listByRole(Authority role) async {
    final response = await request(
      uri.replace(path: '$path/role/${role.javaName}'),
      client: client,
      method: HttpMethod.get,
      headers: commonHeaders,
    );

    return response.getBody<List<User>>();
  }

  @override
  Future<Page<User>> pageByRole(Authority role, [PageQuery? query]) async {
    final response = await request(
      uri.replace(path: '$path/role/${role.javaName}/page', queryParameters: query?.toQueryParameters()),
      client: client,
      method: HttpMethod.get,
      headers: commonHeaders,
    );

    return response.getBody<PageMap>().as<User>();
  }
}
