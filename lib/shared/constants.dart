// Estas URL son puntos de acceso que son proporcionados por el servidor de
// autorización. Usualmente están incluidas en la documentación del servidor
// para su API OAuth2.
import 'package:flutter_dotenv/flutter_dotenv.dart';

final Uri authorizationEndpoint = Uri.parse(dotenv.env['AUTHORIZATION_ENDPOINT']!);
final Uri tokenEndpoint = Uri.parse(dotenv.env['TOKEN_ENDPOINT']!);
final Uri introspectionEndpoint = Uri.parse(dotenv.env['INTROSPECTION_ENDPOINT']!);
final Uri userinfoEndpoint = Uri.parse(dotenv.env['USERINFO_ENDPOINT']!);
final Uri endSessionEndpoint = Uri.parse(dotenv.env['END_SESSION_ENDPOINT']!);

// El servidor de autorización asignará a cada cliente un identificador y
// secreto distintos, lo que le permite al servidor saber qué cliente lo
// está accediendo. Algunos servidores también pueden tener un par
// identificador/secreto anónimo que cualquier cliente puede usar.
final String identifier = dotenv.env['CLIENT_ID']!;
final String secret = dotenv.env['CLIENT_SECRET']!;

// URL de la API
final Uri apiUri = Uri.parse(dotenv.env['API_URI']!);
