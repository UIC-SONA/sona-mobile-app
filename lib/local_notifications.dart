import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';

const androidNotificationDetails = AndroidNotificationDetails(
  'COMMON CHANNEL',
  'Canal para notificaciones comunes',
  importance: Importance.max,
  priority: Priority.high,
  ticker: 'ticker',
);
const NotificationDetails notificationDetails = NotificationDetails(
  android: androidNotificationDetails,
);

class LocalNotifications {
  //
  static final _pluging = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
    const initializationSettingsDarwin = DarwinInitializationSettings();
    const initializationSettingsLinux = LinuxInitializationSettings(defaultActionName: 'Open notification');
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );
    await _pluging.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    await _pluging.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  static void _onDidReceiveNotificationResponse(NotificationResponse response) {
    if (kDebugMode) {
      print("Response [$response]");
    }
  }

  static Future<void> show(
    int id, {
    required String title,
    required String body,
    required String payload,
  }) async {
    await _pluging.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static Future<void> periodicallyShow(
    int id, {
    required String title,
    required String body,
    required String payload,
    required RepeatInterval repeatInterval,
  }) async {
    await _pluging.periodicallyShow(
      id,
      title,
      body,
      repeatInterval,
      notificationDetails,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exact,
    );
  }

  static Future<void> zonedSchedule(
    int id, {
    required String title,
    required String body,
    required String payload,
    required TZDateTime scheduledDate,
  }) async {
    await _pluging.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancel(int id, {String? tag}) async {
    await _pluging.cancel(id, tag: tag);
  }

  static Future<void> cancelAll() async {
    await _pluging.cancelAll();
  }

  static Future<void> cancelMultiple(List<int> ids) async {
    for (var id in ids) {
      await _pluging.cancel(id);
    }
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _pluging.pendingNotificationRequests();
  }

  // Widget para mostrar las notificaciones programadas
  static Widget buildScheduledNotificationsList() {
    return FutureBuilder<List<PendingNotificationRequest>>(
      future: getPendingNotifications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final notifications = snapshot.data ?? [];

        if (notifications.isEmpty) {
          return const Center(
            child: Text('No hay notificaciones programadas'),
          );
        }

        return Expanded(
          child: ListView.builder(
            shrinkWrap: true, // Añade esto
            physics: NeverScrollableScrollPhysics(), // Añade esto si quieres deshabilitar el scroll
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                title: Text(notification.title ?? 'Sin título'),
                subtitle: Text(notification.body ?? 'Sin contenido'),
                trailing: Text('ID: ${notification.id}'),
              );
            },
          ),
        );
      },
    );
  }
}
