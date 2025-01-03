import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare/widgets/custom_button.dart';
import 'package:medicare/widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers for input fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to register user
  Future<void> registerUser() async {
    try {
      // Create user using Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // You can also store additional user data (like name) in Firestore here
      // Example: FirebaseFirestore.instance.collection('users').add({...})

      // Show success and navigate to the next screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration Successful!")),
      );

      // Optionally, navigate to the login screen or home screen
      // Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      // Handle registration errors
      String message = 'Registration Failed';
      if (e.code == 'weak-password') {
        message = 'The password is too weak';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      // Catch other errors
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('An error occurred')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
              label: "Name",
              controller: nameController,
            ),
            CustomTextField(
              label: "Email",
              controller: emailController,
            ),
            CustomTextField(
              label: "Password",
              isPassword: true,
              controller: passwordController,
            ),
            SizedBox(height: 20),
            CustomButton(
              text: "Register",
              onPressed: () {
                registerUser();
              },
            ),
          ],
        ),
      ),
    );
  }
}
