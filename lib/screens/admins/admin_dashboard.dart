import 'package:flutter/material.dart';
import 'add_doctor_screen.dart';
import 'user_statistics_screen.dart';
import 'manage_users_screen.dart';
import 'package:medicare/models/user_model.dart';
import 'admin_profile_screen.dart';
import 'package:d_chart/d_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare/auth/login_screen.dart';
import 'package:medicare/screens/admins/user_table_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDashboard extends StatefulWidget {
  final UserModel user;

  AdminDashboard({required this.user});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final Color primaryColor = Color(0xFF08A8B1);
  final Color secondaryColor = Color(0xFFF19E23);

  Map<String, int> userCounts = {
    'Admin': 0,
    'Doctor': 0,
    'Patient': 0,
  };

  @override
  void initState() {
    super.initState();
    fetchUserCounts();
  }

  Future<void> fetchUserCounts() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      int adminCount = 0;
      int doctorCount = 0;
      int patientCount = 0;

      for (var doc in snapshot.docs) {
        print('User ${doc.id} role: ${doc['role']}');

        String role = doc['role']?.toString().toLowerCase() ?? '';
        if (role == 'admin') {
          adminCount++;
          print('Admin found: $adminCount');
        } else if (role == 'doctor') {
          doctorCount++;
          print('Doctor found: $doctorCount');
        } else if (role == 'patient') {
          patientCount++;
          print('Patient found: $patientCount');
        }
      }

      setState(() {
        userCounts['Admin'] = adminCount;
        userCounts['Doctor'] = doctorCount;
        userCounts['Patient'] = patientCount;

        print(
            'Updated counts - Admin: $adminCount, Doctor: $doctorCount, Patient: $patientCount');
      });
    } catch (e) {
      print('Error fetching user counts: $e');
    }
  }

  Widget _getPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return UserStatisticsScreen(user: widget.user);
      case 2:
        return AdminProfileScreen();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'images/Logo.png',
                        width: 40,
                        height: 40,
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Healthcare',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Admin Dashboard',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.white),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Konfirmasi Logout'),
                          content: Text('Apakah Anda yakin ingin keluar?'),
                          actions: [
                            TextButton(
                              child: Text(
                                'Batal',
                                style: TextStyle(color: Colors.grey),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text(
                                'Logout',
                                style: TextStyle(
                                  color: secondaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                // Implementasi logout
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          _buildUserChart(),
          SizedBox(height: 24),
          Column(
            children: [
              _buildMenuFlex(
                'Add Doctor',
                Icons.medical_services,
                'Tambah dokter baru ke sistem',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddDoctorScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: 12),
              _buildMenuFlex(
                'Manage Users',
                Icons.manage_accounts,
                'Kelola semua pengguna sistem',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ManageUsersScreen(user: widget.user),
                    ),
                  );
                },
              ),
              SizedBox(height: 12),
              _buildMenuFlex(
                'User Tables',
                Icons.table_chart,
                'Lihat data pengguna dalam bentuk tabel',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserTableScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuFlex(
      String title, IconData icon, String description, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
          border: Border.all(
            color: primaryColor.withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: primaryColor,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: primaryColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserChart() {
    List<NumericData> numericList = [
      NumericData(domain: 1, measure: userCounts['Admin']?.toDouble() ?? 0),
      NumericData(domain: 2, measure: userCounts['Doctor']?.toDouble() ?? 0),
      NumericData(domain: 3, measure: userCounts['Patient']?.toDouble() ?? 0),
    ];

    final numericGroup = [
      NumericGroup(
        id: 'Bar',
        chartType: ChartType.bar,
        data: numericList,
        color: primaryColor,
      ),
      NumericGroup(
        id: 'Line',
        chartType: ChartType.line,
        data: numericList,
        color: secondaryColor,
      ),
    ];

    return Container(
      margin: EdgeInsets.only(top: 24),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            primaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Statistik Pengguna',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: secondaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Total: ${userCounts.values.reduce((a, b) => a + b)}',
                  style: TextStyle(
                    color: secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: DChartComboN(
              groupList: numericGroup,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('Admin', userCounts['Admin'] ?? 0, primaryColor),
              _buildLegendItem(
                  'Doctor', userCounts['Doctor'] ?? 0, secondaryColor),
              _buildLegendItem(
                  'Patient', userCounts['Patient'] ?? 0, primaryColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _getPage(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Grafik',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info_outline),
              activeIcon: Icon(Icons.info),
              label: 'About',
            ),
          ],
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      ),
    );
  }
}
