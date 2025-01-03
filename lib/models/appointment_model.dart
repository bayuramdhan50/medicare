// appointment_model.dart
class AppointmentModel {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime appointmentDate;
  final String status; // E.g., "Pending", "Confirmed", "Completed", "Cancelled"
  final String notes; // Any additional notes from the doctor or patient

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentDate,
    required this.status,
    required this.notes,
  });

  // Convert AppointmentModel to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'appointmentDate': appointmentDate.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }

  // Convert Map to AppointmentModel
  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      appointmentDate: DateTime.parse(map['appointmentDate'] ?? ''),
      status: map['status'] ?? 'Pending',
      notes: map['notes'] ?? '',
    );
  }
}
