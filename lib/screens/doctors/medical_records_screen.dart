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

  void _showAddRecordDialog(BuildContext context) {
    // Reset controllers hanya pada saat dialog pertama kali dibuka
    if (_selectedPatientId == null) {
      _dateController.clear();
      _diagnosisController.clear();
      _treatmentController.clear();
      _notesController.clear();
      _selectedPatientId = null;
      _selectedPatientName = null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Medical Record'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedPatientId,
                      isExpanded: true,
                      underline: SizedBox(),
                      hint: Text('Select Patient'),
                      items: patients.map<DropdownMenuItem<String>>((doc) {
                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text(doc['name']),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedPatientId = newValue;
                          _selectedPatientName = patients.firstWhere(
                              (patient) => patient.id == newValue)['name'];
                        });
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _diagnosisController,
                decoration: InputDecoration(
                  labelText: 'Diagnosis',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _treatmentController,
                decoration: InputDecoration(
                  labelText: 'Treatment',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_selectedPatientId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please select a patient')),
                );
                return;
              }
              if (_dateController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please select a date')),
                );
                return;
              }
              _addMedicalRecord();
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> record, String recordId) {
    _dateController.text = record['date'];
    _diagnosisController.text = record['diagnosis'];
    _treatmentController.text = record['treatment'];
    _notesController.text = record['notes'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Medical Record'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _diagnosisController,
                decoration: InputDecoration(
                  labelText: 'Diagnosis',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _treatmentController,
                decoration: InputDecoration(
                  labelText: 'Treatment',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateMedicalRecord(recordId);
              Navigator.pop(context);
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String recordId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Medical Record'),
        content: Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteMedicalRecord(recordId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Medical Records',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Dr. ${widget.user.name}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      FloatingActionButton(
                        onPressed: () => _showAddRecordDialog(context),
                        backgroundColor: Colors.white,
                        child: Icon(Icons.add, color: Colors.blue),
                        mini: true,
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
              padding: const EdgeInsets.only(top: 100),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('medicalRecords')
                    .where('doctorId', isEqualTo: widget.user.uid)
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
                          Icon(Icons.medical_information,
                              size: 60, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No medical records found'),
                        ],
                      ),
                    );
                  }

                  final records = snapshot.data!.docs;
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record =
                          records[index].data() as Map<String, dynamic>;
                      final recordId = records[index].id;

                      return Card(
                        margin: EdgeInsets.only(bottom: 16),
                        elevation: 4,
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
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Patient: ${record['patientName']}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Date: ${record['date']}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton(
                                      icon: Icon(Icons.more_vert),
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          child: ListTile(
                                            leading: Icon(Icons.edit,
                                                color: Colors.blue),
                                            title: Text('Edit'),
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          onTap: () {
                                            Future.delayed(
                                              Duration(seconds: 0),
                                              () => _showEditDialog(
                                                  record, recordId),
                                            );
                                          },
                                        ),
                                        PopupMenuItem(
                                          child: ListTile(
                                            leading: Icon(Icons.delete,
                                                color: Colors.red),
                                            title: Text('Delete'),
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          onTap: () {
                                            Future.delayed(
                                              Duration(seconds: 0),
                                              () => _showDeleteDialog(recordId),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Divider(height: 24),
                                _buildInfoRow(
                                  Icons.medical_information,
                                  'Diagnosis',
                                  record['diagnosis'],
                                ),
                                SizedBox(height: 8),
                                _buildInfoRow(
                                  Icons.healing,
                                  'Treatment',
                                  record['treatment'],
                                ),
                                SizedBox(height: 8),
                                _buildInfoRow(
                                  Icons.note,
                                  'Notes',
                                  record['notes'],
                                ),
                              ],
                            ),
                          ),
                        ),
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
