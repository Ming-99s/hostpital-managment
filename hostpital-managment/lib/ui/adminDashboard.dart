import 'dart:io';
import '../domain/user.dart';
import '../domain/patient.dart';
import '../domain/doctor.dart';
import '../domain/appointment.dart';
import '../domain/appointmentManager.dart';

class AdminDashboard {
  final AppointmentManager appointmentManager;

  AdminDashboard(this.appointmentManager);

  void startAdminDashboard(User admin) {
    if (admin.type != UserType.admin) {
      print('❌ Only admins can access this dashboard.');
      return;
    }

    while (true) {
      print('\n====================================');
      print('   ADMIN DASHBOARD');
      print('   Welcome, ${admin.username.toUpperCase()}');
      print('====================================');
      print('1. 👥 Manage Users');
      print('2. 📅 Manage Appointments');
      print('3. 🚪 Logout');
      print('------------------------------------');
      stdout.write('Enter your choice: ');
      final String? choice = stdin.readLineSync();

      switch (choice) {
        case '1':
          _manageUsers(admin);
          break;
        case '2':
          _manageAppointments();
          break;
        case '3':
          print('\n👋 Logging out. Goodbye!');
          return;
        default:
          print('❌ Invalid choice. Please try again.');
      }
    }
  }

  void _manageUsers(User currentAdmin) {
    while (true) {
      print('\n👥 === USER MANAGEMENT ===');
      print('1. 👀 View All Users');
      print('2. ➕ Add Patient');
      print('3. ➕ Add Doctor');
      print('4. 🗑️ Remove User');
      print('5. ↩️ Back to Main Menu');
      print('------------------------------------');
      stdout.write('Enter your choice: ');
      final String? choice = stdin.readLineSync();

      switch (choice) {
        case '1':
          _viewAllUsers(currentAdmin);
          break;
        case '2':
          _addPatient();
          break;
        case '3':
          _addDoctor();
          break;
        case '4':
          _removeUser(currentAdmin);
          break;
        case '5':
          return;
        default:
          print('❌ Invalid choice. Please try again.');
      }
    }
  }

  void _viewAllUsers(User currentAdmin) {
    final users = appointmentManager.allUsers;
    
    print('\n👀 === ALL USERS ===');
    
    // Show current admin first
    print('\n⚙️ CURRENT ADMIN:');
    print('   Username: ${currentAdmin.username}');
    print('   ID: ${currentAdmin.id}');
    print('   Type: ${currentAdmin.type.name}');
    print('   Registered: ${_formatDate(currentAdmin.registerDate)}');
    print('   ---');
    
    final patients = users.whereType<Patient>().toList();
    final doctors = users.whereType<Doctor>().toList();
    
    if (patients.isNotEmpty) {
      print('\n😷 PATIENTS:');
      for (var i = 0; i < patients.length; i++) {
        final patient = patients[i];
        print('${i + 1}. ${patient.username}');
        print('   ID: ${patient.id}');
        print('   Age: ${patient.age} | Gender: ${patient.gender.name}');
        print('   Email: ${patient.email}');
        print('   Address: ${patient.address}');
        print('   Registered: ${_formatDate(patient.registerDate)}');
        print('   ---');
      }
    }

    if (doctors.isNotEmpty) {
      print('\n👨‍⚕️ DOCTORS:');
      for (var i = 0; i < doctors.length; i++) {
        final doctor = doctors[i];
        print('${i + 1}. Dr. ${doctor.username}');
        print('   ID: ${doctor.id}');
        print('   Specialty: ${_formatSpecialty(doctor.specialty)}');
        print('   Email: ${doctor.email}');
        print('   Address: ${doctor.address}');
        print('   Available Slots: ${doctor.availableSlots.length}');
        print('   Registered: ${_formatDate(doctor.registerDate)}');
        print('   ---');
      }
    }

    if (patients.isEmpty && doctors.isEmpty) {
      print('📭 No other users found.');
    }
    
    _pressEnterToContinue();
  }

  void _addPatient() {
    print('\n😷 === ADD NEW PATIENT ===');
    
    stdout.write('Username: ');
    final username = stdin.readLineSync()?.trim() ?? '';
    if (username.isEmpty) {
      print('❌ Username cannot be empty.');
      return;
    }

    // Check for duplicate username
    if (appointmentManager.allUsers.any((user) => user.username == username)) {
      print('❌ Username already exists.');
      return;
    }

    stdout.write('Password: ');
    final password = stdin.readLineSync()?.trim() ?? '';
    if (password.isEmpty) {
      print('❌ Password cannot be empty.');
      return;
    }

    stdout.write('Age: ');
    final ageInput = stdin.readLineSync();
    final age = int.tryParse(ageInput ?? '');
    if (age == null || age < 1 || age > 120) {
      print('❌ Invalid age.');
      return;
    }

    stdout.write('Email: ');
    final email = stdin.readLineSync()?.trim() ?? '';
    if (email.isEmpty || !email.contains('@')) {
      print('❌ Invalid email.');
      return;
    }

    stdout.write('Address: ');
    final address = stdin.readLineSync()?.trim() ?? '';
    if (address.isEmpty) {
      print('❌ Address cannot be empty.');
      return;
    }

    print('Gender:');
    print('1. Male');
    print('2. Female');
    stdout.write('Select gender: ');
    final genderChoice = stdin.readLineSync();
    final gender = genderChoice == '1' ? Gender.male : Gender.female;

    final newPatient = Patient(
      username: username,
      password: password,
      age: age,
      email: email,
      address: address,
      gender: gender,
    );

    appointmentManager.allUsers.add(newPatient);
    print('\n✅ Patient "$username" added successfully!');
    _pressEnterToContinue();
  }

  void _addDoctor() {
    print('\n👨‍⚕️ === ADD NEW DOCTOR ===');
    
    stdout.write('Username: ');
    final username = stdin.readLineSync()?.trim() ?? '';
    if (username.isEmpty) {
      print('❌ Username cannot be empty.');
      return;
    }

    if (appointmentManager.allUsers.any((user) => user.username == username)) {
      print('❌ Username already exists.');
      return;
    }

    stdout.write('Password: ');
    final password = stdin.readLineSync()?.trim() ?? '';
    if (password.isEmpty) {
      print('❌ Password cannot be empty.');
      return;
    }

    stdout.write('Email: ');
    final email = stdin.readLineSync()?.trim() ?? '';
    if (email.isEmpty || !email.contains('@')) {
      print('❌ Invalid email.');
      return;
    }

    stdout.write('Address: ');
    final address = stdin.readLineSync()?.trim() ?? '';
    if (address.isEmpty) {
      print('❌ Address cannot be empty.');
      return;
    }

    print('\n🎯 Select Specialty:');
    for (var i = 0; i < Specialty.values.length; i++) {
      print('${i + 1}. ${_formatSpecialty(Specialty.values[i])}');
    }
    stdout.write('Enter specialty number: ');
    final specialtyInput = stdin.readLineSync();
    final specialtyIndex = int.tryParse(specialtyInput ?? '');
    if (specialtyIndex == null || specialtyIndex < 1 || specialtyIndex > Specialty.values.length) {
      print('❌ Invalid specialty.');
      return;
    }
    final specialty = Specialty.values[specialtyIndex - 1];

    final newDoctor = Doctor(
      username: username,
      password: password,
      email: email,
      address: address,
      specialty: specialty,
      availableSlots: [],
    );

    appointmentManager.allUsers.add(newDoctor);
    print('\n✅ Dr. $username (${_formatSpecialty(specialty)}) added successfully!');
    _pressEnterToContinue();
  }

  void _removeUser(User currentAdmin) {
    final users = appointmentManager.allUsers;
    
    if (users.isEmpty) {
      print('📭 No users to remove.');
      return;
    }

    print('\n🗑️ === REMOVE USER ===');
    
    // Create a list of users excluding the current admin
    final usersToShow = users.where((user) => user.id != currentAdmin.id).toList();
    
    if (usersToShow.isEmpty) {
      print('📭 No other users to remove.');
      return;
    }

    for (var i = 0; i < usersToShow.length; i++) {
      final user = usersToShow[i];
      final userType = user is Patient ? '😷 Patient' : '👨‍⚕️ Doctor';
      print('${i + 1}. $userType: ${user.username}');
    }

    stdout.write('\nEnter user number to remove: ');
    final input = stdin.readLineSync();
    final choice = int.tryParse(input ?? '');
    if (choice == null || choice < 1 || choice > usersToShow.length) {
      print('❌ Invalid selection.');
      return;
    }

    final userToRemove = usersToShow[choice - 1];

    // Check if user has appointments
    final userAppointments = appointmentManager.allAppointments
        .where((appt) => appt.patientId == userToRemove.id || appt.doctorId == userToRemove.id)
        .toList();

    if (userAppointments.isNotEmpty) {
      print('⚠️ This user has ${userAppointments.length} appointment(s).');
      stdout.write('Are you sure you want to remove? (y/n): ');
      final confirm = stdin.readLineSync()?.toLowerCase();
      if (confirm != 'y') {
        print('❌ Removal cancelled.');
        return;
      }
    }

    final userName = userToRemove.username;
    users.removeWhere((user) => user.id == userToRemove.id);
    print('✅ User "$userName" removed successfully!');
    _pressEnterToContinue();
  }

  void _manageAppointments() {
    while (true) {
      print('\n📅 === APPOINTMENT MANAGEMENT ===');
      print('1. 👀 View All Appointments');
      print('2. ✅ Approve Appointment');
      print('3. ❌ Reject Appointment');
      print('4. 🗑️ Cancel Appointment');
      print('5. ↩️ Back to Main Menu');
      print('------------------------------------');
      stdout.write('Enter your choice: ');
      final String? choice = stdin.readLineSync();

      switch (choice) {
        case '1':
          _viewAllAppointments();
          break;
        case '2':
          _approveAppointment();
          break;
        case '3':
          _rejectAppointment();
          break;
        case '4':
          _cancelAppointment();
          break;
        case '5':
          return;
        default:
          print('❌ Invalid choice. Please try again.');
      }
    }
  }

  void _viewAllAppointments() {
    final appointments = appointmentManager.allAppointments;
    
    if (appointments.isEmpty) {
      print('\n📭 No appointments found.');
      _pressEnterToContinue();
      return;
    }

    print('\n👀 === ALL APPOINTMENTS ===');
    for (var i = 0; i < appointments.length; i++) {
      final appt = appointments[i];
      
      // Find patient
      Patient? patient;
      try {
        patient = appointmentManager.allUsers
            .where((user) => user.id == appt.patientId && user is Patient)
            .cast<Patient>()
            .first;
      } catch (e) {
        patient = null;
      }

      // Find doctor
      Doctor? doctor;
      try {
        doctor = appointmentManager.allUsers
            .where((user) => user.id == appt.doctorId && user is Doctor)
            .cast<Doctor>()
            .first;
      } catch (e) {
        doctor = null;
      }

      final statusEmoji = _getStatusEmoji(appt.appointmentStatus);
      final dateStr = _formatDate(appt.dateTime);
      final timeStr = _formatTime(appt.dateTime);

      print('\n${i + 1}. $statusEmoji Appointment #${appt.appointmentId}');
      print('   Patient: ${patient?.username ?? '[Deleted Patient]'}');
      print('   Doctor: Dr. ${doctor?.username ?? '[Deleted Doctor]'}');
      if (doctor != null) {
        print('   Specialty: ${_formatSpecialty(doctor.specialty)}');
        print('   Available Slots: ${doctor.availableSlots.length}');
      }
      print('   Date: $dateStr at $timeStr');
      print('   Status: ${appt.appointmentStatus.name.toUpperCase()}');
      print('   ---');
    }
    _pressEnterToContinue();
  }

  void _approveAppointment() {
    final pendingAppointments = appointmentManager.allAppointments
        .where((appt) => appt.appointmentStatus == AppointmentStatus.pending)
        .toList();

    if (pendingAppointments.isEmpty) {
      print('\n📭 No pending appointments found.');
      return;
    }

    print('\n✅ === APPROVE APPOINTMENT ===');
    for (var i = 0; i < pendingAppointments.length; i++) {
      final appt = pendingAppointments[i];
      
      // Find patient
      Patient? patient;
      try {
        patient = appointmentManager.allUsers
            .where((user) => user.id == appt.patientId && user is Patient)
            .cast<Patient>()
            .first;
      } catch (e) {
        patient = null;
      }

      // Find doctor
      Doctor? doctor;
      try {
        doctor = appointmentManager.allUsers
            .where((user) => user.id == appt.doctorId && user is Doctor)
            .cast<Doctor>()
            .first;
      } catch (e) {
        doctor = null;
      }

      final dateStr = _formatDate(appt.dateTime);
      final timeStr = _formatTime(appt.dateTime);

      print('${i + 1}. ${patient?.username ?? '[Deleted]'} with Dr. ${doctor?.username ?? '[Deleted]'}');
      print('    Date: $dateStr at $timeStr');
      print('    ---');
    }

    stdout.write('Enter appointment number to approve: ');
    final input = stdin.readLineSync();
    final choice = int.tryParse(input ?? '');
    if (choice == null || choice < 1 || choice > pendingAppointments.length) {
      print('❌ Invalid selection.');
      return;
    }

    final appointmentToApprove = pendingAppointments[choice - 1];
    
    // Find the doctor for this appointment to remove the slot
    Doctor? doctor;
    try {
      doctor = appointmentManager.allUsers
          .where((user) => user.id == appointmentToApprove.doctorId && user is Doctor)
          .cast<Doctor>()
          .first;
    } catch (e) {
      doctor = null;
    }

    // Remove the booked slot from doctor's available slots
    if (doctor != null) {
      // Find the exact slot that matches the appointment time
      final slotToRemove = doctor.availableSlots.firstWhere(
        (slot) => 
          slot.year == appointmentToApprove.dateTime.year &&
          slot.month == appointmentToApprove.dateTime.month &&
          slot.day == appointmentToApprove.dateTime.day &&
          slot.hour == appointmentToApprove.dateTime.hour &&
          slot.minute == appointmentToApprove.dateTime.minute,
        orElse: () => DateTime.now() // Default value if not found
      );
      
      // Only remove if we found a matching slot
      if (slotToRemove != DateTime.now()) {
        doctor.availableSlots.remove(slotToRemove);
        print('🗓️ Slot removed from doctor\'s availability');
      }
    }

    appointmentToApprove.appointmentStatus = AppointmentStatus.approved;
    print('✅ Appointment approved successfully!');
    _pressEnterToContinue();
  }

  void _rejectAppointment() {
    final pendingAppointments = appointmentManager.allAppointments
        .where((appt) => appt.appointmentStatus == AppointmentStatus.pending)
        .toList();

    if (pendingAppointments.isEmpty) {
      print('\n📭 No pending appointments found.');
      return;
    }

    print('\n❌ === REJECT APPOINTMENT ===');
    for (var i = 0; i < pendingAppointments.length; i++) {
      final appt = pendingAppointments[i];
      
      // Find patient
      Patient? patient;
      try {
        patient = appointmentManager.allUsers
            .where((user) => user.id == appt.patientId && user is Patient)
            .cast<Patient>()
            .first;
      } catch (e) {
        patient = null;
      }

      // Find doctor
      Doctor? doctor;
      try {
        doctor = appointmentManager.allUsers
            .where((user) => user.id == appt.doctorId && user is Doctor)
            .cast<Doctor>()
            .first;
      } catch (e) {
        doctor = null;
      }

      final dateStr = _formatDate(appt.dateTime);
      final timeStr = _formatTime(appt.dateTime);

      print('${i + 1}. ${patient?.username ?? '[Deleted]'} with Dr. ${doctor?.username ?? '[Deleted]'}');
      print('    Date: $dateStr at $timeStr');
      print('    ---');
    }

    stdout.write('Enter appointment number to reject: ');
    final input = stdin.readLineSync();
    final choice = int.tryParse(input ?? '');
    if (choice == null || choice < 1 || choice > pendingAppointments.length) {
      print('❌ Invalid selection.');
      return;
    }

    final appointmentToReject = pendingAppointments[choice - 1];
    appointmentToReject.appointmentStatus = AppointmentStatus.reject;
    
    
    print('✅ Appointment rejected successfully!');
    _pressEnterToContinue();
  }

  void _cancelAppointment() {
    final appointments = appointmentManager.allAppointments
        .where((appt) => appt.appointmentStatus == AppointmentStatus.pending || 
                        appt.appointmentStatus == AppointmentStatus.approved)
        .toList();

    if (appointments.isEmpty) {
      print('\n📭 No active appointments found (pending or approved).');
      return;
    }

    print('\n🗑️ === CANCEL APPOINTMENT ===');
    for (var i = 0; i < appointments.length; i++) {
      final appt = appointments[i];
      
      // Find patient
      Patient? patient;
      try {
        patient = appointmentManager.allUsers
            .where((user) => user.id == appt.patientId && user is Patient)
            .cast<Patient>()
            .first;
      } catch (e) {
        patient = null;
      }

      // Find doctor
      Doctor? doctor;
      try {
        doctor = appointmentManager.allUsers
            .where((user) => user.id == appt.doctorId && user is Doctor)
            .cast<Doctor>()
            .first;
      } catch (e) {
        doctor = null;
      }

      final statusEmoji = _getStatusEmoji(appt.appointmentStatus);
      final dateStr = _formatDate(appt.dateTime);
      final timeStr = _formatTime(appt.dateTime);

      print('${i + 1}. $statusEmoji ${patient?.username ?? '[Deleted]'} with Dr. ${doctor?.username ?? '[Deleted]'}');
      print('    Date: $dateStr at $timeStr | Status: ${appt.appointmentStatus.name}');
      print('    ---');
    }

    stdout.write('Enter appointment number to cancel: ');
    final input = stdin.readLineSync();
    final choice = int.tryParse(input ?? '');
    if (choice == null || choice < 1 || choice > appointments.length) {
      print('❌ Invalid selection.');
      return;
    }

    final appointmentToCancel = appointments[choice - 1];
    appointmentToCancel.appointmentStatus = AppointmentStatus.canceled;
    
    // When canceling an approved appointment, return the slot to doctor's availability
    if (appointmentToCancel.appointmentStatus == AppointmentStatus.approved) {
      Doctor? doctor;
      try {
        doctor = appointmentManager.allUsers
            .where((user) => user.id == appointmentToCancel.doctorId && user is Doctor)
            .cast<Doctor>()
            .first;
      } catch (e) {
        doctor = null;
      }
      
      if (doctor != null && !doctor.availableSlots.contains(appointmentToCancel.dateTime)) {
        doctor.availableSlots.add(appointmentToCancel.dateTime);
        print('🗓️ Slot returned to doctor\'s availability');
      }
    }
    
    print('✅ Appointment cancelled successfully!');
    _pressEnterToContinue();
  }

  // Helper methods
  String _formatSpecialty(Specialty specialty) {
    return specialty.toString().split('.').last.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => ' ${match.group(0)}'
    ).trim();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime time) {
    int hour = time.hour;
    int minute = time.minute;
    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12 == 0 ? 12 : hour % 12;
    String minuteStr = minute.toString().padLeft(2, '0');
    return '$hour:$minuteStr $period';
  }

  String _getStatusEmoji(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return '⏳';
      case AppointmentStatus.approved:
        return '✅';
      case AppointmentStatus.reject:
        return '❌';
      case AppointmentStatus.canceled:
        return '🗑️';
    }
  }

  void _pressEnterToContinue() {
    print('\nPress Enter to continue...');
    stdin.readLineSync();
  }
}