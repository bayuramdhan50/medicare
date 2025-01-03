import 'package:flutter/material.dart';
import 'package:medicare/models/user_model.dart';

class BookAppointmentScreen extends StatelessWidget {
  final UserModel user;

  BookAppointmentScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Appointment'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text('This is the Book Appointment screen for ${user.name}.'),
      ),
    );
  }
}
