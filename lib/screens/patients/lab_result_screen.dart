import 'package:flutter/material.dart';
import 'package:medicare/models/user_model.dart';
import 'package:medicare/widgets/custom_button.dart';

class LabResultScreen extends StatelessWidget {
  final UserModel user;

  LabResultScreen({required this.user});

  // Sample lab results data
  final List<Map<String, String>> labResults = [
    {
      'test': 'Blood Test',
      'date': '2024-12-01',
      'result': 'Normal',
    },
    {
      'test': 'X-Ray',
      'date': '2024-12-05',
      'result': 'No abnormalities detected',
    },
    {
      'test': 'MRI Scan',
      'date': '2024-12-07',
      'result': 'Minor inflammation detected',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lab Results'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Lab Results for ${user.name}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            // List of lab results
            Expanded(
              child: ListView.builder(
                itemCount: labResults.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            labResults[index]['test'] ?? '',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Date: ${labResults[index]['date']}',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Result: ${labResults[index]['result']}',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 16),
                          CustomButton(
                            text: 'View Details',
                            onPressed: () {
                              // You can add logic to view detailed results or open a PDF here
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
