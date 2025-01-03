import 'package:flutter/material.dart';
import 'package:medicare/models/user_model.dart';
import 'package:medicare/widgets/custom_button.dart';

class MyAppointmentScreen extends StatelessWidget {
  final UserModel user;

  MyAppointmentScreen({required this.user});

  // Sample appointment data
  final List<Map<String, String>> appointments = [
    {
      'date': '2024-12-01',
      'time': '10:00 AM',
      'doctor': 'Dr. John Doe',
      'status': 'Confirmed',
    },
    {
      'date': '2024-12-05',
      'time': '02:00 PM',
      'doctor': 'Dr. Jane Smith',
      'status': 'Pending',
    },
    {
      'date': '2024-12-10',
      'time': '09:00 AM',
      'doctor': 'Dr. Emily Clark',
      'status': 'Cancelled',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Appointments'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Appointments for ${user.name}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            // List of appointments
            Expanded(
              child: ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Date: ${appointments[index]['date']}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Time: ${appointments[index]['time']}',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Doctor: ${appointments[index]['doctor']}',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Status: ${appointments[index]['status']}',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 16),
                          CustomButton(
                            text: 'View Appointment Details',
                            onPressed: () {
                              // Add functionality to view appointment details
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
