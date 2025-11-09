import 'dart:io';
import 'package:test/test.dart';
import '../../hostpital-managment/lib/data/Repository/User_file.dart';
import '../../hostpital-managment/lib/domain/Service/userManager.dart';
import '../../hostpital-managment/lib/domain/Service/authService.dart';
import '../../hostpital-managment/lib/domain/user.dart';
import '../../hostpital-managment/lib/domain/doctor.dart';
import '../../hostpital-managment/lib/domain/patient.dart';



void main() {
  late File userFile;
  late UserRepository userRepo;
  late UserManager userManager;
  late AuthService authService;

  setUp(() {
    userFile = File('test/test_users.json');

    userRepo = UserRepository(userFile.path);

    userManager = UserManager(userRepository: userRepo);

    authService = AuthService(userManager: userManager);
    

  });

  group('AuthService - Core Registration and Login', () {

    // --- Register Patient Tests ---
    test('should successfully register a new patient', () {
      final patient = authService.registerPatient(
        'testpatient',
        'securepass123',
        'support%team@data.io',
        30,
        '123 Main St',
        Gender.female,
      );

      expect(patient, isNotNull);
      expect(patient!.type, UserType.patient); 
      expect(patient.username, 'testpatient');
      authService.userManager.removeUser(patient.id);

    });

    test('registering patient with existing username will throw Exception', () {
      final patient = authService.registerPatient(
        'userA', 'pass', 'a@mail.com', 25, 'Addr', Gender.male,
      );

      
      expect(
        () => authService.registerPatient(
          'userA', 'pass2', 'b@mail.com', 30, 'Addr2', Gender.female,
        ),
        // Check that an Exception is thrown
        throwsA(isA<Exception>()),

      );
      authService.userManager.removeUser(patient!.id);
    });

    // --- Register Doctor Tests ---
    test('should successfully register a new doctor', () {
      final doctor = authService.registerDoctor(
        'drsmith',
        'docpass456',
        'doctor@example.com',
        Specialty.cardiology,
        [DateTime.now()],
        '456 Hospital Blvd',
      );

      expect(doctor, isNotNull);
      // Check if the returned object is a Doctor
      expect(doctor!.type,UserType.doctor);
      expect(doctor.username, 'drsmith');
      authService.userManager.removeUser(doctor.id);
    });
    
    test('should throw exception when registering doctor with existing username', () {
      final doctor = authService.registerDoctor(
        'docB', 'pass', 'b@mail.com', Specialty.pediatrics, [], 'Addr',
      );
      
      expect(
        () => authService.registerDoctor(
          'docB', 'pass2', 'c@mail.com', Specialty.neurology, [], 'Addr2',
        ),
        // Check that an Exception is thrown
        throwsA(isA<Exception>()),
      );
      authService.userManager.removeUser(doctor!.id);

    });

    // --- Login Tests ---
    test('should successfully log in with correct credentials', () {
      const String username = 'loginuser';
      const String password = 'loginpass';
      
      // Setup: Register a user first
      final patient = authService.registerPatient(
        username,
        password,
        'login@example.com',
        40,
        'Login Address',
        Gender.male,
      );

      final user = authService.login(username, password);
      
      expect(user, isNotNull);
      expect(user!.username, username);
      expect(user.type, UserType.patient);

      authService.userManager.removeUser(patient!.id);
    });

    test('should return null for incorrect login credentials', () {
      // Setup: Register a user
      final patient = authService.registerPatient(
        'correctuser', 'correctpass', 'a@b.com', 30, 'Addr', Gender.male,
      );
      
      expect(authService.login('correctuser', 'wrongpass'), isNull);
      
      expect(authService.login('unknownuser', 'correctpass'), isNull);

      authService.userManager.removeUser(patient!.id);

    });
    
  });
}





  

