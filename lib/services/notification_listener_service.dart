import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare/services/notification_service.dart';

class NotificationListenerService {
  static Set<String> _processedNotifications = {};
  static DateTime _lastCheckTime = DateTime.now();
  static Stream<QuerySnapshot>? _notificationStream;

  static void initialize(String userId) {
    NotificationService.initialize();

    // Set up notification stream
    _notificationStream = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();

    // Listen to notifications
    _notificationStream?.listen((snapshot) {
      for (var doc in snapshot.docs) {
        _checkAndShowNotification(doc);
      }
    });

    print('NotificationListenerService initialized for user: $userId');
  }

  static void _checkAndShowNotification(QueryDocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    Timestamp timestamp = data['timestamp'] as Timestamp;
    DateTime notificationTime = timestamp.toDate();

    // Pastikan hanya notifikasi yang belum dibaca yang diproses
    if (!_processedNotifications.contains(doc.id) &&
        notificationTime.isAfter(_lastCheckTime) &&
        !(data['isRead'] ?? false)) {
      _processedNotifications.add(doc.id); // Tandai notifikasi sudah diproses

      // Tampilkan notifikasi
      NotificationService.showNotification(
        title: data['title'] ?? 'New Notification',
        body: data['body'] ?? 'You have a new message.',
      );
      print('New notification shown: ${data['title']}');

      // Tandai notifikasi sebagai sudah dibaca setelah ditampilkan
      FirebaseFirestore.instance
          .collection('notifications')
          .doc(doc.id)
          .update({'isRead': true}).then((_) {
        print('Notification marked as read: ${data['title']}');
      }).catchError((error) {
        print('Error updating notification: $error');
      });
    }
  }

  static void dispose() {
    _processedNotifications.clear();
    _lastCheckTime = DateTime.now();
  }
}
