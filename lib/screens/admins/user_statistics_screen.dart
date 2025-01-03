import 'package:flutter/material.dart';
import 'package:medicare/models/user_model.dart';

class UserStatisticsScreen extends StatelessWidget {
  final UserModel user;

  UserStatisticsScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    // Placeholder for statistics data, can replace with actual data
    final Map<String, int> educationDistribution = {
      'Bachelor': 15,
      'Master': 10,
      'PhD': 5,
      'Unknown': 3,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('User Statistics'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Education Distribution', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            // You can use a chart library here for better visualization
            DataTable(
              columns: [
                DataColumn(label: Text('Education')),
                DataColumn(label: Text('Count')),
              ],
              rows: educationDistribution.entries
                  .map((entry) => DataRow(cells: [
                        DataCell(Text(entry.key)),
                        DataCell(Text(entry.value.toString())),
                      ]))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
