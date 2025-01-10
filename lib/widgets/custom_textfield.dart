import 'package:flutter/material.dart';

// Custom TextField Widget
class CustomTextField extends StatelessWidget {
  final String label;
  final bool isPassword;
  final TextEditingController controller;
  final Icon? prefixIcon;
  final TextInputType keyboardType;

  const CustomTextField({
    Key? key,
    required this.label,
    this.isPassword = false,
    required this.controller,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
