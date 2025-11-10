import 'dart:io';
import 'dart:convert';
import '../../domain/user.dart';
import '../../domain/patient.dart';
import '../../domain/doctor.dart';
import '../../domain/admin.dart';

class UserRepository {
  final String filePath;

  UserRepository(this.filePath);

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

    void writeUsers(List<User> users) {
    final file = File(filePath);
  
    final data = {
      'users': users.map((u) {
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
        } else if (u is Doctor) {
          base.addAll({
            'address': u.address,
            'email': u.email,
            'specialty': u.specialty.toString(),
            'availableSlots': u.availableSlots
                .map((s) => s.toIso8601String())
                .toList(),
          });
        }
  
        return base;
      }).toList()
    };
  
    file.writeAsStringSync(JsonEncoder.withIndent('  ').convert(data));
  }

}
