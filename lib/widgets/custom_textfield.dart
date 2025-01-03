import 'package:flutter/material.dart';

// Custom TextField Widget
class CustomTextField extends StatelessWidget {
  final String label;
  final bool isPassword;
  final TextEditingController? controller; // Add controller parameter

  const CustomTextField({
    super.key,
    required this.label,
    this.isPassword = false,
    this.controller, // Make controller optional
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller, // Assign controller to TextField
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
