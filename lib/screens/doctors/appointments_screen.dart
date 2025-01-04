import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare/models/user_model.dart';

class AppointmentsScreen extends StatelessWidget {
  final UserModel user;

  AppointmentsScreen({required this.user});

  // Method untuk mengupdate status appointment
  void updateStatus(String appointmentId, String newStatus) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': newStatus,
      });
      print("Status updated to $newStatus");
    } catch (e) {
      print("Error updating status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('appointments')
            .where('doctorUid',
                isEqualTo: user.uid) // Filter appointments by doctor's UID
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No appointments found.'));
          }

          var appointments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              var appointment =
                  appointments[index].data() as Map<String, dynamic>;
              String patientId = appointment['patientId'] ?? 'Unknown';
              String date = appointment['date'] ?? 'Not specified';
              String time = appointment['time'] ?? 'Not specified';
              String status = appointment['status'] ?? 'Pending';
              String doctorName = appointment['doctor'] ?? 'Unknown';
              String appointmentId =
                  appointments[index].id; // Get the document ID

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(patientId).get(),
                builder: (context, patientSnapshot) {
                  if (patientSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Card(
                      margin:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        title: Text('Patient ID: $patientId'),
                        subtitle: Text('Loading patient data...'),
                        trailing: Icon(Icons.calendar_today),
                      ),
                    );
                  }

                  if (patientSnapshot.hasError) {
                    return Card(
                      margin:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        title: Text('Patient: Error loading data'),
                        subtitle: Text('Could not fetch patient details.'),
                        trailing: Icon(Icons.calendar_today),
                      ),
                    );
                  }

                  if (!patientSnapshot.hasData ||
                      !patientSnapshot.data!.exists) {
                    return Card(
                      margin:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        title: Text('Patient: Not found'),
                        subtitle: Text('No patient data available.'),
                        trailing: Icon(Icons.calendar_today),
                      ),
                    );
                  }

                  var patientData =
                      patientSnapshot.data!.data() as Map<String, dynamic>;
                  String patientName = patientData['name'] ?? 'Unknown';

                  return Card(
                    margin:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      title: Text('Patient: $patientName'),
                      subtitle: Text(
                          'Date: $date\nTime: $time\nStatus: $status\nDoctor: $doctorName'),
                      trailing: Icon(Icons.calendar_today),
                      // Button to update status
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Update Appointment Status'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ElevatedButton(
                                    onPressed: () {
                                      updateStatus(appointmentId, 'Completed');
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Mark as Completed'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      updateStatus(appointmentId, 'Cancelled');
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Mark as Cancelled'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
