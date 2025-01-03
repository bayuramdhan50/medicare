import 'package:flutter/material.dart';
import 'package:medicare/models/user_model.dart';

class MedicalRecordsScreen extends StatelessWidget {
  final UserModel user;

  MedicalRecordsScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Medical Records')),
      body: Center(
        child: Text('Medical records for Dr. ${user.name}'),
      ),
    );
  }
}
