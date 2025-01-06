import 'package:flutter/material.dart';
import 'package:medicare/screens/patients/book_appointment_screen.dart';
import 'package:medicare/screens/patients/my_appointment_screen.dart';
import 'package:medicare/screens/patients/medical_records_screen.dart';
import 'package:medicare/screens/patients/prescription_screen.dart';
import 'package:medicare/screens/patients/lab_result_screen.dart';
import 'package:medicare/screens/patients/find_hospital_screen.dart';
import 'package:medicare/screens/patients/profile_screen.dart';
import 'package:medicare/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PatientDashboard extends StatelessWidget {
  final UserModel user;

  PatientDashboard({required this.user});

  final List<String> bannerImages = [
    'assets/images/banner1.jpg',
    'assets/images/banner2.jpg',
    'assets/images/banner3.jpg',
  ];

  Future<Map<String, dynamic>> fetchCovidData() async {
    final response =
        await http.get(Uri.parse('https://disease.sh/v3/covid-19/all'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load covid data');
    }
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
                  Colors.blue.shade700,
                  Colors.blue.shade500,
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
                                'Halo,',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                user.name ?? 'Pasien',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
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

                  // Banner Carousel in Card
                  Container(
                    height: screenSize.height * 0.25,
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: PageView.builder(
                        itemCount: bannerImages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: AssetImage(bannerImages[index]),
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Menu Grid in Card
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Layanan Kami',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double aspectRatio = constraints.maxWidth /
                                (constraints.maxHeight *
                                    1.5); // Pastikan aspect ratio valid
                            return GridView.count(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              crossAxisCount: 4,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 8,
                              childAspectRatio: aspectRatio > 0
                                  ? aspectRatio
                                  : 1.0, // Memastikan aspect ratio selalu lebih besar dari 0
                              children: [
                                MenuIcon(
                                  icon: Icons.calendar_today,
                                  label: 'Book\nAppointment',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BookAppointmentScreen(user: user),
                                    ),
                                  ),
                                ),
                                MenuIcon(
                                  icon: Icons.assignment,
                                  label: 'My\nAppointments',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MyAppointmentScreen(user: user),
                                    ),
                                  ),
                                ),
                                MenuIcon(
                                  icon: Icons.medical_services,
                                  label: 'Medical\nRecords',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MedicalRecordsScreen(user: user),
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
                                          PrescriptionScreen(user: user),
                                    ),
                                  ),
                                ),
                                MenuIcon(
                                  icon: Icons.local_hospital,
                                  label: 'Lab\nResults',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          LabResultScreen(user: user),
                                    ),
                                  ),
                                ),
                                MenuIcon(
                                  icon: Icons.local_hospital,
                                  label: 'Find\nHospital',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FindHospitalScreen(user: user),
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

                  // Health Statistics Card
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'COVID-19 Statistics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        FutureBuilder<Map<String, dynamic>>(
                          future: fetchCovidData(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }
                            return CovidStatistics(data: snapshot.data!);
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget untuk Menu Icon
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
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.blue.shade700, size: 24),
          ),
          SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
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

// Widget untuk COVID Statistics
class CovidStatistics extends StatelessWidget {
  final Map<String, dynamic> data;

  const CovidStatistics({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Wrap StatItem widgets with Expanded to avoid overflow
          Expanded(
            child: StatItem(
              label: 'Total Cases',
              value: data['cases'].toString(),
              color: Colors.orange,
            ),
          ),
          Expanded(
            child: StatItem(
              label: 'Recovered',
              value: data['recovered'].toString(),
              color: Colors.green,
            ),
          ),
          Expanded(
            child: StatItem(
              label: 'Deaths',
              value: data['deaths'].toString(),
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          overflow:
              TextOverflow.ellipsis, // Avoid overflow in case of long values
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
