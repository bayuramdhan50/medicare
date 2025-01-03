import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare/models/appointment_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save Appointment Data
  Future<void> saveAppointment(AppointmentModel appointment) async {
    try {
      await _db
          .collection('appointments')
          .doc(appointment.id)
          .set(appointment.toMap());
    } catch (e) {
      print('Error saving appointment: $e');
    }
  }

  // Get Appointment Data by Patient ID
  Stream<List<AppointmentModel>> getAppointmentsByPatient(String patientId) {
    return _db
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppointmentModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Get Appointment Data by Doctor ID
  Stream<List<AppointmentModel>> getAppointmentsByDoctor(String doctorId) {
    return _db
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppointmentModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Save User Data (Optional)
  Future<void> saveUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(userId).set(data);
    } catch (e) {
      print('Error saving user data: $e');
    }
  }
}
