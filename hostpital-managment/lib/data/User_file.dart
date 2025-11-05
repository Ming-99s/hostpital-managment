import 'dart:io';
import 'dart:convert';
import '../domain/user.dart';
import '../domain/patient.dart';
import '../domain/doctor.dart';
import '../domain/admin.dart';

class UserRepository {
  final String filePath;

  UserRepository(this.filePath);

  // -------------------- Read all users --------------------
  List<User> readUsers() {
    final file = File(filePath);

    if (!file.existsSync()) {
      // create empty file if not exist
      file.writeAsStringSync(jsonEncode({'users': []}));
      return [];
    }

    final content = file.readAsStringSync().trim();
    if (content.isEmpty) return [];

    final data = jsonDecode(content);
    final usersJson = data['users'] as List;

    return usersJson.map<User>((u) {
      final type = UserType.values.firstWhere(
        (t) => t.toString() == u['type'],
      );

      switch (type) {
        case UserType.patient:
          return Patient(
            id: u['id'],
            username: u['username'],
            password: u['password'],
            age: u['age'],
            address: u['address'],
            email: u['email'],
            gender: Gender.values.firstWhere(
              (g) => g.toString() == u['gender'],
            ),
          );
        case UserType.doctor:
          return Doctor(
            id: u['id'],
            username: u['username'],
            password: u['password'],
            address: u['address'],
            email: u['email'],
            specialty: Specialty.values.firstWhere(
              (s) => s.toString() == u['specialty'],
            ),
            availableSlots: (u['availableSlots'] as List)
                .map((s) => DateTime.parse(s))
                .toList(),
          );
        case UserType.admin:
          return Admin(
            id: u['id'],
            username: u['username'],
            password: u['password'],
          );
      }
    }).toList();
  }

  // -------------------- Write all users --------------------
    void writeUsers(List<User> users) {
    final file = File(filePath);
  
    // Only write non-doctor users to this file
    final nonDoctorUsers = users.where((u) => u.type != UserType.doctor).toList();

    final data = {
      'users': nonDoctorUsers.map((u) {
        final Map<String, dynamic> base = {
          'id': u.id,
          'username': u.username,
          'password': u.password,
          'type': u.type.toString(),
        };

        if (u is Patient) {
          base.addAll({
            'age': u.age,
            'address': u.address,
            'email': u.email,
            'gender': u.gender.toString(),
          });
        }
        // Admin has no extra fields

        return base;
      }).toList()
    };

    file.writeAsStringSync(JsonEncoder.withIndent('  ').convert(data));
  }

}

// -------------------- Doctor Repository (separate file) --------------------
class DoctorRepository {
  final String filePath;

  DoctorRepository(this.filePath);

  List<Doctor> readDoctors() {
    final file = File(filePath);

    if (!file.existsSync()) {
      file.writeAsStringSync(jsonEncode({'doctors': []}));
      return [];
    }

    final content = file.readAsStringSync().trim();
    if (content.isEmpty) return [];

    final data = jsonDecode(content);
    final doctorsJson = (data['doctors'] as List? ?? []);

    return doctorsJson.map<Doctor>((u) {
      return Doctor(
        id: u['id'],
        username: u['username'],
        password: u['password'],
        address: u['address'],
        email: u['email'],
        specialty: Specialty.values.firstWhere(
          (s) => s.toString() == u['specialty'],
        ),
        availableSlots: (u['availableSlots'] as List)
            .map((s) => DateTime.parse(s))
            .toList(),
      );
    }).toList();
  }

  void writeDoctors(List<Doctor> doctors) {
    final file = File(filePath);
    final data = {
      'doctors': doctors.map((d) {
        return {
          'id': d.id,
          'username': d.username,
          'password': d.password,
          'address': d.address,
          'email': d.email,
          'specialty': d.specialty.toString(),
          'availableSlots': d.availableSlots.map((s) => s.toIso8601String()).toList(),
          'type': UserType.doctor.toString(),
        };
      }).toList()
    };

    file.writeAsStringSync(JsonEncoder.withIndent('  ').convert(data));
  }
}
