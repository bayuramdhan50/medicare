import 'package:flutter/material.dart';
import 'package:medicare/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // Memastikan binding diinisialisasi sebelum Firebase diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp();

  // Jalankan aplikasi setelah Firebase diinisialisasi
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
