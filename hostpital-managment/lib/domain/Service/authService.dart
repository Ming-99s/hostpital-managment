import '../user.dart';
import '../patient.dart';
import '../doctor.dart';
import '../Service/appointmentManager.dart';
class AuthService {
  late List<User> _users;
  late AppointmentManager appointmentManager;

  AuthService({required List<User> users, required this.appointmentManager}) {
    _users = users;
  }

  // -------------------- Unified Register --------------------
  User register({
    required UserType type,
    required String username,
    required String password,
    String? email,
    String? address,
    int? age,
    Gender? gender,
    Specialty? specialty,
  }) {
    // Check if username already exists
    if (_users.any((u) => u.username == username)) {
      throw Exception('Username already exists!');
    }

    late User newUser;

    if (type == UserType.patient) {
      if (age == null || gender == null || email == null || address == null) {
        throw Exception('Missing required fields for patient.');
      }
      newUser = Patient(
        username: username,
        password: password,
        age: age,
        address: address,
        email: email,
        gender: gender,
      );
    } else if (type == UserType.doctor) {
      if (email == null || address == null || specialty == null) {
        throw Exception('Missing required fields for doctor.');
      }
      newUser = Doctor(
        username: username,
        password: password,
        email: email,
        address: address,
        specialty: specialty,
        availableSlots: [],
      );
    } else {
      throw Exception('Cannot register admin manually.');
    }

    _users.add(newUser);
    return newUser;
  }

  // -------------------- Login --------------------
  User login({required String username, required String password}) {
    final user = _users.firstWhere((u) => u.username == username); // no orElse

    if (!user.login(username, password)) {
      throw Exception('Invalid password!');
    }

    return user;
  }

  // -------------------- Helpers --------------------
  List<User> get allUsers => _users;

  List<User> getPatients() =>
      _users.where((u) => u.type == UserType.patient).toList();

  List<User> getDoctors() =>
      _users.where((u) => u.type == UserType.doctor).toList();

  User getAdmin() =>
      _users.firstWhere((u) => u.type == UserType.admin); // no orElse
}