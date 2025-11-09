import 'dart:io';
import '../data/Repository/User_file.dart';
import '../data/Repository/appointments_file.dart';
import '../domain/Service/userManager.dart';
import '../domain/admin.dart';
import '../domain/user.dart';
import '../domain/patient.dart';
import '../domain/doctor.dart';
import '../domain/appointment.dart';
import '../domain/Service/appointmentManager.dart';

class AdminDashboard {
  final AppointmentManager appointmentManager;
  final UserManager userManager;

  AdminDashboard(this.appointmentManager, this.userManager);

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
          _manageUsersBoard(admin);
          break;
        case '2':
          _manageAppointmentsBoard();
          break;
        case '3':
          print('\n👋 Logging out. Goodbye!');
          return;
        default:
          print('❌ Invalid choice. Please try again.');
      }
    }
  }

  void _manageAppointmentsBoard() {
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

  void _approveAppointment() {
    try {
      List<Appointment> appointments = appointmentManager.getAllAppointment();

      // Get pending appointments only
      final pendingAppointments = appointments
          .where((a) => a.appointmentStatus == AppointmentStatus.pending)
          .toList();

      if (pendingAppointments.isEmpty) {
        print('\n📭 No pending appointments found.');
        return;
      }

      print('\n✅ APPROVE APPOINTMENT');
      print('─' * 50);
      print('⏳ Pending Appointments:');
      print('─' * 50);

      // Display pending appointments
      for (int i = 0; i < pendingAppointments.length; i++) {
        final appointment = pendingAppointments[i];
        final patientInfo = userManager.getPatientInfo(appointment.patientId);
        final doctorInfo = userManager.getDoctorInfo(appointment.doctorId);

        print(
            '${i + 1}. ${_formatCompactAppointmentInfo(appointment, patientInfo, doctorInfo)}');
        if (i < pendingAppointments.length - 1) print('');
      }

      // Get user selection
      stdout.write(
          '\nEnter appointment number to approve (1-${pendingAppointments.length}) or "cancel" to go back: ');
      String input = stdin.readLineSync()?.trim() ?? '';

      if (input.toLowerCase() == 'cancel') {
        print('🚫 Approval cancelled.');
        return;
      }

      int appointmentIndex = int.tryParse(input) ?? 0;
      if (appointmentIndex < 1 ||
          appointmentIndex > pendingAppointments.length) {
        print(
            '❌ Invalid selection. Please enter a number between 1 and ${pendingAppointments.length}.');
        return;
      }

      Appointment selectedAppointment =
          pendingAppointments[appointmentIndex - 1];

      // Confirm approval
      print('\n⚠️  CONFIRM APPROVAL');
      print('You are about to approve:');
      print(_formatAppointmentInfo(selectedAppointment, '🟡'));

      stdout.write(
          '\nAre you sure you want to approve this appointment? (yes/no): ');
      String confirmation = stdin.readLineSync()?.trim()?.toLowerCase() ?? '';

      if (confirmation == 'yes' || confirmation == 'y') {
        appointmentManager
            .approveAppointment(selectedAppointment.appointmentId);
        print('\n✅ Appointment has been approved successfully!');
      } else {
        print('🚫 Approval cancelled.');
      }
    } catch (e) {
      print('❌ Error approving appointment: $e');
    }
  }

  void _rejectAppointment() {
    try {
      List<Appointment> appointments = appointmentManager.getAllAppointment();

      // Get pending appointments only
      final pendingAppointments = appointments
          .where((a) => a.appointmentStatus == AppointmentStatus.pending)
          .toList();

      if (pendingAppointments.isEmpty) {
        print('\n📭 No pending appointments found.');
        return;
      }

      print('\n❌ REJECT APPOINTMENT');
      print('─' * 50);
      print('⏳ Pending Appointments:');
      print('─' * 50);

      // Display pending appointments
      for (int i = 0; i < pendingAppointments.length; i++) {
        final appointment = pendingAppointments[i];
        final patientInfo = userManager.getPatientInfo(appointment.patientId);
        final doctorInfo = userManager.getDoctorInfo(appointment.doctorId);

        print(
            '${i + 1}. ${_formatCompactAppointmentInfo(appointment, patientInfo, doctorInfo)}');
        if (i < pendingAppointments.length - 1) print('');
      }

      // Get user selection
      stdout.write(
          '\nEnter appointment number to reject (1-${pendingAppointments.length}) or "cancel" to go back: ');
      String input = stdin.readLineSync()?.trim() ?? '';

      if (input.toLowerCase() == 'cancel') {
        print('🚫 Rejection cancelled.');
        return;
      }

      int appointmentIndex = int.tryParse(input) ?? 0;
      if (appointmentIndex < 1 ||
          appointmentIndex > pendingAppointments.length) {
        print(
            '❌ Invalid selection. Please enter a number between 1 and ${pendingAppointments.length}.');
        return;
      }

      Appointment selectedAppointment =
          pendingAppointments[appointmentIndex - 1];

      // Get rejection reason
      print('\n📝 Please provide a reason for rejection:');
      stdout.write('Reason: ');
      String reason = stdin.readLineSync()?.trim() ?? 'No reason provided';

      // Confirm rejection
      print('\n⚠️  CONFIRM REJECTION');
      print('You are about to reject:');
      print(_formatAppointmentInfo(selectedAppointment, '🟡'));
      print('Reason: $reason');

      stdout.write(
          '\nAre you sure you want to reject this appointment? (yes/no): ');
      String confirmation = stdin.readLineSync()?.trim()?.toLowerCase() ?? '';

      if (confirmation == 'yes' || confirmation == 'y') {
        appointmentManager.rejectAppointment(selectedAppointment.appointmentId);
        print('\n❌ Appointment has been rejected successfully!');
        print('Reason: $reason');
      } else {
        print('🚫 Rejection cancelled.');
      }
    } catch (e) {
      print('❌ Error rejecting appointment: $e');
    }
  }

  void _cancelAppointment() {
    try {
      List<Appointment> appointments = appointmentManager.getAllAppointment();

      // Get pending and approved appointments (can cancel both)
      final cancellableAppointments = appointments
          .where((a) =>
              a.appointmentStatus == AppointmentStatus.pending ||
              a.appointmentStatus == AppointmentStatus.approved)
          .toList();

      if (cancellableAppointments.isEmpty) {
        print('\n📭 No cancellable appointments found.');
        print('   (Only pending or approved appointments can be cancelled)');
        return;
      }

      print('\n🗑️ CANCEL APPOINTMENT');
      print('─' * 50);
      print('Appointments Available for Cancellation:');
      print('─' * 50);

      // Display cancellable appointments
      for (int i = 0; i < cancellableAppointments.length; i++) {
        final appointment = cancellableAppointments[i];
        final patientInfo = userManager.getPatientInfo(appointment.patientId);
        final doctorInfo = userManager.getDoctorInfo(appointment.doctorId);

        print(
            '${i + 1}. ${_formatCompactAppointmentInfo(appointment, patientInfo, doctorInfo)}');
        if (i < cancellableAppointments.length - 1) print('');
      }

      // Get user selection
      stdout.write(
          '\nEnter appointment number to cancel (1-${cancellableAppointments.length}) or "cancel" to go back: ');
      String input = stdin.readLineSync()?.trim() ?? '';

      if (input.toLowerCase() == 'cancel') {
        print('🚫 Cancellation cancelled.');
        return;
      }

      int appointmentIndex = int.tryParse(input) ?? 0;
      if (appointmentIndex < 1 ||
          appointmentIndex > cancellableAppointments.length) {
        print(
            '❌ Invalid selection. Please enter a number between 1 and ${cancellableAppointments.length}.');
        return;
      }

      Appointment selectedAppointment =
          cancellableAppointments[appointmentIndex - 1];



      // Confirm cancellation
      print('\n⚠️  CONFIRM CANCELLATION');
      print('You are about to cancel:');
      print(_formatAppointmentInfo(selectedAppointment,
          _getStatusIcon(selectedAppointment.appointmentStatus)));


      stdout.write(
          '\nAre you sure you want to cancel this appointment? (yes/no): ');
      String confirmation = stdin.readLineSync()?.trim()?.toLowerCase() ?? '';

      if (confirmation == 'yes' || confirmation == 'y') {
        appointmentManager.cancelAppointment(selectedAppointment.appointmentId);
        print('\n🚫 Appointment has been cancelled successfully!');
      } else {
        print('🚫 Cancellation cancelled.');
      }
    } catch (e) {
      print('❌ Error cancelling appointment: $e');
    }
  }

// Helper method for compact appointment display in lists
  String _formatCompactAppointmentInfo(Appointment appointment,
      Map<String, String> patientInfo, Map<String, String> doctorInfo) {
    final statusIcon = _getStatusIcon(appointment.appointmentStatus);
    final formattedDate = _formatDateTime(appointment.dateTime);
    final formattedTime = _formatTime(appointment.dateTime);

    return '$statusIcon ID: ${appointment.appointmentId} | '
        'Patient: ${patientInfo['name']} | '
        'Doctor: ${doctorInfo['name']} | '
        'Date: $formattedDate $formattedTime | '
        'Status: ${_formatAppointmentStatus(appointment.appointmentStatus)}';
  }

// Helper method to get status icon
  String _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return '🟡';
      case AppointmentStatus.approved:
        return '🟢';
      case AppointmentStatus.rejected:
        return '🔴';
      case AppointmentStatus.canceled:
        return '⚫';
    }
  }

  void _viewAllAppointments() {
    try {
      List<Appointment> appointments = appointmentManager.getAllAppointment();

      if (appointments.isEmpty) {
        print('\n📭 No appointments found.');
        return;
      }

      print('\n' + '=' * 100);
      print('📅 ALL APPOINTMENTS (${appointments.length} total)');
      print('=' * 100);

      // Sort appointments by date for better organization
      appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      // Group appointments by status
      final pendingAppointments = appointments
          .where((a) => a.appointmentStatus == AppointmentStatus.pending)
          .toList();
      final approvedAppointments = appointments
          .where((a) => a.appointmentStatus == AppointmentStatus.approved)
          .toList();
      final rejectedAppointments = appointments
          .where((a) => a.appointmentStatus == AppointmentStatus.rejected)
          .toList();
      final cancelledAppointments = appointments
          .where((a) => a.appointmentStatus == AppointmentStatus.canceled)
          .toList();

      // Display appointments by status
      _displayAppointmentsByStatus(
          pendingAppointments, '⏳ PENDING APPOINTMENTS', '🟡');
      _displayAppointmentsByStatus(
          approvedAppointments, '✅ APPROVED APPOINTMENTS', '🟢');
      _displayAppointmentsByStatus(
          rejectedAppointments, '❌ REJECTED APPOINTMENTS', '🔴');
      _displayAppointmentsByStatus(
          cancelledAppointments, '🚫 CANCELLED APPOINTMENTS', '⚫');

      // Display summary
      print('\n📊 APPOINTMENT SUMMARY:');
      print('─' * 50);
      print('⏳ Pending: ${pendingAppointments.length}');
      print('✅ Approved: ${approvedAppointments.length}');
      print('❌ Rejected: ${rejectedAppointments.length}');
      print('🚫 Cancelled: ${cancelledAppointments.length}');
      print(
          '📈 Completion Rate: ${((approvedAppointments.length / appointments.length) * 100).toStringAsFixed(1)}%');
      print('=' * 100);
    } catch (e) {
      print('❌ Error fetching appointments: $e');
    }
  }

  void _displayAppointmentsByStatus(
      List<Appointment> appointments, String header, String statusIcon) {
    if (appointments.isEmpty) return;

    print('\n$header (${appointments.length})');
    print('─' * 80);

    for (int i = 0; i < appointments.length; i++) {
      final appointment = appointments[i];
      print('${i + 1}. ${_formatAppointmentInfo(appointment, statusIcon)}');

      if (i < appointments.length - 1) {
        print('   ${'─' * 70}');
      }
    }
  }

  String _formatAppointmentInfo(Appointment appointment, String statusIcon) {
    final patientInfo = userManager.getPatientInfo(appointment.patientId);
    final doctorInfo = userManager.getDoctorInfo(appointment.doctorId);

    return '''
$statusIcon ID: ${appointment.appointmentId}
   👤 Patient: ${patientInfo['name']} (ID: ${appointment.patientId})
   👨‍⚕️ Doctor: ${doctorInfo['name']} (ID: ${appointment.doctorId}) | Specialty: ${doctorInfo['specialty']}
   📅 Date: ${_formatDateTime(appointment.dateTime)}
   🕒 Time: ${_formatTime(appointment.dateTime)}
   📍 Status: ${_formatAppointmentStatus(appointment.appointmentStatus)}''';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:$minute $period';
  }

  String _formatAppointmentStatus(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return '⏳ Pending';
      case AppointmentStatus.approved:
        return '✅ Approved';
      case AppointmentStatus.rejected:
        return '❌ Rejected';
      case AppointmentStatus.canceled:
        return '🚫 Cancelled';
    }
  }

  void _manageUsersBoard(User currentAdmin) {
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
          _displayUser(currentAdmin); // Fixed: call the method properly
          break;
        case '2':
          _addPatient(currentAdmin);
          break;
        case '3':
          _addDoctor(currentAdmin);
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

  //Ai generate
  void _displayUser(User currentAdmin) {
    // Check if current user is admin
    if (currentAdmin.type != UserType.admin) {
      print('❌ Access denied! Only administrators can view all users.');
      return;
    }

    // Get all users from UserManager
    List<User> allUsers = userManager.getallUser();

    if (allUsers.isEmpty) {
      print('📭 No users found in the system.');
      return;
    }

    print('\n' + '=' * 80);
    print('👥 ALL REGISTERED USERS');
    print('=' * 80);

    // Display users by type
    _displayUsersByType(allUsers, UserType.admin, '🛡️  ADMINS');
    _displayUsersByType(allUsers, UserType.doctor, '👨‍⚕️ DOCTORS');
    _displayUsersByType(allUsers, UserType.patient, '👥 PATIENTS');

    print('\n📊 SUMMARY:');
    print('Total Users: ${allUsers.length}');
    print('Admins: ${allUsers.where((user) => user is Admin).length}');
    print('Doctors: ${allUsers.where((user) => user is Doctor).length}');
    print('Patients: ${allUsers.where((user) => user is Patient).length}');
    print('=' * 80);
  }

  void _displayUsersByType(List<User> users, UserType type, String header) {
    final filteredUsers = users.where((user) => user.type == type).toList();

    if (filteredUsers.isEmpty) return;

    print('\n$header');
    print('─' * 60);

    for (int i = 0; i < filteredUsers.length; i++) {
      final user = filteredUsers[i];
      print('${i + 1}. ${_formatUserInfo(user)}');
      print('   └─ ${_getUserSpecificDetails(user)}');
      if (i < filteredUsers.length - 1) print('');
    }
  }

  String _formatUserInfo(User user) {
    return '${user.username} (ID: ${user.id})';
  }

  String _getUserSpecificDetails(User user) {
    switch (user.runtimeType) {
      case Admin:
        return 'Role: System Administrator';

      case Doctor:
        final doctor = user as Doctor;
        return 'Specialty: ${doctor.specialty.toString().split('.').last} | '
            'Email: ${doctor.email} | '
            'Available Slots: ${doctor.availableSlots.length}';

      case Patient:
        final patient = user as Patient;
        return 'Age: ${patient.age} | '
            'Gender: ${patient.gender.toString().split('.').last} | '
            'Email: ${patient.email}';

      default:
        return 'Unknown user type';
    }
  }

  void _addPatient(User currentAdmin) {
    if (currentAdmin.type != UserType.admin) {
      print('❌ Only admins can add patients.');
      return;
    }

    print('\n➕ ADDING NEW PATIENT');
    print('─' * 40);

    try {
      // Get patient details
      stdout.write('Enter username: ');
      String username = stdin.readLineSync()?.trim() ?? '';
      if (username.isEmpty) {
        print('❌ Username cannot be empty.');
        return;
      }

      // Check if username already exists
      if (userManager.isUsernameExists(username)) {
        print(
            '❌ Username "$username" already exists. Please choose a different username.');
        return;
      }

      stdout.write('Enter password: ');
      String password = stdin.readLineSync()?.trim() ?? '';
      if (password.isEmpty) {
        print('❌ Password cannot be empty.');
        return;
      }

      stdout.write('Enter email: ');
      String email = stdin.readLineSync()?.trim() ?? '';
      if (email.isEmpty || userManager.isValidEmail(email)) {
        print('❌ Please enter a valid email.');
        return;
      }

      stdout.write('Enter age: ');
      int age = int.tryParse(stdin.readLineSync()?.trim() ?? '') ?? 0;
      if (age <= 0 || age > 120) {
        print('❌ Please enter a valid age (1-120).');
        return;
      }

      stdout.write('Enter address: ');
      String address = stdin.readLineSync()?.trim() ?? '';
      if (address.isEmpty) {
        print('❌ Address cannot be empty.');
        return;
      }

      // Gender selection
      print('\nSelect gender:');
      print('1. Male');
      print('2. Female');
      stdout.write('Enter choice (1-2): ');
      String genderChoice = stdin.readLineSync()?.trim() ?? '';

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

      // Create new patient - ID will be auto-generated by User class
      Patient newPatient = Patient(
        username: username,
        password: password,
        age: age,
        address: address,
        email: email,
        gender: gender,
      );

      // Add using UserManager
      userManager.addUser(newPatient);

      print('\n✅ Patient added successfully!');
      print('Patient ID: ${newPatient.id}');
      print('Username: $username');
      print('Age: $age');
      print('Email: $email');
    } catch (e) {
      print('❌ Error adding patient: $e');
    }
  }

  void _addDoctor(User currentAdmin) {
    if (currentAdmin.type != UserType.admin) {
      print('❌ Only admins can add doctors.');
      return;
    }

    print('\n➕ ADDING NEW DOCTOR');
    print('─' * 40);

    try {
      // Get doctor details
      stdout.write('Enter username: ');
      String username = stdin.readLineSync()?.trim() ?? '';
      if (username.isEmpty) {
        print('❌ Username cannot be empty.');
        return;
      }

      // Check if username already exists
      if (userManager.isUsernameExists(username)) {
        print(
            '❌ Username "$username" already exists. Please choose a different username.');
        return;
      }

      stdout.write('Enter password: ');
      String password = stdin.readLineSync()?.trim() ?? '';
      if (password.isEmpty) {
        print('❌ Password cannot be empty.');
        return;
      }

      stdout.write('Enter email: ');
      String email = stdin.readLineSync()?.trim() ?? '';
      if (email.isEmpty || userManager.isValidEmail(email)) {
        print('❌ Please enter a valid email.');
        return;
      }

      stdout.write('Enter address: ');
      String address = stdin.readLineSync()?.trim() ?? '';
      if (address.isEmpty) {
        print('❌ Address cannot be empty.');
        return;
      }

      // Specialty selection
      print('\nSelect specialty:');
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
      String specialtyChoice = stdin.readLineSync()?.trim() ?? '';

      Specialty specialty;
      switch (specialtyChoice) {
        case '1':
          specialty = Specialty.generalPractice;
          break;
        case '2':
          specialty = Specialty.pediatrics;
          break;
        case '3':
          specialty = Specialty.cardiology;
          break;
        case '4':
          specialty = Specialty.dermatology;
          break;
        case '5':
          specialty = Specialty.neurology;
          break;
        case '6':
          specialty = Specialty.orthopedics;
          break;
        case '7':
          specialty = Specialty.psychiatry;
          break;
        case '8':
          specialty = Specialty.surgery;
          break;
        case '9':
          specialty = Specialty.obstetricsGynecology;
          break;
        default:
          print('❌ Invalid specialty selection.');
          return;
      }

      // Create new doctor with empty available slots - ID will be auto-generated
      Doctor newDoctor = Doctor(
        username: username,
        password: password,
        address: address,
        email: email,
        specialty: specialty,
        availableSlots: [], // Start with no available slots
      );

      // Add using UserManager
      userManager.addUser(newDoctor);

      print('\n✅ Doctor added successfully!');
      print('Doctor ID: ${newDoctor.id}');
      print('Username: $username');
      print('Specialty: ${userManager.formatSpecialty(specialty)}');
      print('Email: $email');
    } catch (e) {
      print('❌ Error adding doctor: $e');
    }
  }

// Helper function to check if username already exists

  void _removeUser(User currentAdmin) {
    if (currentAdmin.type != UserType.admin) {
      print('❌ Only admins can remove users.');
      return;
    }

    print('\n🗑️ REMOVE USER');
    print('─' * 40);

    try {
      // First, display all users so admin can see which ones to remove
      List<User> allUsers = userManager.getallUser();

      if (allUsers.isEmpty) {
        print('📭 No users found in the system.');
        return;
      }

      // Display users in a simple list format for removal
      print('\n📋 Registered Users:');
      print('─' * 60);

      for (int i = 0; i < allUsers.length; i++) {
        final user = allUsers[i];
        String userType = user.type.toString().split('.').last;
        String adminIndicator = user.type == UserType.admin ? ' 🛡️' : '';
        print(
            '${i + 1}. ${user.username} (ID: ${user.id}) - $userType$adminIndicator');
      }

      // Get user selection
      print('\nSelect user to remove:');
      stdout.write(
          'Enter user number (1-${allUsers.length}) or "cancel" to go back: ');
      String input = stdin.readLineSync()?.trim() ?? '';

      if (input.toLowerCase() == 'cancel') {
        print('🚫 Removal cancelled.');
        return;
      }

      int userIndex = int.tryParse(input) ?? 0;
      if (userIndex < 1 || userIndex > allUsers.length) {
        print(
            '❌ Invalid selection. Please enter a number between 1 and ${allUsers.length}.');
        return;
      }

      User userToRemove = allUsers[userIndex - 1];

      // Prevent removal of any admin account
      if (userToRemove.type == UserType.admin) {
        print('❌ Cannot remove admin accounts. Admin accounts are protected.');
        print(
            '   If you need to remove an admin, please contact system administrator.');
        return;
      }

      // Additional check: prevent admin from removing themselves (redundant but safe)
      if (userToRemove.id == currentAdmin.id) {
        print('❌ You cannot remove your own admin account.');
        return;
      }

      // Confirm removal
      print('\n⚠️  CONFIRM REMOVAL');
      print('You are about to remove:');
      print('Username: ${userToRemove.username}');
      print('User ID: ${userToRemove.id}');
      print('Type: ${userToRemove.type.toString().split('.').last}');

      stdout.write('\nAre you sure you want to remove this user? (yes/no): ');
      String confirmation = stdin.readLineSync()?.trim()?.toLowerCase() ?? '';

      if (confirmation == 'yes' || confirmation == 'y') {
        // Remove the user
        userManager.removeUser(userToRemove.id);

        print(
            '\n✅ User "${userToRemove.username}" has been successfully removed.');

        // Show updated count
        List<User> updatedUsers = userManager.getallUser();
        print('Total users remaining: ${updatedUsers.length}');
      } else {
        print('🚫 Removal cancelled.');
      }
    } catch (e) {
      print('❌ Error removing user: $e');
    }
  }
}

void main() {
  UserRepository reUser = UserRepository('../data/users.json');

  AppointmentRepository reApp =
      AppointmentRepository('../data/appointments.json');

  Admin admin = Admin(username: 'ming', password: 'ming123');


  UserManager userManager = UserManager(userRepository: reUser);
  AppointmentManager appointmentManager = AppointmentManager(reApp,userManager);
  AdminDashboard ad = AdminDashboard(appointmentManager, userManager);

  ad.startAdminDashboard(admin);
}
