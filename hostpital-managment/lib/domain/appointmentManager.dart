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


}
