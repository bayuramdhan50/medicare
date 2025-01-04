import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare/models/user_model.dart';

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment booked successfully!')),
      );

      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book appointment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Appointment'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Select a Doctor',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // If the doctors list is still empty, show a loading indicator
            doctors.isEmpty
                ? CircularProgressIndicator()
                : DropdownButton<String>(
                    value: selectedDoctorName,
                    hint: Text('Select Doctor'),
                    onChanged: (String? newValue) {
                      setState(() {
                        // Find the UID of the selected doctor
                        selectedDoctorName = newValue;
                        selectedDoctorUid = doctors.firstWhere(
                            (doctor) => doctor['name'] == newValue)['uid'];
                      });
                    },
                    items: doctors.map<DropdownMenuItem<String>>((doctor) {
                      return DropdownMenuItem<String>(
                        value: doctor['name'],
                        child: Text(doctor['name'] ?? 'Unknown Doctor'),
                      );
                    }).toList(),
                  ),
            SizedBox(height: 20),
            Text(
              'Select Appointment Date and Time',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () => _selectDateTime(context),
              child: Text(
                selectedDateTime == null
                    ? 'Pick Date and Time'
                    : '${selectedDateTime!.toLocal()}',
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _bookAppointment,
              child: Text('Book Appointment'),
            ),
          ],
        ),
      ),
    );
  }
}
