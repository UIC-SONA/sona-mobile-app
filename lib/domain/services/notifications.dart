import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import 'package:sona/domain/providers/auth.dart';
import 'package:sona/domain/providers/locale.dart';
import 'package:sona/shared/constants.dart';
import 'package:sona/shared/http/http.dart';
import 'package:http/http.dart' as http;

final _log = Logger();

abstract class NotificationService {
  Future<void> suscribe();

  Future<void> unsuscribe();

  void listen(Function(RemoteMessage?) listenner);
}

class ApiNotificationService extends NotificationService implements WebResource {
  //
  final AuthProvider authProvider;
  final LocaleProvider localeProvider;

  ApiNotificationService({
    required this.authProvider,
    required this.localeProvider,
  });

  @override
  http.Client? get client => authProvider.client;

  @override
  String get path => '/notification';

  @override
  Uri get uri => apiUri;

  @override
  Map<String, String> get commonHeaders => {'Accept-Language': localeProvider.languageCode};

  final messaging = FirebaseMessaging.instance;

  @override
  Future<void> suscribe() async {
    await messaging.requestPermission();
    String? token;
    try {
      token = await messaging.getToken();
      if (token == null) return;
    } catch (e) {
      _log.w("Error getting FCM token, try with APNS token", error: e, stackTrace: StackTrace.current);
      try {
        token = await messaging.getAPNSToken();
        if (token == null) return;
      } catch (e) {
        _log.e("Error getting APNS token", error: e, stackTrace: StackTrace.current);
        return;
      }
    }

    await request(
      uri.replace(path: '$path/suscribe'),
      client: client,
      method: HttpMethod.post,
      headers: {
        ...commonHeaders,
      },
      body: {"token": token},
    );

    _log.i("Suscribe FCM Token $token");
  }

  @override
  Future<void> unsuscribe() async {
    final token = await messaging.getToken();
    if (token == null) return;
    await request(
      uri.replace(path: '$path/unsuscribe'),
      client: client,
      method: HttpMethod.post,
      headers: {
        ...commonHeaders,
      },
      body: {"token": token},
    );
    await messaging.deleteToken();
    _log.i("Unsuscribe FCM Token $token");
  }

  @override
  void listen(Function(RemoteMessage?) listenner) {
    messaging.getInitialMessage().then(listenner);
    FirebaseMessaging.onMessageOpenedApp.listen(listenner);
    FirebaseMessaging.onMessage.listen(listenner);
  }
}
