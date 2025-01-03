import 'package:flutter/material.dart';
import 'package:medicare/models/user_model.dart';
import 'package:medicare/widgets/custom_button.dart';

class PrescriptionScreen extends StatelessWidget {
  final UserModel user;

  PrescriptionScreen({required this.user});

  // Sample prescription data
  final List<Map<String, String>> prescriptions = [
    {
      'medicine': 'Paracetamol',
      'dose': '500mg',
      'instructions': 'Take one tablet every 6 hours.',
      'date': '2024-12-01',
    },
    {
      'medicine': 'Amoxicillin',
      'dose': '250mg',
      'instructions': 'Take one tablet twice a day for 7 days.',
      'date': '2024-12-05',
    },
    {
      'medicine': 'Ibuprofen',
      'dose': '200mg',
      'instructions': 'Take one tablet every 8 hours as needed.',
      'date': '2024-12-10',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prescriptions'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Prescriptions for ${user.name}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            // List of prescriptions
            Expanded(
              child: ListView.builder(
                itemCount: prescriptions.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Medicine: ${prescriptions[index]['medicine']}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Dose: ${prescriptions[index]['dose']}',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Instructions: ${prescriptions[index]['instructions']}',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Date: ${prescriptions[index]['date']}',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 16),
                          CustomButton(
                            text: 'View Prescription Details',
                            onPressed: () {
                              // Add functionality to view prescription details
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
