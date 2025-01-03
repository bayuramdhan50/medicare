import 'package:flutter/material.dart';
import 'package:medicare/models/user_model.dart';

class ManageUsersScreen extends StatelessWidget {
  final UserModel user;

  ManageUsersScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    // Placeholder for user data (replace with your Firestore logic)
    final List<Map<String, String>> users = [
      {'name': 'John Doe', 'email': 'john@example.com'},
      {'name': 'Jane Smith', 'email': 'jane@example.com'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Users'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              title: Text(user['name']!),
              subtitle: Text(user['email']!),
              trailing: Icon(Icons.delete),
              onTap: () {
                // Add logic to delete user from Firestore
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User deleted successfully')),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
