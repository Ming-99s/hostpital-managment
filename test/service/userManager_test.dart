import 'dart:io';
import 'package:test/test.dart';
import '../../hostpital-managment/lib/domain/Service/userManager.dart';
import '../../hostpital-managment/lib/data/Repository/User_file.dart';
import '../../hostpital-managment/lib/domain/patient.dart';
import '../../hostpital-managment/lib/domain/doctor.dart';

void main() {
  late File userFile;
  late UserRepository userRepository;
  late UserManager userManager;

  setUp(() {
    userFile = File('test/test_users.json');

    userRepository = UserRepository(userFile.path);
    userManager = UserManager(userRepository: userRepository);
  });



  group('UserManager Tests', () {
    test('Add and get patient', () {
      final patient = Patient(
        username: 'haha',
        password: '1234',
        age: 22,
        address: 'Phnom Penh',
        email: 'alice@example.com',
        gender: Gender.female,
      );
   
      if(userManager.isUsernameExists(patient.username)){
        return;
      }
      else{
        userManager.addUser(patient);
      }
      
      final namePatient = userManager.getPatientById(patient.id);
      expect(namePatient!.username, 'haha');
    });

    test('Add and get doctor', () {
      final doctor = Doctor(
        username: 'Dr. Bob',
        password: 'abcd',
        address: 'Siem Reap',
        email: 'bob@example.com',
        specialty: Specialty.cardiology,
        availableSlots: [],
      );
      if(userManager.isUsernameExists(doctor.username)){
        return;
      }
      else{
        userManager.addUser(doctor);
      }

      final docInfo = userManager.getDoctorById(doctor.id);

      expect(docInfo, isNotNull);
      expect(docInfo!.specialty, Specialty.cardiology);
    });



    test('Remove user', () {
      final patient = Patient(
        username: 'poppy',
        password: '1234',
        age: 22,
        address: 'Phnom Penh',
        email: 'alice@example.com',
        gender: Gender.female,
      );
      userManager.addUser(patient);
      userManager.removeUser(patient.id);

      final thisUser = userManager.getPatientById(patient.id);
      expect(thisUser, isNull);
    });

    test('Validate email format', () {
      expect(userManager.isValidEmail('valid@mail.com'), true);
      expect(userManager.isValidEmail('invalidemail'), false);
      expect(userManager.isValidEmail('another@domain'), false);
    });
  });
}
