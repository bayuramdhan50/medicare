import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare/models/user_model.dart';

class UserStatisticsScreen extends StatelessWidget {
  final UserModel user;

  UserStatisticsScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text('User Statistics'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No data available for this user.'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String userName = userData['name'] ?? 'Unknown';
          String userGender = userData['gender'] ?? 'Unknown';
          int userAge = userData['age'] ?? 0;
          String userHealthStatus = userData['healthStatus'] ?? 'Unknown';

          // Placeholder for relevant statistics, you can adjust based on your data
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('User Information', style: TextStyle(fontSize: 18)),
                SizedBox(height: 20),
                DataTable(
                  columns: [
                    DataColumn(label: Text('Attribute')),
                    DataColumn(label: Text('Value')),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text('Name')),
                      DataCell(Text(userName)),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Age')),
                      DataCell(Text(userAge.toString())),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Gender')),
                      DataCell(Text(userGender)),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Health Status')),
                      DataCell(Text(userHealthStatus)),
                    ]),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
