import 'dart:io';
import '../domain/Service/appointmentManager.dart';
import '../domain/patient.dart';
import '../domain/doctor.dart';
import '../domain/Service/authService.dart';
import '../domain/user.dart';
import 'adminDashboard.dart';
import 'doctorDashboard.dart';
import 'patientDashboard.dart';

class AuthUI {
  final AuthService authService;
  final AppointmentManager appointmentManager;

  AuthUI({required this.authService , required this.appointmentManager});

  void startAuthUI() {
    while (true) {
      print('\n====================================');
      print('   🏥 HOSPITAL MANAGEMENT SYSTEM');
      print('====================================');
      print('1. 🔐 Login');
      print('2. 📝 Register as Patient');
      print('3. 👨‍⚕️ Register as Doctor');
      print('4. 🚪 Exit');
      print('------------------------------------');
      stdout.write('Enter your choice: ');
      final String? choice = stdin.readLineSync();

      switch (choice) {
        case '1':
          _handleLogin();
          break;
        case '2':
          _handlePatientRegistration();
          break;
        case '3':
          _handleDoctorRegistration();
          break;
        case '4':
          print('\n👋 Thank you for using our service. Goodbye!');
          return;
        default:
          print('❌ Invalid choice. Please try again.');
      }
    }
  }

  void _handleLogin() {
    print('\n====================================');
    print('   🔐 LOGIN');
    print('====================================');

    stdout.write('Username: ');
    final String? username = stdin.readLineSync()?.trim();

    stdout.write('Password: ');
    final String? password = stdin.readLineSync()?.trim();

    if (username == null || username.isEmpty || password == null || password.isEmpty) {
      print('❌ Username and password are required.');
      return;
    }

    try {
      final User? user = authService.login(username, password);
      
      if (user != null) {
        print('\n✅ Login successful!');
        print('Welcome, ${user.username.toUpperCase()}!');
        print('User Type: ${_getUserTypeString(user.type)}');
        
        _redirectToDashboard(user);
      } else {
        print('❌ Invalid username or password.');
      }
    } catch (e) {
      print('❌ Login failed: $e');
    }
  }

  void _handlePatientRegistration() {
    print('\n====================================');
    print('   📝 PATIENT REGISTRATION');
    print('====================================');

    // Get username
    stdout.write('Username: ');
    final String? username = stdin.readLineSync()?.trim();
    if (username == null || username.isEmpty) {
      print('❌ Username is required.');
      return;
    }

    // Check if username is available
    if (!authService.isUsernameAvailable(username)) {
      print('❌ Username already exists. Please choose another one.');
      return;
    }

    // Get password
    stdout.write('Password: ');
    final String? password = stdin.readLineSync()?.trim();
    if (password == null || password.isEmpty) {
      print('❌ Password is required.');
      return;
    }

    // Get email
    stdout.write('Email: ');
    final String? email = stdin.readLineSync()?.trim();
    if (email == null || email.isEmpty) {
      print('❌ Email is required.');
      return;
    }

    // Get age
    stdout.write('Age: ');
    final String? ageInput = stdin.readLineSync()?.trim();
    final int? age = int.tryParse(ageInput ?? '');
    if (age == null || age <= 0) {
      print('❌ Valid age is required.');
      return;
    }

    // Get address
    stdout.write('Address: ');
    final String? address = stdin.readLineSync()?.trim();
    if (address == null || address.isEmpty) {
      print('❌ Address is required.');
      return;
    }

    // Get gender
    print('\nSelect Gender:');
    print('1. Male');
    print('2. Female');
    stdout.write('Enter choice (1-2): ');
    final String? genderChoice = stdin.readLineSync()?.trim();
    
    Gender gender;
    switch (genderChoice) {
      case '1':
        gender = Gender.male;
        break;
      case '2':
        gender = Gender.female;
        break;

      default:
        print('❌ Invalid gender selection.');
        return;
    }

    // Confirm registration
    print('\n📋 REGISTRATION SUMMARY:');
    print('------------------------------------');
    print('Username: $username');
    print('Email: $email');
    print('Age: $age');
    print('Address: $address');
    print('Gender: ${_getGenderString(gender)}');
    print('------------------------------------');
    
    stdout.write('Confirm registration? (y/n): ');
    final String? confirmation = stdin.readLineSync()?.toLowerCase();

    if (confirmation == 'y' || confirmation == 'yes') {
      try {
        final User? newPatient = authService.registerPatient(
          username, password, email, age, address, gender
        );
        
        if (newPatient != null) {
          print('\n✅ Patient registration successful!');
          print('You can now login with your credentials.');
        }
      } catch (e) {
        print('❌ Registration failed: $e');
      }
    } else {
      print('❌ Registration cancelled.');
    }
  }

  void _handleDoctorRegistration() {
    print('\n====================================');
    print('   👨‍⚕️ DOCTOR REGISTRATION');
    print('====================================');

    // Get username
    stdout.write('Username: ');
    final String? username = stdin.readLineSync()?.trim();
    if (username == null || username.isEmpty) {
      print('❌ Username is required.');
      return;
    }

    // Check if username is available
    if (!authService.isUsernameAvailable(username)) {
      print('❌ Username already exists. Please choose another one.');
      return;
    }

    // Get password
    stdout.write('Password: ');
    final String? password = stdin.readLineSync()?.trim();
    if (password == null || password.isEmpty) {
      print('❌ Password is required.');
      return;
    }

    // Get email
    stdout.write('Email: ');
    final String? email = stdin.readLineSync()?.trim();
    if (email == null || email.isEmpty) {
      print('❌ Email is required.');
      return;
    }

    // Get address
    stdout.write('Address: ');
    final String? address = stdin.readLineSync()?.trim();
    if (address == null || address.isEmpty) {
      print('❌ Address is required.');
      return;
    }

    // Get specialty
    print('\nSelect Specialty:');
    print('1. General Practice');
    print('2. Pediatrics');
    print('3. Cardiology');
    print('4. Dermatology');
    print('5. Neurology');
    print('6. Orthopedics');
    print('7. Psychiatry');
    print('8. Surgery');
    print('9. Obstetrics & Gynecology');
    stdout.write('Enter choice (1-9): ');
    final String? specialtyChoice = stdin.readLineSync()?.trim();
    
    Specialty specialty;
    switch (specialtyChoice) {
      case '1': specialty = Specialty.generalPractice; break;
      case '2': specialty = Specialty.pediatrics; break;
      case '3': specialty = Specialty.cardiology; break;
      case '4': specialty = Specialty.dermatology; break;
      case '5': specialty = Specialty.neurology; break;
      case '6': specialty = Specialty.orthopedics; break;
      case '7': specialty = Specialty.psychiatry; break;
      case '8': specialty = Specialty.surgery; break;
      case '9': specialty = Specialty.obstetricsGynecology; break;
      default:
        print('❌ Invalid specialty selection.');
        return;
    }

    // Initialize with empty available slots
    final List<DateTime> availableSlots = [];

    // Confirm registration
    print('\n📋 REGISTRATION SUMMARY:');
    print('------------------------------------');
    print('Username: $username');
    print('Email: $email');
    print('Address: $address');
    print('Specialty: ${authService.userManager.formatSpecialty(specialty)}');
    print('Available Slots: ${availableSlots.length} (can be added later)');
    print('------------------------------------');
    
    stdout.write('Confirm registration? (y/n): ');
    final String? confirmation = stdin.readLineSync()?.toLowerCase();

    if (confirmation == 'y' || confirmation == 'yes') {
      try {
        final User? newDoctor = authService.registerDoctor(
          username, password, email, specialty, availableSlots, address
        );
        
        if (newDoctor != null) {
          print('\n✅ Doctor registration successful!');
          print('You can now login with your credentials.');
        }
      } catch (e) {
        print('❌ Registration failed: $e');
      }
    } else {
      print('❌ Registration cancelled.');
    }
  }

  void _redirectToDashboard(User user) {

    print('\n🎯 Redirecting to ${_getUserTypeString(user.type)} Dashboard...');
    
    switch (user.type) {
      case UserType.admin:
        AdminDashboard adminDashboard = AdminDashboard(appointmentManager, authService.userManager);
        adminDashboard.startAdminDashboard(user);
        break;
      case UserType.doctor:
        DoctorDashboard doctorDashboard = DoctorDashboard(appointmentManager, authService.userManager);
        doctorDashboard.startDoctorDashboard(user);
        break;
      case UserType.patient:
        PatientDashboard patientDashboard = PatientDashboard(appointmentManager, authService.userManager);
        patientDashboard.startPatientDashboard(user);
        break;
    }
  }

  String _getUserTypeString(UserType type) {
    switch (type) {
      case UserType.admin: return 'Admin';
      case UserType.doctor: return 'Doctor';
      case UserType.patient: return 'Patient';
    }
  }

  String _getGenderString(Gender gender) {
    switch (gender) {
      case Gender.male: return 'Male';
      case Gender.female: return 'Female';
    }
  }
}