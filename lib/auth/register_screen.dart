import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare/widgets/custom_button.dart';
import 'package:medicare/widgets/custom_textfield.dart';
import 'package:medicare/models/user_model.dart';

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
  final TextEditingController ageController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Tambahkan variabel untuk menyimpan pilihan jenis kelamin
  String? selectedGender;

  // Variabel untuk mengontrol visibilitas password
  bool showPassword = false;

  // Function to register user
  Future<void> registerUser() async {
    try {
      // Create user using Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Create UserModel instance
      UserModel newUser = UserModel(
        uid: userCredential.user!.uid, // UID from Firebase Auth
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        role: 'patient', // Default role set to 'patient'
        age: int.tryParse(ageController.text.trim()), // Parse age
        gender: selectedGender, // Use selected gender from dropdown
      );

      // Save additional user data (like name, email, and role) to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUser.toMap());

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
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      // Catch other errors
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('An error occurred')));
      }
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
              Color(0xFF08A8B1).withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tombol kembali
                IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: const Color.fromARGB(255, 8, 4, 1)),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(height: 2),
                Center(
                  child: Image.asset(
                    'images/Logo.png',
                    height: 100,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Daftar Akun",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF19E23),
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  "Silakan lengkapi data diri Anda",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFF19E23),
                  ),
                ),
                SizedBox(height: 15),
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
                        label: "Nama Lengkap",
                        controller: nameController,
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        label: "Email",
                        controller: emailController,
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        label: "Password",
                        isPassword: !showPassword,
                        controller: passwordController,
                        prefixIcon: Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        label: "Umur",
                        controller: ageController,
                        prefixIcon: Icon(Icons.cake_outlined),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedGender,
                        decoration: InputDecoration(
                          labelText: "Jenis Kelamin",
                          prefixIcon: Icon(Icons.wc_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: ['Laki-laki', 'Perempuan', 'Lainnya']
                            .map((gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value;
                          });
                        },
                      ),
                      SizedBox(height: 30),
                      CustomButton(
                        text: "Daftar",
                        onPressed: () => registerUser(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF19E23),
                          padding: EdgeInsets.symmetric(
                              vertical: 13, horizontal: 23),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        text: "Sudah punya akun? ",
                        style: TextStyle(color: Colors.white70),
                        children: [
                          TextSpan(
                            text: "Masuk",
                            style: TextStyle(
                              color: Color(0xFFF19E23),
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
