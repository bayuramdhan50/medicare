import 'package:flutter/material.dart';
import 'package:medicare/models/user_model.dart';

class MyPatientsScreen extends StatelessWidget {
  final UserModel user;

  MyPatientsScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Patients')),
      body: Center(
        child: Text('List of Patients for Dr. ${user.name}'),
      ),
    );
  }
}
