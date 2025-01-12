import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare/models/user_model.dart';

class AddDoctorScreen extends StatefulWidget {
  const AddDoctorScreen({super.key});

  @override
  _AddDoctorScreenState createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController healthStatusController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String selectedGender = 'Male'; // Default gender value

  // List of gender options
  List<String> genderOptions = ['Male', 'Female', 'Other'];

  final Color primaryColor = Color(0xFF08A8B1); // Tosca
  final Color secondaryColor = Color(0xFFF19E23); // Orange

  Future<void> addDoctor() async {
    try {
      // Buat akun dokter di Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Buat objek dokter dengan role 'doctor' dan atribut tambahan
      UserModel newDoctor = UserModel(
        uid: userCredential.user!.uid,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        role: 'doctor', // Role dokter
        age: int.parse(ageController.text.trim()), // Mengambil usia dari input
        gender: selectedGender, // Mengambil gender dari dropdown
        healthStatus: healthStatusController.text
            .trim(), // Mengambil status kesehatan dari input
      );

      // Simpan informasi dokter ke Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newDoctor.toMap());

      // Tampilkan notifikasi sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Doctor added successfully!')),
      );

      // Kosongkan input setelah sukses
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      ageController.clear();
      healthStatusController.clear();
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to add doctor';
      if (e.code == 'weak-password') {
        errorMessage = 'The password is too weak';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The email is already in use';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('An error occurred')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Doctor',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildInputField(
                controller: nameController,
                label: 'Doctor Name',
                icon: Icons.person,
                keyboardType: TextInputType.name,
              ),
              SizedBox(height: 16),
              _buildInputField(
                controller: emailController,
                label: 'Doctor Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              _buildInputField(
                controller: passwordController,
                label: 'Password',
                icon: Icons.lock,
                isPassword: true,
              ),
              SizedBox(height: 16),
              _buildInputField(
                controller: ageController,
                label: 'Age',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withOpacity(0.5)),
                  color: Colors.white,
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    labelStyle: TextStyle(color: primaryColor),
                    border: InputBorder.none,
                    icon: Icon(Icons.people, color: primaryColor),
                  ),
                  items: genderOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedGender = newValue!;
                    });
                  },
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                onPressed: addDoctor,
                child: Text(
                  'Add Doctor',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.5)),
        color: Colors.white,
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: primaryColor),
          prefixIcon: Icon(icon, color: primaryColor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
