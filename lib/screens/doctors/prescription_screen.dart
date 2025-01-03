import 'package:flutter/material.dart';
import 'package:medicare/models/user_model.dart';

class PrescriptionScreen extends StatelessWidget {
  final UserModel user;

  PrescriptionScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Prescription')),
      body: Center(
        child: Text('Prescription form for Dr. ${user.name}'),
      ),
    );
  }
}
