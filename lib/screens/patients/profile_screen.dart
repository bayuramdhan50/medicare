import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare/models/user_model.dart';
import 'edit_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  final Function onProfileUpdated;
  final Function onLogout;

  ProfileScreen({
    required this.user,
    required this.onProfileUpdated,
    required this.onLogout,
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Define consistent colors
  final Color primaryBlue = Color(0xFF0077B6);
  final Color darkBlue = Color(0xFF00B4D8);
  final Color lightBlue = Color(0xFF0077B6).withOpacity(0.8);
  final Color accentBlue = Color(0xFF00B4D8);

  Future<UserModel?> _fetchUserData() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(widget.user.uid).get();
      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<UserModel?>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[700]),
                  SizedBox(height: 16),
                  Text(
                    "Failed to load profile",
                    style: TextStyle(fontSize: 18, color: Colors.red[700]),
                  ),
                ],
              ),
            );
          }

          UserModel user = snapshot.data!;

          return Stack(
            children: [
              // Enhanced Background Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      darkBlue,
                      primaryBlue,
                      lightBlue.withOpacity(0.8),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              // Main Content
              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header Section
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                        child: Column(
                          children: [
                            // Enhanced Profile Picture
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: darkBlue.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  size: 70,
                                  color: primaryBlue,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            // Enhanced User Name
                            Text(
                              user.name,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: darkBlue.withOpacity(0.5),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            // Enhanced User Email
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.95),
                                shadows: [
                                  Shadow(
                                    color: darkBlue.withOpacity(0.3),
                                    blurRadius: 3,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Enhanced Information Section
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: darkBlue.withOpacity(0.2),
                              blurRadius: 15,
                              offset: Offset(0, -8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section Title
                              Row(
                                children: [
                                  Icon(Icons.person_pin,
                                      color: primaryBlue, size: 30),
                                  SizedBox(width: 10),
                                  Text(
                                    'Personal Information',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: darkBlue,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),

                              // Info Cards
                              _buildInfoCard(
                                icon: Icons.calendar_today,
                                title: 'Age',
                                subtitle: user.age?.toString() ?? 'Not set',
                              ),
                              _buildInfoCard(
                                icon: Icons.accessibility,
                                title: 'Gender',
                                subtitle: user.gender ?? 'Not set',
                              ),
                              _buildInfoCard(
                                icon: Icons.account_circle,
                                title: 'Role',
                                subtitle: user.role,
                              ),

                              SizedBox(height: 20),

                              // Enhanced Edit Profile Button
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.edit, color: Colors.white),
                                  label: Text('Edit Profile',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      )),
                                  onPressed: () async {
                                    final updatedUser = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditProfileScreen(
                                          user: user,
                                          onSave: (updatedUser) {
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryBlue,
                                    elevation: 3,
                                    shadowColor: primaryBlue.withOpacity(0.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 15),

                              // Enhanced Logout Button
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.logout, color: Colors.white),
                                  label: Text('Logout',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      )),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          elevation: 10,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color(0xFF42A5F5),
                                                  Color(0xFF2196F3),
                                                ],
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Header Icon
                                                  Container(
                                                    padding: EdgeInsets.all(15),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.exit_to_app,
                                                      color: Colors.white,
                                                      size: 50,
                                                    ),
                                                  ),
                                                  SizedBox(height: 20),

                                                  // Title
                                                  Text(
                                                    'Konfirmasi Logout',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  SizedBox(height: 15),

                                                  // Content
                                                  Text(
                                                    'Apakah Anda yakin ingin keluar dari aplikasi?',
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 16,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  SizedBox(height: 25),

                                                  // Action Buttons
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      // Cancel Button
                                                      Expanded(
                                                        child: OutlinedButton(
                                                          style: OutlinedButton
                                                              .styleFrom(
                                                            side: BorderSide(
                                                                color: Colors
                                                                    .white,
                                                                width: 2),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        12),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                            ),
                                                          ),
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                          child: Text(
                                                            'Batal',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 15),

                                                      // Logout Button
                                                      Expanded(
                                                        child: ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors.white,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        12),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                            ),
                                                          ),
                                                          onPressed: () async {
                                                            await FirebaseAuth
                                                                .instance
                                                                .signOut();
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            widget.onLogout();
                                                          },
                                                          child: Text(
                                                            'Logout',
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xFF2196F3),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[700],
                                    elevation: 3,
                                    shadowColor: Colors.red.withOpacity(0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Enhanced Info Card Widget
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 20),
      shadowColor: primaryBlue.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              accentBlue.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              // Enhanced Icon Container
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: lightBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: primaryBlue, size: 28),
              ),
              SizedBox(width: 20),
              // Enhanced Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
