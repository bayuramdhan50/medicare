import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medicare/models/user_model.dart';
import 'package:intl/intl.dart';

class PrescriptionScreen extends StatelessWidget {
  final UserModel user;

  PrescriptionScreen({required this.user});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi untuk mendapatkan nama dokter berdasarkan doctorUid
  Future<String> getDoctorName(String doctorUid) async {
    try {
      var docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .where('uid', isEqualTo: doctorUid)
          .limit(1)
          .get();

      if (docSnapshot.docs.isNotEmpty) {
        return docSnapshot.docs.first.data()['name'] ?? 'Unknown Doctor';
      } else {
        return 'Unknown Doctor';
      }
    } catch (e) {
      return 'Unknown Doctor';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade50, Colors.white],
              ),
            ),
          ),

          // Header dengan wave clipper
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade800],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Prescriptions',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            user.name,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('prescriptions')
                    .where('patientId', isEqualTo: user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.medication_outlined,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No prescriptions available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final prescriptions = snapshot.data!.docs;
                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: prescriptions.length,
                    itemBuilder: (context, index) {
                      final prescription =
                          prescriptions[index].data() as Map<String, dynamic>;
                      final doctorUid = prescription['doctorId'];

                      return FutureBuilder<String>(
                        future: getDoctorName(doctorUid),
                        builder: (context, doctorSnapshot) {
                          return Card(
                            elevation: 4,
                            margin: EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  colors: [Colors.white, Colors.blue.shade50],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today,
                                            color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text(
                                          DateFormat('yyyy-MM-dd').format(
                                              prescription['date'].toDate()),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(height: 24),
                                    _buildInfoRow(
                                      Icons.person,
                                      'Doctor',
                                      doctorSnapshot.data ?? 'Loading...',
                                    ),
                                    SizedBox(height: 12),
                                    _buildInfoRow(
                                      Icons.medication,
                                      'Medicine',
                                      prescription['medication'] ??
                                          'Not specified',
                                    ),
                                    SizedBox(height: 12),
                                    _buildInfoRow(
                                      Icons.schedule,
                                      'Dose',
                                      prescription['dose'] ?? 'Not specified',
                                    ),
                                    SizedBox(height: 12),
                                    _buildInfoRow(
                                      Icons.info_outline,
                                      'Instructions',
                                      prescription['instructions'] ??
                                          'Not specified',
                                    ),
                                    SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        icon: Icon(Icons.remove_red_eye),
                                        label: Text('View Details'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12),
                                        ),
                                        onPressed: () {
                                          // Add functionality to view details
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
        Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
