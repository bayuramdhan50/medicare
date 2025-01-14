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
      'date': Timestamp.fromDate(DateTime.now()), // Format tanggal
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
                  SnackBar(
                    content: Text('Please select a patient'),
                    backgroundColor: Color(0xFF008000),
                  ),
                );
              }
            },
            child: Text('Add', style: TextStyle(color: Color(0xFF008000))),
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
                colors: [Color(0xFF008000).withOpacity(0.1), Colors.white],
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
                  colors: [Color(0xFF008000), Color(0xFF38B000)],
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
                            'Prescriptions',
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
                        onPressed: _showAddPrescriptionDialog,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.add, color: Color(0xFF008000)),
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
                    .collection('prescriptions')
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
                          Icon(Icons.medical_services_outlined,
                              size: 60, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No prescriptions found'),
                        ],
                      ),
                    );
                  }

                  final prescriptions = snapshot.data!.docs;
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: prescriptions.length,
                    itemBuilder: (context, index) {
                      final prescription =
                          prescriptions[index].data() as Map<String, dynamic>;
                      final prescriptionId = prescriptions[index].id;

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
                              colors: [
                                Colors.white,
                                Color(0xFF008000).withOpacity(0.1)
                              ],
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
                                            'Patient: ${prescription['patientName']}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Date: ${DateFormat('yyyy-MM-dd').format(prescription['date'].toDate())}',
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
                                            // Delay to allow menu to close
                                            Future.delayed(
                                              Duration(seconds: 0),
                                              () => _showEditDialog(
                                                  prescription, prescriptionId),
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
                                            // Delay to allow menu to close
                                            Future.delayed(
                                              Duration(seconds: 0),
                                              () => _showDeleteDialog(
                                                  prescriptionId),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Divider(height: 24),
                                _buildInfoRow(
                                  Icons.medication,
                                  'Medication',
                                  prescription['medication'],
                                ),
                                SizedBox(height: 8),
                                _buildInfoRow(
                                  Icons.scale,
                                  'Dose',
                                  prescription['dose'],
                                ),
                                SizedBox(height: 8),
                                _buildInfoRow(
                                  Icons.info_outline,
                                  'Instructions',
                                  prescription['instructions'],
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
      children: [
        Icon(icon, size: 20, color: Color(0xFF008000)),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
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

  // Tambahkan method untuk menampilkan dialog edit dan delete
  void _showEditDialog(
      Map<String, dynamic> prescription, String prescriptionId) {
    _medicationController.text = prescription['medication'];
    _doseController.text = prescription['dose'];
    _instructionsController.text = prescription['instructions'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Prescription'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _medicationController,
                decoration: InputDecoration(
                  labelText: 'Medication',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _doseController,
                decoration: InputDecoration(
                  labelText: 'Dose',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _instructionsController,
                decoration: InputDecoration(
                  labelText: 'Instructions',
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
              _firestore
                  .collection('prescriptions')
                  .doc(prescriptionId)
                  .update({
                'medication': _medicationController.text,
                'dose': _doseController.text,
                'instructions': _instructionsController.text,
              });
              Navigator.pop(context);
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String prescriptionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Prescription'),
        content: Text('Are you sure you want to delete this prescription?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _firestore
                  .collection('prescriptions')
                  .doc(prescriptionId)
                  .delete();
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
