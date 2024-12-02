import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:sona/shared/constants.dart';
import 'package:sona/shared/http/http.dart';

import '../models/user.dart';

abstract class AuthProvider<T extends http.Client> {
  //
  T? get client;

  Future<bool> isAutheticated();

  Future<void> logout();

  Future<T> login(String username, String password);

  Future<UserInfo> user();

  void addLogoutListener(void Function() listenner);
}

class KeycloakAuthProvider extends AuthProvider<oauth2.Client> {
  final FlutterSecureStorage storage;
  final List<void Function()> _logoutListeners = [];

  oauth2.Client? _client;

  // Para utilizar el endpoint de introspección, necesitamos enviar un encabezado
  // de autorización HTTP, para el servidor de autorización de keycloak, este
  // encabezado debe ser codificado en base64 y tener la forma `Basic <credenciales>`.
  final introspectionAuthorization = base64Encode(utf8.encode('$identifier:$secret'));

  /// Clave donde se almacenan las credenciales del usuario de forma
  /// persistente y segura utilizando el paquete `flutter_secure_storage`.
  static const credentialsKey = "credentials";

  KeycloakAuthProvider({required this.storage}) {
    storage.read(key: credentialsKey).then((value) {
      if (value != null) {
        final credentials = oauth2.Credentials.fromJson(value);
        _client = oauth2.Client(
          credentials,
          identifier: identifier,
          secret: secret,
          onCredentialsRefreshed: _saveCredentials,
        );
      }
    });
  }

  @override
  oauth2.Client? get client => _client;

  @override
  Future<bool> isAutheticated() async {
    if (_client == null) return false;
    try {
      final credentials = _client!.credentials;
      if (credentials.isExpired) {
        if (!credentials.canRefresh) return false;
        await _client!.refreshCredentials();
        return true;
      }

      var response = await http.post(
        introspectionEndpoint,
        headers: {
          'Authorization': 'Basic $introspectionAuthorization',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'token': credentials.accessToken,
        },
      );

      if (response.statusCode != 200) return false;
      return jsonDecode(response.body)['active'] == true;
    } on StateError {
      return false;
    }
  }

  @override
  Future<oauth2.Client> login(String username, String password) async {
    var newClient = await oauth2.resourceOwnerPasswordGrant(
      tokenEndpoint,
      username,
      password,
      identifier: identifier,
      secret: secret,
      scopes: ['profile', 'email', 'offline_access', 'openid'],
      onCredentialsRefreshed: _saveCredentials,
    );

    await _saveCredentials(newClient.credentials);
    return _client = newClient;
  }

  @override
  Future<void> logout() async {
    if (_client == null) return;
    try {
      await _client!.post(endSessionEndpoint);
    } catch (e) {
      // Ignorar errores
    } finally {
      _client = null;
      await storage.delete(key: credentialsKey);
      for (var listener in _logoutListeners) {
        listener();
      }
    }
  }

  @override
  Future<UserInfo> user() async {
    if (_client == null) {
      throw oauth2.AuthorizationException('unauthorized', 'User is not authenticated', userinfoEndpoint);
    }

    final response = await client!.get(userinfoEndpoint);
    if (response.statusCode == 200) {
      return UserInfo.fromJson(jsonDecode(response.body));
    }

    throw oauth2.AuthorizationException(response.status.message, response.body, userinfoEndpoint);
  }

  _saveCredentials(oauth2.Credentials credentials) async {
    await storage.write(key: credentialsKey, value: credentials.toJson());
  }

  @override
  void addLogoutListener(void Function() listenner) {
    _logoutListeners.add(listenner);
  }
}
