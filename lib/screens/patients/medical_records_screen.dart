import 'package:flutter/material.dart';
import 'package:medicare/models/user_model.dart';
import 'package:medicare/widgets/custom_button.dart';

class MedicalRecordsScreen extends StatelessWidget {
  final UserModel user;

  MedicalRecordsScreen({required this.user});

  // Sample medical records data
  final List<Map<String, String>> medicalRecords = [
    {
      'disease': 'Hypertension',
      'date': '2024-11-15',
      'status': 'Under treatment',
    },
    {
      'disease': 'Diabetes',
      'date': '2024-10-25',
      'status': 'Stable, taking medication',
    },
    {
      'disease': 'Asthma',
      'date': '2024-09-10',
      'status': 'Controlled with inhaler',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Records'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Medical Records for ${user.name}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            // List of medical records
            Expanded(
              child: ListView.builder(
                itemCount: medicalRecords.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Disease: ${medicalRecords[index]['disease']}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Date of Diagnosis: ${medicalRecords[index]['date']}',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Status: ${medicalRecords[index]['status']}',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 16),
                          CustomButton(
                            text: 'View Details',
                            onPressed: () {
                              // You can add logic to view detailed medical records here
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
