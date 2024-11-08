import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:sona/application/common/security/storage.dart';

// Estas URL son puntos de acceso que son proporcionados por el servidor de
// autorización. Usualmente están incluidas en la documentación del servidor
// para su API OAuth2.
final authorizationEndpoint = Uri.parse(dotenv.env['AUTHORIZATION_ENDPOINT']!);
final tokenEndpoint = Uri.parse(dotenv.env['TOKEN_ENDPOINT']!);
final introspectionEndpoint = Uri.parse(dotenv.env['INTROSPECTION_ENDPOINT']!);
final userinfoEndpoint = Uri.parse(dotenv.env['USERINFO_ENDPOINT']!);
final endSessionEndpoint = Uri.parse(dotenv.env['END_SESSION_ENDPOINT']!);

// El servidor de autorización asignará a cada cliente un identificador y
// secreto distintos, lo que le permite al servidor saber qué cliente lo
// está accediendo. Algunos servidores también pueden tener un par
// identificador/secreto anónimo que cualquier cliente puede usar.
final identifier = dotenv.env['CLIENT_ID']!;
final secret = dotenv.env['CLIENT_SECRET']!;

// Para utilizar el endpoint de introspección, necesitamos enviar un encabezado
// de autorización HTTP, para el servidor de autorización de keycloak, este
// encabezado debe ser codificado en base64 y tener la forma `Basic <credenciales>`.
final introspectionAuthorization = base64Encode(utf8.encode('$identifier:$secret'));

/// Clave donde se almacenan las credenciales del usuario de forma
/// persistente y segura utilizando el paquete `flutter_secure_storage`.
const credentialsKey = "credentials";

/// Carga un cliente OAuth2 a partir de credenciales guardadas o autentica
/// uno nuevo.

Client? _instance;

Future<oauth2.Client> getInstance() async {
  if (_instance != null) return _instance as oauth2.Client;

  var credentialsStored = await storage.read(key: credentialsKey);
  if (credentialsStored != null) {
    var credentials = oauth2.Credentials.fromJson(credentialsStored);
    return _instance = oauth2.Client(credentials, identifier: identifier, secret: secret);
  }
  throw Exception('No se pudo obtener el cliente OAuth2');
}

Future<oauth2.Client> authenticate(String username, String password) async {
  var client = await oauth2.resourceOwnerPasswordGrant(
    tokenEndpoint,
    username,
    password,
    identifier: identifier,
    secret: secret,
    scopes: ['profile', 'email', 'offline_access', 'openid'],
    onCredentialsRefreshed: _saveCredentials,
  );

  await _saveCredentials(client.credentials);
  return _instance = client;
}

Future<void> logout() async {
  var client = await getInstance();
  await client.post(endSessionEndpoint);
  await storage.delete(key: credentialsKey);
}

Future<UserInfo> user() async {
  var client = await getInstance();
  final response = await client.get(userinfoEndpoint);
  if (response.statusCode == 200) {
    return UserInfo.fromJson(jsonDecode(response.body));
  }
  throw Exception('Failed to get user info');
}

class UserInfo {
  final String sub;
  final String name;
  final String preferredUsername;
  final String givenName;
  final String familyName;
  final String email;

  UserInfo({
    required this.sub,
    required this.name,
    required this.preferredUsername,
    required this.givenName,
    required this.familyName,
    required this.email,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      sub: json['sub'],
      name: json['name'],
      preferredUsername: json['preferred_username'],
      givenName: json['given_name'],
      familyName: json['family_name'],
      email: json['email'],
    );
  }
}

_saveCredentials(oauth2.Credentials credentials) async {
  await storage.write(key: credentialsKey, value: credentials.toJson());
}
