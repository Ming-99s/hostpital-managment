import 'package:uuid/uuid.dart';

enum AppointmentStatus { pending, reject, approved, canceled }

// Appointment class
class Appointment {
  final String appointmentId;
  final String patientId;
  final String doctorId;
  DateTime dateTime;
  AppointmentStatus appointmentStatus;

  Appointment({
    String? appointmentId, // optional: allows reuse when loading from DB
    required this.patientId,
    required this.doctorId,
    required this.dateTime,
    required this.appointmentStatus,
  }) : appointmentId = appointmentId ?? Uuid().v4();

  @override
  String toString() {
    return 'Appointment(id: $appointmentId, patientId: $patientId, doctorId: $doctorId, dateTime: $dateTime, status: $appointmentStatus)';
  }
}
