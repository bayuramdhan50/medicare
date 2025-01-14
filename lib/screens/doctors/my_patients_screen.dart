import 'package:flutter/material.dart';
import 'package:medicare/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare/screens/doctors/app_color.dart';

class MyPatientsScreen extends StatelessWidget {
  final UserModel user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  MyPatientsScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Pasien',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('appointments')
              .where('doctorUid', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, appointmentSnapshot) {
            if (appointmentSnapshot.hasError) {
              return Center(
                child: Text(
                  'Terjadi kesalahan',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            }

            if (appointmentSnapshot.connectionState ==
                ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              );
            }

            if (!appointmentSnapshot.hasData ||
                appointmentSnapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Tidak ada pasien',
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                  ],
                ),
              );
            }

            Set<String> patientIds = appointmentSnapshot.data!.docs
                .map((doc) =>
                    (doc.data() as Map<String, dynamic>)['patientId'] as String)
                .toSet();

            return StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .where(FieldPath.documentId, whereIn: patientIds.toList())
                  .snapshots(),
              builder: (context, patientSnapshot) {
                if (patientSnapshot.hasError) {
                  return Center(
                    child: Text(
                      'Terjadi kesalahan',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  );
                }

                if (patientSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  );
                }

                if (!patientSnapshot.hasData ||
                    patientSnapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Tidak ada data pasien',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: patientSnapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var patientData = patientSnapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor:
                              AppColors.primaryGreen.withOpacity(0.2),
                          child: Icon(
                            Icons.person,
                            size: 35,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        title: Text(
                          patientData['name'] ?? 'Nama tidak tersedia',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.email,
                                    size: 16, color: Colors.grey[600]),
                                SizedBox(width: 8),
                                Text(
                                  patientData['email'] ?? '-',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.phone,
                                    size: 16, color: Colors.grey[600]),
                                SizedBox(width: 8),
                                Text(
                                  patientData['phone'] ?? '-',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
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
    );
  }
}
