import 'package:flutter/material.dart';
import 'package:medicare/models/user_model.dart';

class AddDoctorScreen extends StatelessWidget {
  final UserModel user;

  AddDoctorScreen({required this.user});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

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
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add the doctor to the Firestore database (replace this with your Firestore logic)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Doctor added successfully!')),
                );
              },
              child: Text('Add Doctor'),
            ),
          ],
        ),
      ),
    );
  }
}
