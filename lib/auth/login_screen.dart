import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:medicare/auth/register_screen.dart';
import 'package:medicare/widgets/custom_button.dart';
import 'package:medicare/widgets/custom_textfield.dart';
import 'package:medicare/models/user_model.dart';
import 'package:medicare/screens/patients/patient_dashboard.dart';
import 'package:medicare/screens/doctors/doctor_dashboard.dart';
import 'package:medicare/screens/admins/admin_dashboard.dart';

// login_screen.dart
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Firebase Authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to verify login with Firebase
  Future<void> _verifyLogin(BuildContext context) async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    try {
      // Attempt to sign in with Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user role from Firestore (or other data source)
      // For this example, assuming role is stored in Firestore
      String role = await _getUserRole(userCredential.user!.uid);

      // Create user model
      UserModel loggedInUser = UserModel(
        uid: userCredential.user!.uid,
        name: userCredential.user!.displayName ?? email.split('@')[0],
        email: email,
        role: role,
      );

      // Navigate to appropriate dashboard based on role
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          if (role == 'patient') {
            return PatientDashboard(user: loggedInUser);
          } else if (role == 'doctor') {
            return DoctorDashboard(user: loggedInUser);
          } else {
            return AdminDashboard(user: loggedInUser);
          }
        }),
      );
    } on FirebaseAuthException catch (e) {
      // Handle errors during login
      String message = 'Login Failed';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      // General error handling
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('An error occurred')));
    }
  }

  // Function to fetch user role from Firestore or another data source
  Future<String> _getUserRole(String userId) async {
    // For now, let's assume roles are stored in Firestore
    // You can replace this with your actual Firestore query or other logic
    // Example Firestore query (replace with actual Firestore implementation):
    // DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    // return userDoc['role'];

    // For demonstration, returning a role based on userId (you can replace with your logic)
    if (userId == 'doctorId') {
      return 'doctor';
    } else if (userId == 'adminId') {
      return 'admin';
    } else {
      return 'patient';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(label: "Email", controller: emailController),
            CustomTextField(
              label: "Password",
              isPassword: true,
              controller: passwordController,
            ),
            SizedBox(height: 20),
            CustomButton(
              text: "Login",
              onPressed: () => _verifyLogin(context),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegisterScreen(),
                ),
              ),
              child: Text("Don't have an account? Register"),
            ),
          ],
        ),
      ),
    );
  }
}
