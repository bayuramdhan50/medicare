import 'package:flutter/material.dart';
import 'package:medicare/models/user_model.dart';
import 'package:medicare/screens/patients/patient_dashboard.dart';
import 'package:medicare/screens/doctors/doctor_dashboard.dart';
import 'package:medicare/screens/admins/admin_dashboard.dart';
import 'package:medicare/widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  final UserModel user;

  // Menerima UserModel sebagai parameter untuk mengetahui role
  HomeScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Color(0xFF08A8B1),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Welcome ${user.name}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF19E23),
              ),
            ),
            SizedBox(height: 20),
            // Menampilkan tombol berdasarkan role
            if (user.role == 'patient') ...[
              CustomButton(
                text: 'Patient Dashboard',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PatientDashboard(user: user)),
                  );
                },
              ),
            ] else if (user.role == 'doctor') ...[
              CustomButton(
                text: 'Doctor Dashboard',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DoctorDashboard(user: user)),
                  );
                },
              ),
            ] else if (user.role == 'admin') ...[
              CustomButton(
                text: 'Admin Dashboard',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AdminDashboard(user: user)),
                  );
                },
              ),
            ],
            // Tombol umum untuk semua user
            CustomButton(
              text: 'Appointments',
              onPressed: () {
                // Navigasi ke AppointmentScreen
              },
            ),
            CustomButton(
              text: 'Medical Records',
              onPressed: () {
                // Navigasi ke MedicalRecordsScreen
              },
            ),
            CustomButton(
              text: 'Map',
              onPressed: () {
                // Navigasi ke MapScreen
              },
            ),
            CustomButton(
              text: 'Notifications',
              onPressed: () {
                // Navigasi ke NotificationsScreen
              },
            ),
            CustomButton(
              text: 'Forum',
              onPressed: () {
                // Navigasi ke ForumScreen
              },
            ),
            CustomButton(
              text: 'Profile',
              onPressed: () {
                // Navigasi ke ProfileScreen
              },
            ),
          ],
        ),
      ),
    );
  }
}
