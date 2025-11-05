import 'dart:io';
import '../domain/appointmentManager.dart';
import '../domain/user.dart';
import '../domain/appointment.dart';
import '../domain/doctor.dart';

class PatientDashboard {
  final AppointmentManager appointmentManager;

  PatientDashboard(this.appointmentManager);

  void startPatientDashboard(User patient) {
    if (patient.type != UserType.patient) {
      print('❌ Only patients can access this dashboard.');
      return;
    }

    while (true) {
      print('\n====================================');
      print('   WELCOME, ${patient.username.toUpperCase()}');
      print('====================================');
      print('1. Book New Appointment');
      print('2. View My Appointments');
      print('3. Logout');
      print('------------------------------------');
      stdout.write('Enter your choice: ');
      final String? choice = stdin.readLineSync();

      switch (choice) {
        case '1':
          handleBookAppointment(patient);
          break;
        case '2':
          viewAppointments(patient);
          break;
        case '3':
          print('\n👋 Logging out. Goodbye!');
          return;
        default:
          print('Invalid choice. Please try again.');
      }
    }
  }

  String formatTime(DateTime time) {
    int hour = time.hour;
    int minute = time.minute;
    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12 == 0 ? 12 : hour % 12;
    String minuteStr = minute.toString().padLeft(2, '0');
    return '$hour:$minuteStr $period';
  }

void handleBookAppointment(User patient) {
    final doctors = appointmentManager.allUsers
        .where((u) => u.type == UserType.doctor)
        .cast<Doctor>()
        .toList();

    if (doctors.isEmpty) {
      print('No doctors currently available.');
      return;
    }

    print('\n--- AVAILABLE DOCTORS ---');
    for (int i = 0; i < doctors.length; i++) {
      print('${i + 1}. ${doctors[i].username} (Specialty: ${doctors[i].specialty.name})');
    }

    stdout.write('Select a doctor by number: ');
    final docNum = stdin.readLineSync();
    if (docNum == null) return;

    final doctorChoice = int.tryParse(docNum);
    if (doctorChoice == null || doctorChoice < 1 || doctorChoice > doctors.length) {
      print('Invalid doctor selection.');
      return;
    }

    final selectedDoctor = doctors[doctorChoice - 1];

    final availableDates = selectedDoctor.availableSlots;
    if (availableDates.isEmpty) {
      print('No available dates for Dr. ${selectedDoctor.username}');
      return;
    }

    print('\n--- AVAILABLE SLOTS ---');
    for (int i = 0; i < availableDates.length; i++) {
      final slot = availableDates[i];
      final dateStr = '${slot.year}-${slot.month.toString().padLeft(2,'0')}-${slot.day.toString().padLeft(2,'0')}';
      final timeStr = formatTime(slot);
      print('${i + 1}. $dateStr at $timeStr');
    }

    stdout.write('Select a slot by number: ');
    final slotNum = stdin.readLineSync();
    if (slotNum == null) return;

    final slotChoice = int.tryParse(slotNum);
    if (slotChoice == null || slotChoice < 1 || slotChoice > availableDates.length) {
      print('Invalid slot selection.');
      return;
    }

    final selectedSlot = availableDates[slotChoice - 1];

    final newAppointment = appointmentManager.bookAppointment(
      patient.id,
      selectedDoctor.id,
      selectedSlot,
    );

    if (newAppointment != null) {
      print('\n🎉 Appointment successfully booked!');
      print('Doctor: ${selectedDoctor.username}');
      print('Date: ${selectedSlot.year}-${selectedSlot.month.toString().padLeft(2,'0')}-${selectedSlot.day.toString().padLeft(2,'0')}');
      print('Time: ${formatTime(selectedSlot)}');
      print('Appointment ID: ${newAppointment.appointmentId}');
    } else {
      print('\n❌ Failed to book appointment. Please check the selection.');
    }
  }


  void viewAppointments(User patient) {
  final myAppointments = appointmentManager.allAppointments
      .where((appt) => appt.patientId == patient.id)
      .toList();

  if (myAppointments.isEmpty) {
    print('\nYou have no appointments.');
    return;
  }

  print('\n--- MY APPOINTMENTS ---');
  for (var i = 0; i < myAppointments.length; i++) {
    final appt = myAppointments[i];

    // Try to find doctor safely
    final doctorList = appointmentManager.allUsers
        .where((u) => u.id == appt.doctorId && u.type == UserType.doctor)
        .toList();

    String doctorName;
    String specialtyName;
    if (doctorList.isEmpty) {
      doctorName = '[Deleted Doctor]';
      specialtyName = '-';
    } else {
      final doctor = doctorList.first as Doctor;
      doctorName = 'Dr. ${doctor.username}';
      specialtyName = doctor.specialty.name;
    }

    final dateStr =
        '${appt.dateTime.year}-${appt.dateTime.month.toString().padLeft(2, '0')}-${appt.dateTime.day.toString().padLeft(2, '0')}';
    final timeStr = formatTime(appt.dateTime);

    print(
        '${i + 1}. $doctorName ($specialtyName) on $dateStr at $timeStr | Status: ${appt.appointmentStatus.name}');
  }

  // Filter only pending appointments for cancellation
  final pendingAppointments = myAppointments
      .where((appt) => appt.appointmentStatus == AppointmentStatus.pending)
      .toList();

  if (pendingAppointments.isEmpty) return;

  stdout.write('\nDo you want to cancel a pending appointment? (y/n): ');
  final cancelInput = stdin.readLineSync();
  if (cancelInput?.toLowerCase() != 'y') return;

  print('\n--- PENDING APPOINTMENTS ---');
  for (var i = 0; i < pendingAppointments.length; i++) {
    final appt = pendingAppointments[i];
    final doctorList = appointmentManager.allUsers
        .where((u) => u.id == appt.doctorId && u.type == UserType.doctor)
        .toList();

    String doctorName;
    if (doctorList.isEmpty) {
      doctorName = '[Deleted Doctor]';
    } else {
      final doctor = doctorList.first as Doctor;
      doctorName = 'Dr. ${doctor.username}';
    }

    final dateStr =
        '${appt.dateTime.year}-${appt.dateTime.month.toString().padLeft(2, '0')}-${appt.dateTime.day.toString().padLeft(2, '0')}';
    final timeStr = formatTime(appt.dateTime);

    print('${i + 1}. $doctorName on $dateStr at $timeStr');
  }

  stdout.write('Enter the number of the appointment to cancel: ');
  final input = stdin.readLineSync();
  final choice = int.tryParse(input ?? '');
  if (choice == null || choice < 1 || choice > pendingAppointments.length) {
    print('Invalid selection.');
    return;
  }

  final toCancel = pendingAppointments[choice - 1];
  appointmentManager.allAppointments.remove(toCancel);

  print('✅ Appointment canceled successfully!');
}

}
