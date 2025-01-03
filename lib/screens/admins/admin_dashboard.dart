import 'package:flutter/material.dart';
import 'add_doctor_screen.dart';
import 'user_statistics_screen.dart';
import 'manage_users_screen.dart';
import 'package:medicare/models/user_model.dart';

class AdminDashboard extends StatelessWidget {
  final UserModel user;

  AdminDashboard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text('Add Doctor'),
              leading: Icon(Icons.medical_services),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddDoctorScreen(user: user),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('User Statistics'),
              leading: Icon(Icons.pie_chart),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserStatisticsScreen(user: user),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Manage Users'),
              leading: Icon(Icons.manage_accounts),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageUsersScreen(user: user),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
