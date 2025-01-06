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
      appBar: AppBar(
        title: Text('Prescriptions'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Prescriptions for ${user.name}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            // Mengambil data resep dari Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('prescriptions')
                    .where('patientId',
                        isEqualTo: user.uid) // Hanya mengambil resep pasien ini
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No prescriptions available.'));
                  }

                  final prescriptions = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: prescriptions.length,
                    itemBuilder: (context, index) {
                      final prescription =
                          prescriptions[index].data() as Map<String, dynamic>;

                      // Mengambil doctorId dari resep
                      final doctorUid = prescription['doctorId'];

                      // Menggunakan FutureBuilder untuk menampilkan nama dokter
                      return FutureBuilder<String>(
                        future:
                            getDoctorName(doctorUid), // Memanggil getDoctorName
                        builder: (context, doctorSnapshot) {
                          if (doctorSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Card(
                              margin: EdgeInsets.only(bottom: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Doctor: Loading...',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Medicine: ${prescription['medication']}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Dose: ${prescription['dose']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Instructions: ${prescription['instructions']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                        'Date: ${DateFormat('yyyy-MM-dd').format(prescription['date'].toDate())}'),
                                    SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            );
                          }

                          if (doctorSnapshot.hasError) {
                            return Card(
                              margin: EdgeInsets.only(bottom: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Doctor: Unknown',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Medicine: ${prescription['medication']}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Dose: ${prescription['dose']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Instructions: ${prescription['instructions']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                        'Date: ${DateFormat('yyyy-MM-dd').format(prescription['date'].toDate())}'),
                                    SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Card(
                            margin: EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Doctor: ${doctorSnapshot.data}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Medicine: ${prescription['medication']}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Dose: ${prescription['dose']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Instructions: ${prescription['instructions']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                      'Date: ${DateFormat('yyyy-MM-dd').format(prescription['date'].toDate())}'),
                                  SizedBox(height: 16),
                                ],
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
          ],
        ),
      ),
    );
  }
}
