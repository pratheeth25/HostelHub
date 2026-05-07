import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);

    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
    });
  }

  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'campus_sphere_channel',
      'CampusSphere',
      channelDescription: 'CampusSphere event notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _localNotifications.show(
      0,
      message.notification?.title ?? 'CampusSphere',
      message.notification?.body ?? '',
      details,
    );
  }
}
