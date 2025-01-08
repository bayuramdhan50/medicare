import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare/models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  final Function(UserModel) onSave;

  EditProfileScreen({required this.user, required this.onSave});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController ageController;
  late TextEditingController genderController;
  late TextEditingController healthStatusController;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the current user data
    nameController = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    ageController = TextEditingController(text: widget.user.age?.toString());
    genderController = TextEditingController(text: widget.user.gender);
    healthStatusController =
        TextEditingController(text: widget.user.healthStatus);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    ageController.dispose();
    genderController.dispose();
    healthStatusController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final updatedUser = UserModel(
      uid: widget.user.uid,
      name: nameController.text,
      email: emailController.text,
      role: widget.user.role, // Role does not change in this case
      age: int.tryParse(ageController.text), // Convert age to integer
      gender: genderController.text,
      healthStatus: healthStatusController.text,
    );

    try {
      // Update Firestore user document
      await _firestore.collection('users').doc(widget.user.uid).update({
        'name': updatedUser.name,
        'email': updatedUser.email,
        'age': updatedUser.age,
        'gender': updatedUser.gender,
        'healthStatus': updatedUser.healthStatus,
      });

      widget.onSave(
          updatedUser); // Call the onSave function passed from ProfileScreen
      Navigator.pop(context); // Go back to ProfileScreen after saving
    } catch (e) {
      // Handle errors if any
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(
                controller: nameController,
                label: 'Name',
                icon: Icons.person,
              ),
              _buildTextField(
                controller: emailController,
                label: 'Email',
                icon: Icons.email,
              ),
              _buildTextField(
                controller: ageController,
                label: 'Age',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: genderController,
                label: 'Gender',
                icon: Icons.accessibility,
              ),
              _buildTextField(
                controller: healthStatusController,
                label: 'Health Status',
                icon: Icons.healing,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Save Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
