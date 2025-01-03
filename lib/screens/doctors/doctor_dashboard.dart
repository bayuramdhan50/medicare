import 'package:flutter/material.dart';
import 'package:medicare/screens/doctors/my_patients_screen.dart';
import 'package:medicare/screens/doctors/appointments_screen.dart';
import 'package:medicare/screens/doctors/prescription_screen.dart';
import 'package:medicare/screens/doctors/medical_records_screen.dart';
import 'package:medicare/screens/doctors/lab_results_screen.dart';
import 'package:medicare/screens/doctors/forum_screen.dart';
import 'package:medicare/widgets/custom_button.dart';
import 'package:medicare/models/user_model.dart';

class DoctorDashboard extends StatelessWidget {
  final UserModel user;

  DoctorDashboard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Dashboard'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Welcome Dr. ${user.name}, this is your dashboard!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CustomButton(
              text: 'My Patients',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyPatientsScreen(user: user)),
                );
              },
            ),
            CustomButton(
              text: 'Appointments',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AppointmentsScreen(user: user)),
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
              text: 'Lab Results',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LabResultsScreen(user: user)),
                );
              },
            ),
            CustomButton(
              text: 'Forum',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ForumScreen(user: user)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
