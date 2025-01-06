import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LabResultDetailScreen extends StatelessWidget {
  final Map<String, dynamic> labResult;

  LabResultDetailScreen({required this.labResult});

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
      appBar: AppBar(title: Text('Lab Result Details')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Test: ${labResult['testName']}',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Date: ${labResult['date']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Result: ${labResult['result']}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Status: ${labResult['status'] ?? 'Pending'}',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),
            SizedBox(height: 20),

            // FutureBuilder untuk menampilkan nama dokter
            FutureBuilder<String>(
              future: getDoctorName(labResult['doctorUid'] ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Doctor: Loading...',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
                }
                if (snapshot.hasError) {
                  return Text('Doctor: Unknown Doctor',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
                }
                return Text(
                  'Doctor: ${snapshot.data}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                );
              },
            ),

            SizedBox(height: 20),
            Text(
              'Doctor Notes:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(labResult['notes'] ?? 'No additional notes.',
                style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
