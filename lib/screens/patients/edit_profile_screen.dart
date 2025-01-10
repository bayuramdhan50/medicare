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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    ageController = TextEditingController(text: widget.user.age?.toString());
    selectedGender = widget.user.gender;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    ageController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final updatedUser = UserModel(
      uid: widget.user.uid,
      name: nameController.text,
      email: emailController.text,
      role: widget.user.role,
      age: int.tryParse(ageController.text),
      gender: selectedGender,
    );

    try {
      await _firestore.collection('users').doc(widget.user.uid).update({
        'name': updatedUser.name,
        'email': updatedUser.email,
        'age': updatedUser.age,
        'gender': updatedUser.gender,
      });

      widget.onSave(updatedUser);
      Navigator.pop(context);
    } catch (e) {
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
