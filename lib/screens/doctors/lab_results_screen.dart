import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare/models/user_model.dart';

class LabResultsScreen extends StatefulWidget {
  final UserModel user;

  LabResultsScreen({required this.user});

  @override
  _LabResultsScreenState createState() => _LabResultsScreenState();
}

class _LabResultsScreenState extends State<LabResultsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedPatientId;

  // Fungsi untuk menambahkan hasil lab baru
  void addLabResult(String testName, String result) async {
    if (selectedPatientId == null) {
      print("No patient selected");
      return;
    }
    try {
      await _firestore.collection('lab_results').add({
        'doctorUid': widget.user.uid,
        'patientId': selectedPatientId,
        'testName': testName,
        'result': result,
        'status': 'Pending',
        'date': DateTime.now().toIso8601String(),
      });
      print("Lab result added successfully");
    } catch (e) {
      print("Error adding lab result: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lab Results'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  String testName = '';
                  String result = '';

                  return AlertDialog(
                    title: Text('Add Lab Result'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('users')
                              .where('role', isEqualTo: 'patient')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            }
                            var patients = snapshot.data!.docs;
                            return DropdownButton<String>(
                              value: selectedPatientId,
                              hint: Text('Select Patient'),
                              onChanged: (newValue) {
                                setState(() {
                                  selectedPatientId = newValue;
                                });
                              },
                              items: patients.map((doc) {
                                var data = doc.data() as Map<String, dynamic>;
                                return DropdownMenuItem<String>(
                                  value: doc.id,
                                  child: Text(data['name'] ?? 'Unknown'),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        TextField(
                          decoration: InputDecoration(labelText: 'Test Name'),
                          onChanged: (value) {
                            testName = value;
                          },
                        ),
                        TextField(
                          decoration: InputDecoration(labelText: 'Result'),
                          onChanged: (value) {
                            result = value;
                          },
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          addLabResult(testName, result);
                          Navigator.pop(context);
                        },
                        child: Text('Add'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('lab_results')
            .where('doctorUid', isEqualTo: widget.user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No lab results found.'));
          }

          var labResults = snapshot.data!.docs;

          return ListView.builder(
            itemCount: labResults.length,
            itemBuilder: (context, index) {
              var labResult = labResults[index].data() as Map<String, dynamic>;
              String patientId = labResult['patientId'] ?? 'Unknown';
              String testName = labResult['testName'] ?? 'Unknown Test';
              String result = labResult['result'] ?? 'Not Available';
              String status = labResult['status'] ?? 'Pending';
              String docId = labResults[index].id; // ID dokumen Firestore
              String date = labResult['date'] ?? 'Unknown Date';
              String notes = labResult['notes'] ?? '';

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(patientId).get(),
                builder: (context, patientSnapshot) {
                  if (patientSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Test: $testName'),
                      subtitle: Text('Loading patient data...'),
                    );
                  }

                  if (patientSnapshot.hasError ||
                      !patientSnapshot.hasData ||
                      !patientSnapshot.data!.exists) {
                    return ListTile(
                      title: Text('Test: $testName'),
                      subtitle: Text(
                          'Result: $result\nStatus: $status\nPatient: Not Found'),
                    );
                  }

                  var patientData =
                      patientSnapshot.data!.data() as Map<String, dynamic>;
                  String patientName = patientData['name'] ?? 'Unknown';

                  return ListTile(
                    title: Text('Test: $testName'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Result: $result'),
                        Text('Date: $date'),
                        Text('Patient: $patientName'),
                        Row(
                          children: [
                            Text('Status: '),
                            DropdownButton<String>(
                              value: status,
                              onChanged: (newStatus) async {
                                if (newStatus != null) {
                                  await _firestore
                                      .collection('lab_results')
                                      .doc(docId)
                                      .update({
                                    'status': newStatus,
                                  });
                                  setState(() {}); // Refresh UI setelah update
                                }
                              },
                              items: ['Pending', 'Reviewed', 'Completed']
                                  .map((status) => DropdownMenuItem(
                                        value: status,
                                        child: Text(status),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text('Doctor Notes:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        TextField(
                          controller: TextEditingController(text: notes),
                          maxLines: 3,
                          decoration: InputDecoration(
                              hintText: 'Enter notes...',
                              border: OutlineInputBorder()),
                          onChanged: (value) {
                            notes = value;
                          },
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            await _firestore
                                .collection('lab_results')
                                .doc(docId)
                                .update({'notes': notes});
                            setState(() {});
                          },
                          child: Text('Save Notes'),
                        ),
                      ],
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
