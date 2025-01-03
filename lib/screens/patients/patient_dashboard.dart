import 'package:flutter/material.dart';
import 'package:medicare/screens/patients/book_appointment_screen.dart';
import 'package:medicare/screens/patients/my_appointment_screen.dart';
import 'package:medicare/screens/patients/medical_records_screen.dart';
import 'package:medicare/screens/patients/prescription_screen.dart';
import 'package:medicare/screens/patients/lab_result_screen.dart';
import 'package:medicare/screens/patients/find_hospital_screen.dart';
import 'package:medicare/screens/patients/appointment_screen.dart'; // Import AppointmentScreen
import 'package:medicare/widgets/custom_button.dart';
import 'package:medicare/models/user_model.dart';

class PatientDashboard extends StatelessWidget {
  final UserModel user;

  PatientDashboard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Dashboard'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Welcome ${user.name}, this is your dashboard!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            CustomButton(
              text: 'Book Appointment',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BookAppointmentScreen(user: user)),
                );
              },
            ),
            CustomButton(
              text: 'My Appointment',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyAppointmentScreen(user: user)),
                );
              },
            ),
            CustomButton(
              text: 'Medical Records',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MedicalRecordsScreen(user: user)),
                );
              },
            ),
            CustomButton(
              text: 'Prescription',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PrescriptionScreen(user: user)),
                );
              },
            ),
            CustomButton(
              text: 'Lab Results',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LabResultScreen(user: user)),
                );
              },
            ),
            CustomButton(
              text: 'Find Hospital',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FindHospitalScreen(user: user)),
                );
              },
            ),
            CustomButton(
              text: 'Appointments', // Button to navigate to AppointmentScreen
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AppointmentScreen(user: user)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
