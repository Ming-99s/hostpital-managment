import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';

import '../../hostpital-managment/lib/data/Repository/User_file.dart';
import '../../hostpital-managment/lib/data/Repository/appointments_file.dart';
import '../../hostpital-managment/lib/domain/Service/userManager.dart';
import '../../hostpital-managment/lib/domain/Service/appointmentManager.dart';
import '../../hostpital-managment/lib/domain/Service/authService.dart';
import '../../hostpital-managment/lib/domain/patient.dart';
import '../../hostpital-managment/lib/domain/user.dart';

void main() {
  late File tmpUserFile;
  late UserRepository userRepo;
  late UserManager userManager;
  late AppointmentRepository appointmentRepo;
  late AppointmentManager appointmentManager;
  late AuthService authService;

  setUp(() {
    // Create a temp copy of the users fixture so tests don’t affect shared data
    final fixture = File('test/test_users.json');
    tmpUserFile = File('test/tmp_user_repo_login.json');
    tmpUserFile.writeAsStringSync(fixture.readAsStringSync());

    userRepo = UserRepository(tmpUserFile.path);
    userManager = UserManager(userRepository: userRepo);

    // Appointment data is not modified in these tests; use the shared fixture
    appointmentRepo = AppointmentRepository('test/test_appointments.json');
    appointmentManager = AppointmentManager(appointmentRepo, userManager);
    authService = AuthService(userManager: userManager, appointmentManager: appointmentManager);
  });

  tearDown(() {
    if (tmpUserFile.existsSync()) {
      tmpUserFile.deleteSync();
    }
  });

  group('UserRepository login and JSON persistence', () {
    test('Login succeeds with valid credentials', () {
      final user = authService.login('dr_one', 'onepass');
      expect(user, isNotNull);
      expect(user!.username, equals('dr_one'));
      expect(user.type, equals(UserType.doctor));
    });

    test('Saving users persists to JSON and reads back correctly', () {
      // Arrange: read existing users, append a new patient
      final initialUsers = userRepo.readUsers();
      final newPatient = Patient(
        username: 'json_patient',
        password: 'p@ss',
        age: 22,
        address: 'Phnom Penh',
        email: 'json_patient@example.com',
        gender: Gender.female,
      );

      final updated = List<User>.from(initialUsers)..add(newPatient);

      // Act: write to JSON and read back
      userRepo.writeUsers(updated);
      final reloaded = userRepo.readUsers();

      // Assert: object reconstruction matches expected fields
      final loadedPatient = reloaded.where((u) => u is Patient && u.username == 'json_patient').cast<Patient>().firstOrNull;
      expect(loadedPatient, isNotNull);
      expect(loadedPatient!.age, equals(22));
      expect(loadedPatient.address, equals('Phnom Penh'));
      expect(loadedPatient.email, equals('json_patient@example.com'));
      expect(loadedPatient.gender, equals(Gender.female));
      expect(loadedPatient.type, equals(UserType.patient));

      // Bonus: verify raw JSON structure contains expected keys/types
      final content = File(tmpUserFile.path).readAsStringSync();
      final data = jsonDecode(content) as Map<String, dynamic>;
      final usersJson = (data['users'] as List).cast<Map<String, dynamic>>();
      final jsonPatient = usersJson.firstWhere((u) => u['username'] == 'json_patient');
      expect(jsonPatient['type'], equals('UserType.patient'));
      expect(jsonPatient['age'], equals(22));
      expect(jsonPatient['address'], equals('Phnom Penh'));
      expect(jsonPatient['email'], equals('json_patient@example.com'));
      expect(jsonPatient['gender'], equals('Gender.female'));
    });
  });
}

extension FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => this.isEmpty ? null : this.first;
}