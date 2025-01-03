import 'package:flutter/material.dart';
import 'package:medicare/models/user_model.dart';
import 'package:medicare/widgets/custom_button.dart';
import 'package:medicare/screens/patients/book_appointment_screen.dart';

class AppointmentScreen extends StatelessWidget {
  final UserModel user;

  AppointmentScreen({required this.user});

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
              'Upcoming Appointments',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            // Placeholder for the list of appointments
            Expanded(
              child: ListView.builder(
                itemCount:
                    5, // Replace with dynamic count based on user's appointments
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('Doctor ${index + 1}'),
                      subtitle: Text('Appointment Date: 2025-01-10'),
                      trailing: Icon(Icons.access_time),
                      onTap: () {
                        // Navigate to details of the appointment (optional)
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            CustomButton(
              text: 'Book New Appointment',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BookAppointmentScreen(user: user)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
