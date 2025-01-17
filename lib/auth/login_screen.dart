import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:medicare/auth/register_screen.dart';
import 'package:medicare/widgets/custom_button.dart';
import 'package:medicare/widgets/custom_textfield.dart';
import 'package:medicare/models/user_model.dart';
import 'package:medicare/screens/patients/patient_dashboard.dart';
import 'package:medicare/screens/doctors/doctor_dashboard.dart';
import 'package:medicare/screens/admins/admin_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare/services/notification_listener_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _verifyLogin(BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String role = await _getUserRole(userCredential.user!.uid);

      UserModel loggedInUser = UserModel(
        uid: userCredential.user!.uid,
        name: userCredential.user!.displayName ??
            emailController.text.split('@')[0],
        email: emailController.text.trim(),
        role: role,
      );

      Widget nextScreen;
      if (role == 'patient') {
        Future.delayed(Duration(milliseconds: 500), () {
          NotificationListenerService.initialize(loggedInUser.uid);
        });
        nextScreen = PatientDashboard(user: loggedInUser);
      } else if (role == 'doctor') {
        nextScreen = DoctorDashboard(user: loggedInUser);
      } else {
        nextScreen = AdminDashboard(user: loggedInUser);
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => nextScreen),
        (Route<dynamic> route) => false, // Hapus semua layar sebelumnya
      );
    } catch (e) {
      print('Login error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
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
        String role = userDoc['role'];

        if (role == 'admin' || role == 'doctor' || role == 'patient') {
          print('User $userId logged in as: $role');
          return role;
        } else {
          print('User $userId has an invalid role: $role');
          return 'patient';
        }
      } else {
        print('User $userId not found in Firestore.');
        return 'patient';
      }
    } catch (e) {
      print('Error fetching user role: $e');
      return 'patient';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color(0xFF00B4D8).withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(27),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: const Color.fromARGB(255, 11, 11, 11)),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(height: 20),
                Center(
                  child: Container(
                    child: Image.asset(
                      'images/Logo.png',
                      height: 200,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Selamat Datang",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0077B6),
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  "Silakan masuk ke akun Anda",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF0077B6),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CustomTextField(
                        label: "Email",
                        controller: emailController,
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      SizedBox(height: 20),
                      CustomTextField(
                        label: "Password",
                        isPassword: !_isPasswordVisible,
                        controller: passwordController,
                        prefixIcon: Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 15),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Tambahkan fungsi lupa password di sini
                          },
                          child: Text(
                            "Lupa Password?",
                            style: TextStyle(
                              color: Color(0xFF0077B6),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      CustomButton(
                        text: "Masuk",
                        onPressed: () => _verifyLogin(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0077B6),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: 13, horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: "Belum punya akun? ",
                        style: TextStyle(color: Colors.white70),
                        children: [
                          TextSpan(
                            text: "Daftar",
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
