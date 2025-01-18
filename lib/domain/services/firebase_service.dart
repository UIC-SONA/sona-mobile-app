
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/ui/pages/routing/router.dart';

final _log = Logger();

class FirebaseService {
  final _messaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _messaging.requestPermission();
    final token = await _messaging.getToken();
    _log.i("FCM Token $token");
  }

  void _handleMessage(RemoteMessage? message) {
    _log.i("Message received: $message");
    if (message == null) return;
    var appRouter = injector.get<AppRouter>();
    appRouter.push(ForumRoute());
  }

  Future<void> initPushNotifications() async {
    _messaging.getInitialMessage().then(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }
}
