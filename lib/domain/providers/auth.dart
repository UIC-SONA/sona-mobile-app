import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:sona/domain/models/user.dart';
import 'package:sona/shared/constants.dart';
import 'package:sona/shared/http/http.dart';

abstract class AuthProvider<T extends http.Client> {
  //
  T? get client;

  Future<void> useCredentials(oauth2.Credentials credentials);

  Future<bool> isAuthenticated();

  bool isAuthenticatedSync();

  Future<void> logout();

  Future<T> login(String username, String password);

  Future<UserInfo> user();

  void addLogoutListener(void Function() listenner);

  void addLoginListener(void Function() listenner);
}

class KeycloakAuthProvider extends AuthProvider<oauth2.Client> {
  final Future<void> Function(oauth2.Credentials) saveCredentials;
  final Future<void> Function() deleteCredentials;

  final List<void Function()> _logoutListeners = [];
  final List<void Function()> _loginListeners = [];

  oauth2.Client? _client;

  // Para utilizar el endpoint de introspección, necesitamos enviar un encabezado
  // de autorización HTTP, para el servidor de autorización de keycloak, este
  // encabezado debe ser codificado en base64 y tener la forma `Basic <credenciales>`.
  final introspectionAuthorization = base64Encode(utf8.encode('$identifier:$secret'));

  KeycloakAuthProvider({required this.saveCredentials, required this.deleteCredentials});

  @override
  Future<void> useCredentials(oauth2.Credentials credentials) async {
    _client = oauth2.Client(credentials, identifier: identifier, secret: secret, onCredentialsRefreshed: saveCredentials);
  }

  @override
  oauth2.Client? get client => _client;

  @override
  Future<bool> isAuthenticated() async {
    if (_client == null) return false;
    try {
      final credentials = _client!.credentials;
      if (credentials.isExpired) {
        if (!credentials.canRefresh) return false;
        try {
          await _client!.refreshCredentials();
          return true;
        } catch (e) {
          return false;
        }
      }

      var response = await http.post(introspectionEndpoint, headers: {'Authorization': 'Basic $introspectionAuthorization', 'Content-Type': 'application/x-www-form-urlencoded'}, body: {'token': credentials.accessToken});

      if (response.statusCode != 200) return false;
      return jsonDecode(response.body)['active'] == true;
    } on StateError {
      return false;
    }
  }

  @override
  bool isAuthenticatedSync() {
    if (_client == null) return false;
    final credentials = _client!.credentials;
    if (credentials.isExpired) {
      return false;
    }
    return true;
  }

  @override
  Future<oauth2.Client> login(String username, String password) async {
    var newClient = await oauth2.resourceOwnerPasswordGrant(tokenEndpoint, username, password, identifier: identifier, secret: secret, scopes: ['profile', 'email', 'offline_access', 'openid'], onCredentialsRefreshed: saveCredentials);

    await saveCredentials(newClient.credentials);
    _client = newClient;
    for (var listener in _loginListeners) {
      listener();
    }
    return _client!;
  }

  @override
  Future<void> logout() async {
    if (_client == null) return;
    try {
      for (var listener in _logoutListeners) {
        listener();
      }
      await _client!.post(endSessionEndpoint);
    } catch (e) {
      // Ignorar errores
    } finally {
      await deleteCredentials();
      _client = null;
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

  @override
  void addLogoutListener(void Function() listenner) {
    _logoutListeners.add(listenner);
  }

  @override
  void addLoginListener(void Function() listenner) {
    _loginListeners.add(listenner);
  }
}
