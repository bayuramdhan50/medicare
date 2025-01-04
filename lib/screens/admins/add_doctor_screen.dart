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
        title: Text('Add Doctor'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Doctor Name'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Doctor Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: ageController,
              decoration: InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            // Dropdown for gender selection
            DropdownButtonFormField<String>(
              value: selectedGender,
              decoration: InputDecoration(labelText: 'Gender'),
              onChanged: (String? newValue) {
                setState(() {
                  selectedGender = newValue!;
                });
              },
              items: genderOptions
                  .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                  .toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                addDoctor();
              },
              child: Text('Add Doctor'),
            ),
          ],
        ),
      ),
    );
  }
}
