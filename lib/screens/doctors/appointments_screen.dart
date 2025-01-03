import 'package:flutter/material.dart';
import 'package:medicare/models/user_model.dart';

class AppointmentsScreen extends StatelessWidget {
  final UserModel user;

  AppointmentsScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Appointments')),
      body: Center(
        child: Text('List of Appointments for Dr. ${user.name}'),
      ),
    );
  }
}
