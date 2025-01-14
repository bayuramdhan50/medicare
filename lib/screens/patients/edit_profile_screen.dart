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

  final Color primaryColor = Color(0xFF2196F3); // Tosca
  final Color secondaryColor = Color(0xFF0D47A1); // Orange

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
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primaryColor.withOpacity(0.1),
                  Colors.white,
                ],
              ),
            ),
          ),

          // Header dengan wave clipper
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () {
                          print('Back button pressed');
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                      Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Form Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: 100),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTextField(
                      controller: nameController,
                      label: 'Name',
                      icon: Icons.person,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: emailController,
                      label: 'Email',
                      icon: Icons.email,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: ageController,
                      label: 'Age',
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: primaryColor.withOpacity(0.3)),
                        color: Colors.white,
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectedGender,
                        decoration: InputDecoration(
                          labelText: "Jenis Kelamin",
                          labelStyle: TextStyle(color: primaryColor),
                          prefixIcon:
                              Icon(Icons.wc_outlined, color: primaryColor),
                          border: InputBorder.none,
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
                    ),
                    SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Save Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
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

// Wave Clipper class jika belum ada
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
        Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
