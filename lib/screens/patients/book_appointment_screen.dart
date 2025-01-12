import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare/models/user_model.dart';
import 'package:intl/intl.dart';

class BookAppointmentScreen extends StatefulWidget {
  final UserModel user;

  BookAppointmentScreen({required this.user});

  @override
  _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedDoctorName; // Displayed name of the doctor
  String? selectedDoctorUid; // UID of the selected doctor
  DateTime? selectedDateTime;
  List<Map<String, String>> doctors =
      []; // List to store doctor UID and name pairs

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  // Fungsi untuk mengambil daftar dokter dari Firestore
  Future<void> _loadDoctors() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .get();

      List<Map<String, String>> loadedDoctors = []; // Updated to a list of maps
      snapshot.docs.forEach((doc) {
        loadedDoctors.add({
          'name': doc['name'], // Store doctor name
          'uid': doc['uid'], // Store doctor UID
        });
      });

      setState(() {
        doctors = loadedDoctors; // Assign the list of maps
      });
    } catch (e) {
      print("Error loading doctors: $e");
    }
  }

  // Function to select date and time for the appointment
  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDateTime) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(picked),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  // Function to book the appointment
  Future<void> _bookAppointment() async {
    if (selectedDoctorUid == null || selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select doctor and date/time.')),
      );
      return;
    }

    // Format the selected date and time
    String formattedDate =
        "${selectedDateTime!.year}-${selectedDateTime!.month.toString().padLeft(2, '0')}-${selectedDateTime!.day.toString().padLeft(2, '0')}";
    String formattedTime =
        "${selectedDateTime!.hour > 12 ? selectedDateTime!.hour - 12 : selectedDateTime!.hour}:${selectedDateTime!.minute.toString().padLeft(2, '0')} ${selectedDateTime!.hour >= 12 ? 'PM' : 'AM'}";

    try {
      await _firestore.collection('appointments').add({
        'patientId': widget.user.uid,
        'doctorUid': selectedDoctorUid, // Store the doctor's UID
        'doctor': selectedDoctorName, // Store the doctor's name
        'date': formattedDate,
        'time': formattedTime,
        'status': 'Pending',
      });

      // Tambahkan notifikasi untuk pasien
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': widget.user.uid,
        'title': 'Appointment Berhasil Dibuat',
        'body':
            'Anda telah membuat janji dengan ${selectedDoctorName} pada ${DateFormat('dd/MM/yyyy').format(selectedDateTime!)} jam ${formattedTime}',
        'timestamp': Timestamp.fromDate(selectedDateTime!),
        'isRead': false,
      });

      // Tambahkan notifikasi untuk dokter
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': selectedDoctorUid,
        'title': 'Appointment Baru',
        'body':
            'Pasien ${widget.user.name} membuat janji pada ${DateFormat('dd/MM/yyyy').format(selectedDateTime!)} jam ${formattedTime}',
        'timestamp': Timestamp.fromDate(selectedDateTime!),
        'isRead': false,
      });

      print('Notifikasi berhasil dibuat untuk pasien dan dokter');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment booked successfully!')),
      );

      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      print('Error creating appointment and notifications: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat appointment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade100,
                    Colors.white,
                  ],
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
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          'Book Appointment',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Content
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: 100),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Doctor selection card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.medical_services,
                                      color: Colors.blue),
                                  SizedBox(width: 10),
                                  Text(
                                    'Select Doctor',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              doctors.isEmpty
                                  ? Center(child: CircularProgressIndicator())
                                  : Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 12),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: selectedDoctorName,
                                          hint: Text('Choose your doctor'),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedDoctorName = newValue;
                                              selectedDoctorUid =
                                                  doctors.firstWhere((doctor) =>
                                                      doctor['name'] ==
                                                      newValue)['uid'];
                                            });
                                          },
                                          items: doctors
                                              .map<DropdownMenuItem<String>>(
                                                  (doctor) {
                                            return DropdownMenuItem<String>(
                                              value: doctor['name'],
                                              child: Text(doctor['name'] ??
                                                  'Unknown Doctor'),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Date & Time selection card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: Colors.blue),
                                  SizedBox(width: 10),
                                  Text(
                                    'Select Date & Time',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              Container(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.access_time),
                                  label: Text(
                                    selectedDateTime == null
                                        ? 'Pick Date and Time'
                                        : '${selectedDateTime!.toLocal().toString().split('.')[0]}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () => _selectDateTime(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 30),

                      // Book button
                      Container(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _bookAppointment,
                          child: Text(
                            'Book Appointment',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tambahkan class WaveClipper untuk membuat efek wave pada header
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
