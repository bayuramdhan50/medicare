import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare/models/user_model.dart';

class MedicalRecordsScreen extends StatelessWidget {
  final UserModel user;

  MedicalRecordsScreen({required this.user});

  // Function to fetch doctor's name based on doctorId
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
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Records'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Medical Records for ${user.name}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            // Fetching medical records from Firestore in real-time
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('medicalRecords') // Update collection name
                    .where('patientId',
                        isEqualTo: user.uid) // Filter by patientId
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No medical records available.'));
                  }

                  var records = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      var record =
                          records[index].data() as Map<String, dynamic>;

                      // Retrieve medical record fields
                      String date = record['date'] ?? 'Not specified';
                      String diagnosis = record['diagnosis'] ?? 'Not specified';
                      String treatment = record['treatment'] ?? 'Not specified';
                      String notes = record['notes'] ?? 'Not specified';
                      String doctorId = record['doctorId'] ?? 'Not specified';
                      String patientName =
                          record['patientName'] ?? 'Not specified';

                      return Card(
                        margin: EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Patient: $patientName',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Diagnosis: $diagnosis',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Treatment: $treatment',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Date of Diagnosis: $date',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Notes: $notes',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              // Fetching doctor's name
                              FutureBuilder<String>(
                                future: getDoctorName(doctorId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  }

                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }

                                  if (snapshot.hasData) {
                                    return Text(
                                      'Doctor: ${snapshot.data}',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    );
                                  } else {
                                    return Text(
                                      'Doctor: Not specified',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    );
                                  }
                                },
                              ),
                              SizedBox(height: 16),
                            ],
                          ),
                        ),
                      );
                    },
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
