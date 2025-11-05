import 'dart:io';
import '../domain/user.dart';
import '../domain/patient.dart';
import '../domain/doctor.dart';
import '../domain/authService.dart';
import 'adminDashboard.dart';
import 'patientDashboard.dart';
import 'doctorDashboard.dart';

class Auth {
  final AuthService authService;
  Auth({required this.authService});

  void start() {
    print('Welcome to the System!');

    while (true) {
      print('\nChoose an option:');
      print('1. Register');
      print('2. Login');
      print('3. Exit');

      stdout.write('> ');
      final choice = stdin.readLineSync();

      if (choice == '1') {
        // Register
        stdout.write('Register as Patient or Doctor? (p/d): ');
        final typeInput = stdin.readLineSync()!;
        final type =
            typeInput.toLowerCase() == 'p' ? UserType.patient : UserType.doctor;

        stdout.write('Username: ');
        final username = stdin.readLineSync()!;
        stdout.write('Password: ');
        final password = stdin.readLineSync()!;
        stdout.write('Email: ');
        final email = stdin.readLineSync()!;
        stdout.write('Address: ');
        final address = stdin.readLineSync()!;

        try {
          if (type == UserType.patient) {
            stdout.write('Age: ');
            final age = int.parse(stdin.readLineSync()!);

            stdout.write('Gender (male/female): ');
            final genderStr = stdin.readLineSync()!;
            final gender = Gender.values
                .firstWhere((g) => g.toString() == 'Gender.' + genderStr);

            final patient = authService.register(
              type: type,
              username: username,
              password: password,
              email: email,
              address: address,
              age: age,
              gender: gender,
            );
            print('✅ Patient registered successfully! ID: ${patient.id}');
          } else {
            stdout.write(
                'Specialty (e.g., generalPractice, cardiology, neurology): ');
            final specialtyStr = stdin.readLineSync()!;
            final specialty = Specialty.values
                .firstWhere((s) => s.toString() == 'Specialty.' + specialtyStr);

            final doctor = authService.register(
              type: type,
              username: username,
              password: password,
              email: email,
              address: address,
              specialty: specialty,
            );
            print('✅ Doctor registered successfully! ID: ${doctor.id}');
          }
        } catch (e) {
          print('❌ ${e.toString()}');
        }
      } else if (choice == '2') {
        // Login (auto detect type)
        stdout.write('Username: ');
        final username = stdin.readLineSync()!;
        stdout.write('Password: ');
        final password = stdin.readLineSync()!;

        try {
          // Find user by username
          final user = authService.allUsers
              .firstWhere((u) => u.username == username); // no orElse

          if (user.login(username, password)) {
            if (user.type == UserType.patient) {
              print('✅ Logged in as Patient! Welcome, ${user.username}');
              PatientDashboard(authService.appointmentManager)
                  .startPatientDashboard(user);
            } else if (user.type == UserType.doctor) {
              print('✅ Logged in as Doctor! Welcome, ${user.username}');
              DoctorDashboard(authService.appointmentManager)
                  .startDoctorDashboard(user);
            } else if (user.type == UserType.admin) {
              print('✅ Logged in as Admin! Welcome, ${user.username}');
              AdminDashboard(authService.appointmentManager)
                  .startAdminDashboard(user);
            }
          } else {
            print('❌ Invalid password!');
          }
        } catch (e) {
          print('❌ Username not found!');
        }
      } else if (choice == '3') {
        print('Goodbye!');
        break;
      } else {
        print('Invalid choice!');
      }
    }
  }
}
