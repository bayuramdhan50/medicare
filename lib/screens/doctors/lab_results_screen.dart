import 'package:flutter/material.dart';
import 'package:medicare/models/user_model.dart';

class LabResultsScreen extends StatelessWidget {
  final UserModel user;

  LabResultsScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lab Results')),
      body: Center(
        child: Text('Lab results for Dr. ${user.name}'),
      ),
    );
  }
}
