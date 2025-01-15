import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare/screens/getting_started_screen.dart';
import 'package:medicare/screens/patients/patient_dashboard.dart';
import 'package:medicare/screens/doctors/doctor_dashboard.dart';
import 'package:medicare/screens/admins/admin_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare/models/user_model.dart';
import 'package:medicare/services/notification_service.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<UserModel?> _getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        return UserModel(
          uid: data['uid'] ?? '',
          name: data['name'] ?? 'Unknown',
          email: data['email'] ?? 'No Email',
          role: data['role'] ?? 'patient',
          age: data['age'],
          gender: data['gender'],
          healthStatus: data['healthStatus'],
          fcmToken: data['fcmToken'],
        );
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
    return null;
  }

  void _fetchUserNotifications(String userId) async {
    FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        // .where('isRead', isEqualTo: false) // Tetap filter berdasarkan unread
        .snapshots() // Menggunakan snapshots untuk mendengarkan perubahan real-time
        .listen((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        // Filter notifikasi yang belum dibaca secara manual
        var unreadNotifications =
            querySnapshot.docs.where((doc) => doc['isRead'] == false).toList();

        if (unreadNotifications.isNotEmpty) {
          var notificationData = unreadNotifications.first.data();

          // Menampilkan notifikasi jika ada yang belum dibaca
          NotificationService.showNotification(
            title: notificationData['title'] ?? 'New Notification',
            body: notificationData['body'] ?? 'You have a new message.',
          );

          // Tandai notifikasi sebagai sudah dibaca
          FirebaseFirestore.instance
              .collection('notifications')
              .doc(unreadNotifications.first.id)
              .update({'isRead': true});
        }
      }
    }).onError((error) {
      print("Error listening to notifications: $error");
    });
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(Duration(seconds: 3));

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      UserModel? userModel = await _getUserData(user.uid);

      if (userModel != null) {
        // Inisialisasi layanan notifikasi
        NotificationService.initialize();

        // Ambil notifikasi terbaru dari Firestore
        _fetchUserNotifications(userModel.uid);

        Widget homeScreen;
        if (userModel.role == 'patient') {
          homeScreen = PatientDashboard(user: userModel);
        } else if (userModel.role == 'doctor') {
          homeScreen = DoctorDashboard(user: userModel);
        } else {
          homeScreen = AdminDashboard(user: userModel);
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => homeScreen),
        );
      } else {
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GettingStartedScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GettingStartedScreen()),
      );
    }
  }

  Future<String> _getUserRole(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc['role'] ?? 'patient'; // Default role jika tidak ada data
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
    return 'patient';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'images/Logo.png',
          width: 270,
          height: 270,
        ),
      ),
    );
  }
}
