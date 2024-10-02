import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static onTap(NotificationResponse notificationResponse) {}
  static Future init() async {
    InitializationSettings settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings());
    flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveBackgroundNotificationResponse: onTap,
      onDidReceiveNotificationResponse: onTap,
    );
  }

  //basic notification
  static void showBasicNotification(String message) async {
    const AndroidNotificationDetails android = AndroidNotificationDetails(
     'limit_reached_channel',
       'Limit Reached Notification',
        importance: Importance.max,
    priority: Priority.high,
    );
    NotificationDetails details = const NotificationDetails(android: android);
    await flutterLocalNotificationsPlugin.show(
        0,  'Spending Limit Alert',
      message,
       details,
        payload: 'Payload Data');
  }
}
