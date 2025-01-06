import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare/models/user_model.dart';
import 'package:intl/intl.dart';

class PrescriptionScreen extends StatefulWidget {
  final UserModel user;

  PrescriptionScreen({required this.user});

  @override
  _PrescriptionScreenState createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  String? _selectedPatientId;
  String? _selectedPatientName;

  // Fungsi untuk menambah resep
  Future<void> _addPrescription() async {
    var docRef = await _firestore.collection('prescriptions').add({
      'doctorId': widget.user.uid,
      'patientId': _selectedPatientId,
      'patientName': _selectedPatientName,
      'medication': _medicationController.text,
      'dose': _doseController.text,
      'instructions': _instructionsController.text,
      'date': DateFormat('yyyy-MM-dd').format(DateTime.now()), // Format tanggal
    });

    // Menambahkan prescriptionId setelah berhasil menambahkan data
    await docRef.update({'prescriptionId': docRef.id});
  }

  // Fungsi untuk mengambil daftar pasien dari koleksi 'users' dengan role 'patient'
  Future<List<DocumentSnapshot>> _getPatients() async {
    var querySnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'patient')
        .get();
    return querySnapshot.docs;
  }

  // Fungsi untuk menampilkan form tambah resep
  void _showAddPrescriptionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add Prescription'),
        content: Column(
          children: [
            FutureBuilder<List<DocumentSnapshot>>(
              future: _getPatients(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No patients found.');
                }

                final patients = snapshot.data!;
                return DropdownButton<String>(
                  value: _selectedPatientId,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedPatientId = newValue;
                      _selectedPatientName = patients.firstWhere(
                          (patient) => patient.id == newValue)['name'];
                    });
                  },
                  hint: Text('Select Patient'),
                  items: patients.map<DropdownMenuItem<String>>((doc) {
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(doc['name']),
                    );
                  }).toList(),
                );
              },
            ),
            TextField(
              controller: _medicationController,
              decoration: InputDecoration(labelText: 'Medication'),
            ),
            TextField(
              controller: _doseController,
              decoration: InputDecoration(labelText: 'Dose'),
            ),
            TextField(
              controller: _instructionsController,
              decoration: InputDecoration(labelText: 'Instructions'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_selectedPatientId != null) {
                _addPrescription();
                Navigator.pop(context);
              } else {
                // Informasi bahwa pasien harus dipilih
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please select a patient')),
                );
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prescriptions for Dr. ${widget.user.name}'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddPrescriptionDialog,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('prescriptions')
            .where('doctorId', isEqualTo: widget.user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No prescriptions found.'));
          }

          final prescriptions = snapshot.data!.docs;
          return ListView.builder(
            itemCount: prescriptions.length,
            itemBuilder: (context, index) {
              final prescription =
                  prescriptions[index].data() as Map<String, dynamic>;
              final prescriptionId = prescriptions[index].id;

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Patient: ${prescription['patientName']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Medication: ${prescription['medication']}'),
                      Text('Dose: ${prescription['dose']}'),
                      Text('Instructions: ${prescription['instructions']}'),
                      Text(
                          'Date: ${DateFormat('yyyy-MM-dd').format(prescription['date'].toDate())}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Menampilkan form untuk memperbarui resep
                          _medicationController.text =
                              prescription['medication'];
                          _doseController.text = prescription['dose'];
                          _instructionsController.text =
                              prescription['instructions'];

                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Update Prescription'),
                              content: Column(
                                children: [
                                  TextField(
                                    controller: _medicationController,
                                    decoration: InputDecoration(
                                        labelText: 'Medication'),
                                  ),
                                  TextField(
                                    controller: _doseController,
                                    decoration:
                                        InputDecoration(labelText: 'Dose'),
                                  ),
                                  TextField(
                                    controller: _instructionsController,
                                    decoration: InputDecoration(
                                        labelText: 'Instructions'),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('prescriptions')
                                        .doc(prescriptionId)
                                        .update({
                                      'medication': _medicationController.text,
                                      'dose': _doseController.text,
                                      'instructions':
                                          _instructionsController.text,
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text('Update'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Mengonfirmasi penghapusan
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Delete Prescription'),
                              content: Text(
                                  'Are you sure you want to delete this prescription?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('prescriptions')
                                        .doc(prescriptionId)
                                        .delete();
                                    Navigator.pop(context);
                                  },
                                  child: Text('Delete'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
