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
    final doctors = appointmentManager.allUsers
        .where((u) => u.type == UserType.doctor)
        .cast<Doctor>()
        .toList();

    if (doctors.isEmpty) {
      print('\n😔 No doctors currently available in the system.');
      _pressEnterToContinue();
      return;
    }

    print('\n👨‍⚕️ === BOOK NEW APPOINTMENT ===');
    
    // Show doctors by specialty
    _displayDoctorsBySpecialty(doctors);

    stdout.write('\n🎯 Select a doctor by number: ');
    final docNum = stdin.readLineSync();
    if (docNum == null) return;

    final doctorChoice = int.tryParse(docNum);
    if (doctorChoice == null || doctorChoice < 1 || doctorChoice > doctors.length) {
      print('❌ Invalid doctor selection.');
      _pressEnterToContinue();
      return;
    }

    final selectedDoctor = doctors[doctorChoice - 1];
    _bookWithDoctor(patient, selectedDoctor);
  }

  void _displayDoctorsBySpecialty(List<Doctor> doctors) {
    final doctorsBySpecialty = <Specialty, List<Doctor>>{};
    
    for (var doctor in doctors) {
      if (!doctorsBySpecialty.containsKey(doctor.specialty)) {
        doctorsBySpecialty[doctor.specialty] = [];
      }
      doctorsBySpecialty[doctor.specialty]!.add(doctor);
    }

    var doctorIndex = 1;
    for (var specialty in doctorsBySpecialty.keys) {
      print('\n🎯 ${_formatSpecialty(specialty)}:');
      for (var doctor in doctorsBySpecialty[specialty]!) {
        final availableSlots = doctor.availableSlots.length;
        final slotInfo = availableSlots > 0 ? '($availableSlots available slot${availableSlots > 1 ? 's' : ''})' : '(No slots)';
        print('   $doctorIndex. Dr. ${doctor.username} $slotInfo');
        doctorIndex++;
      }
    }
  }

  void _bookWithDoctor(User patient, Doctor doctor) {
    final availableSlots = doctor.availableSlots;
    
    if (availableSlots.isEmpty) {
      print('\n😔 Dr. ${doctor.username} has no available slots at the moment.');
      print('   Please check back later or choose another doctor.');
      _pressEnterToContinue();
      return;
    }

    print('\n📅 === AVAILABLE TIME SLOTS ===');
    print('Doctor: Dr. ${doctor.username}');
    print('Specialty: ${_formatSpecialty(doctor.specialty)}');
    print('');

    // Group slots by date
    final slotsByDate = <String, List<DateTime>>{};
    for (var slot in availableSlots) {
      final dateKey = '${slot.year}-${slot.month.toString().padLeft(2, '0')}-${slot.day.toString().padLeft(2, '0')}';
      if (!slotsByDate.containsKey(dateKey)) {
        slotsByDate[dateKey] = [];
      }
      slotsByDate[dateKey]!.add(slot);
    }

    // Display slots by date
    var slotIndex = 1;
    final slotMap = <int, DateTime>{};
    
    for (var date in slotsByDate.keys) {
      print('📅 $date:');
      slotsByDate[date]!.sort((a, b) => a.hour.compareTo(b.hour));
      for (var slot in slotsByDate[date]!) {
        final timeStr = _formatTime(slot);
        print('   $slotIndex. $timeStr');
        slotMap[slotIndex] = slot;
        slotIndex++;
      }
      print('');
    }

    stdout.write('🕒 Select a time slot by number: ');
    final slotNum = stdin.readLineSync();
    if (slotNum == null) return;

    final slotChoice = int.tryParse(slotNum);
    if (slotChoice == null || !slotMap.containsKey(slotChoice)) {
      print('❌ Invalid slot selection.');
      _pressEnterToContinue();
      return;
    }

    final selectedSlot = slotMap[slotChoice]!;

    // Confirm booking
    print('\n✅ === CONFIRM APPOINTMENT ===');
    print('Doctor: Dr. ${doctor.username}');
    print('Specialty: ${_formatSpecialty(doctor.specialty)}');
    print('Date: ${_formatDate(selectedSlot)}');
    print('Time: ${_formatTime(selectedSlot)}');
    
    stdout.write('\nConfirm booking? (y/n): ');
    final confirm = stdin.readLineSync()?.toLowerCase();
    if (confirm != 'y') {
      print('❌ Booking cancelled.');
      _pressEnterToContinue();
      return;
    }

    final newAppointment = appointmentManager.bookAppointment(
      patient.id,
      doctor.id,
      selectedSlot,
    );

    if (newAppointment != null) {
      print('\n🎉 APPOINTMENT BOOKED SUCCESSFULLY!');
      print('┌──────────────────────────────────┐');
      print('│   📋 Appointment Details         │');
      print('├──────────────────────────────────┤');
      print('│ 👨‍⚕️  Doctor: Dr. ${doctor.username}');
      print('│ 🎯 Specialty: ${_formatSpecialty(doctor.specialty)}');
      print('│ 📅 Date: ${_formatDate(selectedSlot)}');
      print('│ 🕒 Time: ${_formatTime(selectedSlot)}');
      print('│ 📝 Status: ${newAppointment.appointmentStatus.name.toUpperCase()}');
      print('│ 🔑 ID: ${newAppointment.appointmentId}');
      print('└──────────────────────────────────┘');
      print('\n💡 You will be notified when the appointment is approved.');
    } else {
      print('\n❌ Failed to book appointment. Please try again.');
    }
    
    _pressEnterToContinue();
  }

  void _viewAppointments(User patient) {
    final myAppointments = appointmentManager.allAppointments
        .where((appt) => appt.patientId == patient.id)
        .toList();

    if (myAppointments.isEmpty) {
      print('\n📭 You have no appointments scheduled.');
      _pressEnterToContinue();
      return;
    }

    // Sort appointments by date
    myAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    print('\n📋 === MY APPOINTMENTS ===');
    
    final pendingAppointments = myAppointments
        .where((appt) => appt.appointmentStatus == AppointmentStatus.pending)
        .toList();
    
    final approvedAppointments = myAppointments
        .where((appt) => appt.appointmentStatus == AppointmentStatus.approved)
        .toList();
    
    final otherAppointments = myAppointments
        .where((appt) => appt.appointmentStatus != AppointmentStatus.pending && 
                        appt.appointmentStatus != AppointmentStatus.approved)
        .toList();

    if (pendingAppointments.isNotEmpty) {
      print('\n⏳ PENDING APPOINTMENTS:');
      _displayAppointmentList(pendingAppointments);
    }

    if (approvedAppointments.isNotEmpty) {
      print('\n✅ APPROVED APPOINTMENTS:');
      _displayAppointmentList(approvedAppointments);
    }

    if (otherAppointments.isNotEmpty) {
      print('\n📊 OTHER APPOINTMENTS:');
      _displayAppointmentList(otherAppointments);
    }

    // Only allow cancellation of pending appointments
    if (pendingAppointments.isNotEmpty) {
      _handleAppointmentCancellation(pendingAppointments);
    } else {
      _pressEnterToContinue();
    }
  }

  void _displayAppointmentList(List<Appointment> appointments) {
    for (var i = 0; i < appointments.length; i++) {
      final appt = appointments[i];
      final doctor = _getDoctorById(appt.doctorId);
      
      final statusEmoji = _getStatusEmoji(appt.appointmentStatus);
      final dateStr = _formatDate(appt.dateTime);
      final timeStr = _formatTime(appt.dateTime);

      if (doctor != null) {
        print('${i + 1}. $statusEmoji Dr. ${doctor.username}');
        print('   📅 $dateStr at $timeStr');
        print('   🎯 ${_formatSpecialty(doctor.specialty)}');
        print('   📝 Status: ${appt.appointmentStatus.name.toUpperCase()}');
      } else {
        print('${i + 1}. $statusEmoji [Doctor Not Found]');
        print('   📅 $dateStr at $timeStr');
        print('   📝 Status: ${appt.appointmentStatus.name.toUpperCase()}');
      }
      print('   ──────────────────────────');
    }
  }

  void _handleAppointmentCancellation(List<Appointment> pendingAppointments) {
    stdout.write('\n❓ Would you like to cancel a pending appointment? (y/n): ');
    final cancelInput = stdin.readLineSync();
    if (cancelInput?.toLowerCase() != 'y') {
      _pressEnterToContinue();
      return;
    }

    print('\n🗑️ === CANCEL APPOINTMENT ===');
    for (var i = 0; i < pendingAppointments.length; i++) {
      final appt = pendingAppointments[i];
      final doctor = _getDoctorById(appt.doctorId);
      final dateStr = _formatDate(appt.dateTime);
      final timeStr = _formatTime(appt.dateTime);

      if (doctor != null) {
        print('${i + 1}. Dr. ${doctor.username} on $dateStr at $timeStr');
      } else {
        print('${i + 1}. [Unknown Doctor] on $dateStr at $timeStr');
      }
    }

    stdout.write('\nEnter the number of appointment to cancel: ');
    final input = stdin.readLineSync();
    final choice = int.tryParse(input ?? '');
    
    if (choice == null || choice < 1 || choice > pendingAppointments.length) {
      print('❌ Invalid selection.');
      _pressEnterToContinue();
      return;
    }

    final toCancel = pendingAppointments[choice - 1];
    final doctor = _getDoctorById(toCancel.doctorId);
    
    // Confirm cancellation
    print('\n⚠️  === CONFIRM CANCELLATION ===');
    if (doctor != null) {
      print('Doctor: Dr. ${doctor.username}');
      print('Date: ${_formatDate(toCancel.dateTime)}');
      print('Time: ${_formatTime(toCancel.dateTime)}');
    }
    
    stdout.write('\nAre you sure you want to cancel this appointment? (y/n): ');
    final confirm = stdin.readLineSync()?.toLowerCase();
    if (confirm != 'y') {
      print('❌ Cancellation aborted.');
      _pressEnterToContinue();
      return;
    }

    appointmentManager.allAppointments.remove(toCancel);
    print('✅ Appointment cancelled successfully!');
    _pressEnterToContinue();
  }


  // Helper Methods
  Doctor? _getDoctorById(String doctorId) {
    try {
      return appointmentManager.allUsers
          .where((user) => user.id == doctorId && user is Doctor)
          .cast<Doctor>()
          .first;
    } catch (e) {
      return null;
    }
  }

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