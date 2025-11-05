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

  // -------------------- Book Appointment --------------------
  Appointment? bookAppointment(String patientId, String doctorId, DateTime date) {
    final patient = _users.firstWhere((u) => u.id == patientId && u.type == UserType.patient);
    final doctor = _users.firstWhere((u) => u.id == doctorId && u.type == UserType.doctor) as Doctor;

    // Check if slot is available
    if (!doctor.availableSlots.contains(date)) {
      print('❌ Selected slot is not available.');
      return null;
    }

    final appointmentId = Uuid().v4();

    final newAppointment = Appointment(
      appointmentId: appointmentId,
      patientId: patient.id,
      doctorId: doctor.id,
      dateTime: date,
      appointmentStatus: AppointmentStatus.pending,
    );

    _appointments.add(newAppointment);
    print('✅ Appointment booked (Pending) for ${formatDateTime(date)}');
    return newAppointment;
  }

  // -------------------- Approve Appointment --------------------
  void approveAppointment(String appointmentId) {
    final appt = _appointments.firstWhere((a) => a.appointmentId == appointmentId);

    if (appt.appointmentStatus != AppointmentStatus.pending) {
      print('❌ Only pending appointments can be approved.');
      return;
    }

    final doctor = _users.firstWhere((u) => u.id == appt.doctorId && u.type == UserType.doctor) as Doctor;

    // Remove slot from doctor's availableSlots
    doctor.availableSlots.remove(appt.dateTime);

    appt.appointmentStatus = AppointmentStatus.approved;
    print('✅ Appointment approved for ${formatDateTime(appt.dateTime)}');
  }

  

  // -------------------- Helper --------------------
  String formatDateTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final date = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    return '$date $hour:$minute $ampm';
  }
}
