import 'package:uuid/uuid.dart';
import 'appointment.dart';
import 'user.dart';
import 'doctor.dart';

class AppointmentManager {
  late List<User> _users;
  late List<Appointment> _appointments;

  AppointmentManager({
    required List<User> users,
    required List<Appointment> appointments,
  }) {
    _users = users;
    _appointments = appointments;
  }

  // -------------------- Getters --------------------
  List<User> get allUsers => _users;
  List<Appointment> get allAppointments => _appointments;

  List<User> get allDoctors =>
      _users.where((u) => u.type == UserType.doctor).toList();

  List<User> get allPatients =>
      _users.where((u) => u.type == UserType.patient).toList();

  // -------------------- Methods --------------------
  /// Books an appointment for a patient with a doctor at a specific slot
  /// Returns the created appointment if successful, null if slot not available
  Appointment? bookAppointment(
      String patientId, String doctorId, DateTime slot) {
    // Find the doctor
    final doctorUser = _users.firstWhere(
      (u) => u.id == doctorId && u.type == UserType.doctor,
      orElse: () =>
          User(id: '', username: '', password: '', type: UserType.admin),
    );

    if (doctorUser.id.isEmpty) {
      return null; // Doctor not found
    }

    // Cast to Doctor to access availableSlots
    final doctor = doctorUser as Doctor;

    // Check if slot is available
    if (!doctor.availableSlots.contains(slot)) {
      return null; // Slot not available
    }

    // Create new appointment with pending status
    final newAppointment = Appointment(
      patientId: patientId,
      doctorId: doctorId,
      dateTime: slot,
      appointmentStatus: AppointmentStatus.pending,
    );

    // Remove the slot from doctor's available slots
    doctor.availableSlots.remove(slot);

    // Add to appointments list
    _appointments.add(newAppointment);

    return newAppointment;
  }
}
