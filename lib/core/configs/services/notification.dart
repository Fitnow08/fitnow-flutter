import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidPushSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosPushSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidPushSettings,
      iOS: iosPushSettings,
    );

    await _notificationPlugin.initialize(settings: settings);

    await _notificationPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidNotificationDetails = AndroidNotificationDetails(
      "default_channel",
      "default_channel",
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      channelDescription: "This is a the device notification channel",
    );
    const iosNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );
    await _notificationPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: "payload test",
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationPlugin.cancel(id: id);
  }
}
