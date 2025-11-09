import 'dart:io';
import '../data/Repository/User_file.dart';
import '../data/Repository/appointments_file.dart';
import '../domain/Service/appointmentManager.dart';
import '../domain/Service/userManager.dart';
import '../domain/patient.dart';
import '../domain/user.dart';
import '../domain/appointment.dart';
import '../domain/doctor.dart';


class PatientDashboard {
  final AppointmentManager appointmentManager;
  final UserManager userManager;

  PatientDashboard(this.appointmentManager,this.userManager);

  void startPatientDashboard(User patient) {
    if (patient.type != UserType.patient) {
      print('❌ Only patients can access this dashboard.');
      return;
    }

    while (true) {
      print('\n====================================');
      print('   🏥 PATIENT DASHBOARD');
      print('   Welcome, ${patient.username.toUpperCase()}!');
      print('====================================');
      print('1. 📅 Book New Appointment');
      print('2. 📋 View My Appointments');
      print('3. 🚪 Logout');
      print('------------------------------------');
      stdout.write('Enter your choice: ');
      final String? choice = stdin.readLineSync();

      switch (choice) {
        case '1':
          _handleBookAppointment(patient);
          break;
        case '2':
          _viewAppointments(patient);
          break;
        case '3':
          print('\n👋 Thank you for using our service. Goodbye!');
          return;
        default:
          print('❌ Invalid choice. Please try again.');
      }
    }
  }

void _handleBookAppointment(User patient) {
  print('\n====================================');
  print('   📅 BOOK NEW APPOINTMENT');
  print('====================================');

  // Get all users and filter doctors
  final allUsers = appointmentManager.userManager.getallUser();
  final doctors = allUsers.where((user) => user is Doctor).cast<Doctor>().toList();

  if (doctors.isEmpty) {
    print('❌ No doctors available at the moment.');
    return;
  }

  // Display available doctors
  print('\n👨‍⚕️  AVAILABLE DOCTORS:');
  print('------------------------------------');
  for (int i = 0; i < doctors.length; i++) {
    final doctor = doctors[i];
    final specialty = appointmentManager.userManager.formatSpecialty(doctor.specialty);
    final availableSlots = doctor.availableSlots.length;
    print('${i + 1}. Dr. ${doctor.username}');
    print('   Specialty: $specialty');
    print('   Available Slots: $availableSlots');
    print('   Email: ${doctor.email}');
    print('------------------------------------');
  }

  // Select doctor
  stdout.write('Select a doctor (1-${doctors.length}): ');
  final doctorChoice = stdin.readLineSync();
  final doctorIndex = int.tryParse(doctorChoice ?? '') ?? -1;

  if (doctorIndex < 1 || doctorIndex > doctors.length) {
    print('❌ Invalid doctor selection.');
    return;
  }

  final selectedDoctor = doctors[doctorIndex - 1];

  // Check if doctor has available slots
  if (selectedDoctor.availableSlots.isEmpty) {
    print('❌ Dr. ${selectedDoctor.username} has no available slots at the moment.');
    return;
  }

  // Display available time slots
  print('\n🕐 AVAILABLE TIME SLOTS:');
  print('------------------------------------');
  for (int i = 0; i < selectedDoctor.availableSlots.length; i++) {
    final slot = selectedDoctor.availableSlots[i];
    print('${i + 1}. ${_formatDateTime(slot)}');
  }

  // Select time slot
  stdout.write('Select a time slot (1-${selectedDoctor.availableSlots.length}): ');
  final slotChoice = stdin.readLineSync();
  final slotIndex = int.tryParse(slotChoice ?? '') ?? -1;

  if (slotIndex < 1 || slotIndex > selectedDoctor.availableSlots.length) {
    print('❌ Invalid time slot selection.');
    return;
  }

  final selectedDateTime = selectedDoctor.availableSlots[slotIndex - 1];

  // Confirm booking
  print('\n📋 APPOINTMENT SUMMARY:');
  print('------------------------------------');
  print('Patient: ${patient.username}');
  print('Doctor: Dr. ${selectedDoctor.username}');
  print('Specialty: ${appointmentManager.userManager.formatSpecialty(selectedDoctor.specialty)}');
  print('Date & Time: ${_formatDateTime(selectedDateTime)}');
  print('------------------------------------');

  stdout.write('Confirm booking? (y/n): ');
  final confirmation = stdin.readLineSync()?.toLowerCase();

  if (confirmation == 'y' || confirmation == 'yes') {
    try {
      // Create new appointment
      final newAppointment = Appointment(
        patientId: patient.id,
        doctorId: selectedDoctor.id,
        dateTime: selectedDateTime,
        appointmentStatus: AppointmentStatus.pending,
      );

      // Add appointment using AppointmentManager
      appointmentManager.addAppointment(newAppointment);

      print('\n✅ Appointment booked successfully!');
      print('Your appointment ID: ${newAppointment.appointmentId}');
      print('Status: Pending approval from doctor');
      
    } catch (e) {
      print('❌ Failed to book appointment: $e');
    }
  } else {
    print('❌ Appointment booking cancelled.');
  }
}

String _formatDateTime(DateTime dateTime) {
  final hour = dateTime.hour;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  
  // Convert to 12-hour format
  final period = hour >= 12 ? 'PM' : 'AM';
  final twelveHour = hour % 12 == 0 ? 12 : hour % 12;
  
  return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${twelveHour.toString().padLeft(2, '0')}:$minute $period';
}

void _viewAppointments(User patient) {
  print('\n====================================');
  print('   📋 MY APPOINTMENTS');
  print('====================================');

  final appointments = appointmentManager.getAllAppointment()
      .where((appointment) => appointment.patientId == patient.id)
      .toList();

  if (appointments.isEmpty) {
    print('No appointments found.');
    return;
  }

  // Sort appointments by date (most recent first)
  appointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));

  for (int i = 0; i < appointments.length; i++) {
    final appointment = appointments[i];
    final doctorInfo = appointmentManager.userManager.getDoctorInfo(appointment.doctorId);
    
    print('\n${i + 1}. Appointment ID: ${appointment.appointmentId}');
    print('   Doctor: Dr. ${doctorInfo['name']}');
    print('   Specialty: ${doctorInfo['specialty']}');
    print('   Date & Time: ${_formatDateTime(appointment.dateTime)}');
    print('   Status: ${_getStatusEmoji(appointment.appointmentStatus)} ${appointment.appointmentStatus.toString().split('.').last}');
    print('   ------------------------------------');
  }

  // Optional: Add functionality to cancel appointments
  print('\nOptions:');
  print('1. Cancel an appointment');
  print('2. Back to main menu');
  stdout.write('Enter your choice: ');
  final choice = stdin.readLineSync();

  if (choice == '1') {
    _handleCancelAppointment(patient, appointments);
  }
}

void _handleCancelAppointment(User patient, List<Appointment> appointments) {
  stdout.write('\nEnter the appointment number to cancel: ');
  final input = stdin.readLineSync();
  final appointmentIndex = int.tryParse(input ?? '') ?? -1;

  if (appointmentIndex < 1 || appointmentIndex > appointments.length) {
    print('❌ Invalid appointment number.');
    return;
  }

  final appointmentToCancel = appointments[appointmentIndex - 1];
  
  if (appointmentToCancel.appointmentStatus != AppointmentStatus.pending && 
      appointmentToCancel.appointmentStatus != AppointmentStatus.approved) {
    print('❌ Cannot cancel a ${appointmentToCancel.appointmentStatus.toString().split('.').last} appointment.');
    return;
  }

  print('\n🚫 CONFIRM CANCELLATION:');
  print('------------------------------------');
  final doctorInfo = appointmentManager.userManager.getDoctorInfo(appointmentToCancel.doctorId);
  print('Appointment ID: ${appointmentToCancel.appointmentId}');
  print('Doctor: Dr. ${doctorInfo['name']}');
  print('Date & Time: ${_formatDateTime(appointmentToCancel.dateTime)}');
  print('------------------------------------');

  stdout.write('Are you sure you want to cancel this appointment? (y/n): ');
  final confirmation = stdin.readLineSync()?.toLowerCase();

  if (confirmation == 'y' || confirmation == 'yes') {
    appointmentManager.cancelAppointment(appointmentToCancel.appointmentId);
    print('✅ Appointment cancelled successfully.');
  } else {
    print('❌ Cancellation aborted.');
  }
}

String _getStatusEmoji(AppointmentStatus status) {
  switch (status) {
    case AppointmentStatus.pending:
      return '⏳';
    case AppointmentStatus.approved:
      return '✅';
    case AppointmentStatus.canceled:
      return '❌';
    case AppointmentStatus.rejected:
      return '🚫';
  }
}


}

void main() {
  UserRepository reUser = UserRepository('../data/users.json');
  AppointmentRepository reApp = AppointmentRepository('../data/appointments.json');

  UserManager userManager =  UserManager(userRepository: reUser);
  AppointmentManager appointmentManager = AppointmentManager(reApp, userManager);


  Patient? patient = userManager.getPatientById('26ffa3ec-4a7e-4d5e-a28e-dbe30a3e34ad');

  if (patient == null) {
    print('Not found this patient');
    return;
  }
  PatientDashboard p1 = PatientDashboard(appointmentManager, userManager);

  p1.startPatientDashboard(patient);

  
}