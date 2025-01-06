import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare/models/user_model.dart';

class MedicalRecordsScreen extends StatefulWidget {
  final UserModel user;

  MedicalRecordsScreen({required this.user});

  @override
  _MedicalRecordsScreenState createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _recordIdController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _treatmentController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String? _selectedPatientId;
  String? _selectedPatientName;

  // Fungsi untuk menambah rekam medis
  Future<void> _addMedicalRecord() async {
    var docRef = await _firestore.collection('medicalRecords').add({
      'doctorId': widget.user.uid,
      'patientId': _selectedPatientId,
      'patientName': _selectedPatientName,
      'date': _dateController.text,
      'diagnosis': _diagnosisController.text,
      'treatment': _treatmentController.text,
      'notes': _notesController.text,
    });

    // Menambahkan recordId setelah berhasil menambahkan data
    await docRef.update({'recordId': docRef.id});
  }

  // Fungsi untuk memperbarui rekam medis
  Future<void> _updateMedicalRecord(String recordId) async {
    await _firestore.collection('medicalRecords').doc(recordId).update({
      'date': _dateController.text,
      'diagnosis': _diagnosisController.text,
      'treatment': _treatmentController.text,
      'notes': _notesController.text,
    });
  }

  // Fungsi untuk menghapus rekam medis
  Future<void> _deleteMedicalRecord(String recordId) async {
    await _firestore.collection('medicalRecords').doc(recordId).delete();
  }

  // Fungsi untuk mengambil daftar pasien dari koleksi 'users' dengan role 'patient'
  Future<List<DocumentSnapshot>> _getPatients() async {
    var querySnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'patient')
        .get();
    return querySnapshot.docs;
  }

  // Fungsi untuk memilih tanggal
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Records for Dr. ${widget.user.name}'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Menampilkan form untuk menambah rekam medis
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Add New Medical Record'),
                  content: Column(
                    children: [
                      FutureBuilder<List<DocumentSnapshot>>(
                        future: _getPatients(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
                                    (patient) =>
                                        patient.id == newValue)['name'];
                              });
                            },
                            hint: Text('Select Patient'),
                            items:
                                patients.map<DropdownMenuItem<String>>((doc) {
                              return DropdownMenuItem<String>(
                                value: doc.id,
                                child: Text(doc['name']),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      GestureDetector(
                        onTap: () =>
                            _selectDate(context), // Trigger date picker
                        child: AbsorbPointer(
                          child: TextField(
                            controller: _dateController,
                            decoration: InputDecoration(labelText: 'Date'),
                          ),
                        ),
                      ),
                      TextField(
                        controller: _diagnosisController,
                        decoration: InputDecoration(labelText: 'Diagnosis'),
                      ),
                      TextField(
                        controller: _treatmentController,
                        decoration: InputDecoration(labelText: 'Treatment'),
                      ),
                      TextField(
                        controller: _notesController,
                        decoration: InputDecoration(labelText: 'Notes'),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        if (_selectedPatientId != null) {
                          _addMedicalRecord();
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
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('medicalRecords')
            .where('doctorId', isEqualTo: widget.user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No medical records found.'));
          }

          final records = snapshot.data!.docs;
          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index].data() as Map<String, dynamic>;
              final recordId = records[index].id;

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Patient: ${record['patientName']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${record['date']}'),
                      Text('Diagnosis: ${record['diagnosis']}'),
                      Text('Treatment: ${record['treatment']}'),
                      Text('Notes: ${record['notes']}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Menampilkan form untuk memperbarui rekam medis
                          _recordIdController.text = record['recordId'];
                          _dateController.text = record['date'];
                          _diagnosisController.text = record['diagnosis'];
                          _treatmentController.text = record['treatment'];
                          _notesController.text = record['notes'];

                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Update Medical Record'),
                              content: Column(
                                children: [
                                  TextField(
                                    controller: _dateController,
                                    decoration:
                                        InputDecoration(labelText: 'Date'),
                                  ),
                                  TextField(
                                    controller: _diagnosisController,
                                    decoration:
                                        InputDecoration(labelText: 'Diagnosis'),
                                  ),
                                  TextField(
                                    controller: _treatmentController,
                                    decoration:
                                        InputDecoration(labelText: 'Treatment'),
                                  ),
                                  TextField(
                                    controller: _notesController,
                                    decoration:
                                        InputDecoration(labelText: 'Notes'),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    _updateMedicalRecord(recordId);
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
                              title: Text('Delete Medical Record'),
                              content: Text(
                                  'Are you sure you want to delete this record?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    _deleteMedicalRecord(recordId);
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
