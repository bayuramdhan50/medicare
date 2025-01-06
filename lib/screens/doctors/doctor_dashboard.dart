import 'package:flutter/material.dart';
import 'package:medicare/screens/doctors/my_patients_screen.dart';
import 'package:medicare/screens/doctors/appointments_screen.dart';
import 'package:medicare/screens/doctors/prescription_screen.dart';
import 'package:medicare/screens/doctors/medical_records_screen.dart';
import 'package:medicare/screens/doctors/lab_results_screen.dart';
import 'package:medicare/models/user_model.dart';
import 'package:medicare/screens/doctors/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorDashboard extends StatefulWidget {
  final UserModel user;

  DoctorDashboard({required this.user});

  @override
  _DoctorDashboardState createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int patientCount = 0;
  int todayAppointments = 0;
  int pendingAppointments = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Function to fetch data from Firestore
  Future<void> _fetchData() async {
    // Fetching patients count
    QuerySnapshot patientSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'patient')
        .get();

    // Fetching today's appointments count
    DateTime now = DateTime.now();
    String today =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    QuerySnapshot todayAppointmentsSnapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('date', isEqualTo: today)
        .get();

    // Fetching pending appointments count
    QuerySnapshot pendingAppointmentsSnapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('status', isEqualTo: 'Pending')
        .get();

    // Updating the state with fetched data
    setState(() {
      patientCount = patientSnapshot.docs.length;
      todayAppointments = todayAppointmentsSnapshot.docs.length;
      pendingAppointments = pendingAppointmentsSnapshot.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            height: screenSize.height * 0.3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.green.shade700,
                  Colors.green.shade500,
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome,',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Dr. ${widget.user.name ?? 'Doctor'}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1, // Ensure the name doesn't overflow
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigate to ProfileScreen when CircleAvatar is tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfileScreen()),
                            );
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, color: Colors.blue),
                          ),
                        )
                      ],
                    ),
                  ),

                  // Statistics Card
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        StatItem(
                          icon: Icons.people,
                          label: 'Patients',
                          value: '$patientCount',
                          color: Colors.blue,
                        ),
                        StatItem(
                          icon: Icons.calendar_today,
                          label: 'Today',
                          value: '$todayAppointments',
                          color: Colors.orange,
                        ),
                        StatItem(
                          icon: Icons.access_time,
                          label: 'Pending',
                          value: '$pendingAppointments',
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),

                  // Menu Grid
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      // Wrap the Column in a SingleChildScrollView
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              double aspectRatio = constraints.maxWidth /
                                  (constraints.maxHeight * 1.5);

                              return GridView.count(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                crossAxisCount: 3,
                                mainAxisSpacing: 1,
                                crossAxisSpacing: 1,
                                childAspectRatio:
                                    aspectRatio > 0 ? aspectRatio : 1.0,
                                children: [
                                  MenuIcon(
                                    icon: Icons.people,
                                    label: 'My\nPatients',
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MyPatientsScreen(user: widget.user),
                                      ),
                                    ),
                                  ),
                                  MenuIcon(
                                    icon: Icons.calendar_today,
                                    label: 'Appointments',
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AppointmentsScreen(
                                                user: widget.user),
                                      ),
                                    ),
                                  ),
                                  MenuIcon(
                                    icon: Icons.medical_services,
                                    label: 'Prescription',
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PrescriptionScreen(
                                                user: widget.user),
                                      ),
                                    ),
                                  ),
                                  MenuIcon(
                                    icon: Icons.folder_shared,
                                    label: 'Medical\nRecords',
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MedicalRecordsScreen(
                                                user: widget.user),
                                      ),
                                    ),
                                  ),
                                  MenuIcon(
                                    icon: Icons.science,
                                    label: 'Lab\nResults',
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            LabResultsScreen(user: widget.user),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const MenuIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.green.shade700, size: 32),
          ),
          SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
