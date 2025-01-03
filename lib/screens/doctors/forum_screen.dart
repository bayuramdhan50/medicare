import 'package:flutter/material.dart';
import 'package:medicare/models/user_model.dart';

class ForumScreen extends StatelessWidget {
  final UserModel user;

  ForumScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Forum')),
      body: Center(
        child: Text('Forum for Dr. ${user.name}'),
      ),
    );
  }
}
