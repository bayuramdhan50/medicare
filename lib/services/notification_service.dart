import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Request Permission for Notifications
  Future<void> requestNotificationPermission() async {
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Notification permission granted');
    } else {
      print('Notification permission denied');
    }
  }

  // Get FCM Token
  Future<String?> getFcmToken() async {
    String? token = await _firebaseMessaging.getToken();
    return token;
  }

  // Handle Notification
  Future<void> handleNotification(RemoteMessage message) async {
    // Show local notification
    await _showLocalNotification(message);
  }

  // Show Local Notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    var androidDetails = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
    );
    var platformDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformDetails,
      payload: 'Custom data',
    );
  }

  // Initialize Firebase Messaging
  Future<void> initializeFirebaseMessaging() async {
    FirebaseMessaging.onMessage.listen(handleNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(handleNotification);
  }
}
