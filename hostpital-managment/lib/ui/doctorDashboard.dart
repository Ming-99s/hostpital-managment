import 'dart:io';
import '../domain/Service/appointmentManager.dart';
import '../domain/Service/userManager.dart';
import '../domain/Service/doctorService.dart';
import '../domain/user.dart';
import '../domain/doctor.dart';
import '../domain/appointment.dart';

class DoctorDashboard {
  final AppointmentManager appointmentManager;
  final UserManager userManager;
  late final DoctorService doctorService;

  DoctorDashboard(this.appointmentManager, this.userManager) {
    doctorService = DoctorService(
      appointmentManager: appointmentManager,
      userManager: userManager,
    );
  }

  void startDoctorDashboard(User doctorUser) {
    if (doctorUser.type != UserType.doctor) {
      print('❌ Only doctors can access this dashboard.');
      return;
    }

    final Doctor doctor = doctorUser as Doctor;

    while (true) {
      print('\n====================================');
      print('   👨‍⚕️ DOCTOR DASHBOARD');
      print('   Welcome, Dr. ${doctor.username.toUpperCase()}');
      print('   Specialty: ${userManager.formatSpecialty(doctor.specialty)}');
      print('====================================');
      print('1. 🗓️ My Schedule');
      print('2. 📋 My Appointments');
      print('3. 📅 Today\'s Appointments');
      print('4. 🧾 Appointment History');
      print('5. ⚙️ Manage Availability');
      print('6. 🚪 Logout');
      print('------------------------------------');
      stdout.write('Enter your choice: ');
      final String? choice = stdin.readLineSync();

      switch (choice) {
        case '1':
          _viewMySchedule(doctor);
          break;
        case '2':
          _viewMyAppointments(doctor);
          break;
        case '3':
          _viewTodaysAppointments(doctor);
          break;
        case '4':
          _viewAppointmentHistory(doctor);
          break;
        case '5':
          _manageAvailability(doctor);
          break;
        case '6':
          print('\n👋 Logging out. Goodbye!');
          return;
        default:
          print('❌ Invalid choice. Please try again.');
      }
    }
  }

  void _viewMySchedule(Doctor doctor) {
    final grouped = doctorService.getScheduleGroupedByDate(doctor);

    print('\n🗓️ === MY SCHEDULE ===');
    if (grouped.isEmpty) {
      print('📭 No available slots set.');
      _pressEnterToContinue();
      return;
    }

    for (final date in grouped.keys) {
      print('\n📅 $date:');
      final slots = grouped[date]!;
      for (final slot in slots) {
        print('   • ${doctorService.formatTime(slot)}');
      }
    }
    _pressEnterToContinue();
  }

  void _viewMyAppointments(Doctor doctor) {
    final myAppointments = doctorService.getAppointmentsForDoctor(doctor);

    if (myAppointments.isEmpty) {
      print('\n📭 No appointments found.');
      _pressEnterToContinue();
      return;
    }

    print('\n📋 === MY APPOINTMENTS ===');
    for (var i = 0; i < myAppointments.length; i++) {
      final appt = myAppointments[i];
      final patientName = doctorService.getPatientName(appt.patientId);
      print('\n${i + 1}. ${_getStatusEmoji(appt.appointmentStatus)} Appointment #${appt.appointmentId}');
      print('   Patient: $patientName');
      print('   Date: ${doctorService.formatDate(appt.dateTime)} at ${doctorService.formatTime(appt.dateTime)}');
      print('   Status: ${appt.appointmentStatus.name.toUpperCase()}');
    }
    _pressEnterToContinue();
  }

  void _viewTodaysAppointments(Doctor doctor) {
    final now = DateTime.now();
    final todayAppts = doctorService.getTodaysAppointments(doctor, now);

    print('\n📅 === TODAY\'S APPOINTMENTS ===');
    if (todayAppts.isEmpty) {
      print('📭 No appointments scheduled for today.');
      _pressEnterToContinue();
      return;
    }

    for (var i = 0; i < todayAppts.length; i++) {
      final appt = todayAppts[i];
      final patientName = doctorService.getPatientName(appt.patientId);
      print('\n${i + 1}. ${_getStatusEmoji(appt.appointmentStatus)} ${doctorService.formatTime(appt.dateTime)}');
      print('   Patient: $patientName');
      print('   Status: ${appt.appointmentStatus.name.toUpperCase()}');
    }
    _pressEnterToContinue();
  }

  void _viewAppointmentHistory(Doctor doctor) {
    final now = DateTime.now();
    final history = doctorService.getAppointmentHistory(doctor, now);

    print('\n🧾 === APPOINTMENT HISTORY ===');
    if (history.isEmpty) {
      print('📭 No past appointments found.');
      _pressEnterToContinue();
      return;
    }

    for (var i = 0; i < history.length; i++) {
      final appt = history[i];
      final patientName = doctorService.getPatientName(appt.patientId);
      print('\n${i + 1}. ${_getStatusEmoji(appt.appointmentStatus)} Appointment #${appt.appointmentId}');
      print('   Patient: $patientName');
      print('   Date: ${doctorService.formatDate(appt.dateTime)} at ${doctorService.formatTime(appt.dateTime)}');
      print('   Status: ${appt.appointmentStatus.name.toUpperCase()}');
    }
    _pressEnterToContinue();
  }

  void _manageAvailability(Doctor doctor) {
    while (true) {
      print('\n⚙️ === MANAGE AVAILABILITY ===');
      print('1. ➕ Add Time Slot');
      print('2. 🗑️ Remove Time Slot');
      print('3. ↩️ Back');
      stdout.write('Enter your choice: ');
      final String? choice = stdin.readLineSync();

      switch (choice) {
        case '1':
          _addTimeSlot(doctor);
          break;
        case '2':
          _removeTimeSlot(doctor);
          break;
        case '3':
          return;
        default:
          print('❌ Invalid choice.');
      }
    }
  }

  void _addTimeSlot(Doctor doctor) {
    stdout.write('\nEnter date (YYYY-MM-DD): ');
    final dateStr = stdin.readLineSync()?.trim();
    stdout.write('Enter time (HH:MM 24h): ');
    final timeStr = stdin.readLineSync()?.trim();

    if (dateStr == null || timeStr == null) {
      print('❌ Invalid input.');
      _pressEnterToContinue();
      return;
    }

    final dt = doctorService.parseDateTime(dateStr, timeStr);
    if (dt == null) {
      print('❌ Could not parse date/time.');
      _pressEnterToContinue();
      return;
    }

    final ok = doctorService.addTimeSlot(doctor, dt);
    if (!ok) {
      print('❌ Slot is invalid or already exists.');
    } else {
      print('✅ Slot added: ${doctorService.formatDate(dt)} ${doctorService.formatTime(dt)}');
    }
    _pressEnterToContinue();
  }

  void _removeTimeSlot(Doctor doctor) {
    final slots = doctorService.getSchedule(doctor);
    if (slots.isEmpty) {
      print('\n📭 No slots to remove.');
      _pressEnterToContinue();
      return;
    }

    print('\n🗓️ Select a slot to remove:');
    for (var i = 0; i < slots.length; i++) {
      final s = slots[i];
      print('${i + 1}. ${doctorService.formatDate(s)} ${doctorService.formatTime(s)}');
    }

    stdout.write('Enter number: ');
    final input = stdin.readLineSync();
    final choice = int.tryParse(input ?? '');
    if (choice == null) {
      print('❌ Invalid selection.');
      _pressEnterToContinue();
      return;
    }

    final ok = doctorService.removeTimeSlotByIndex(doctor, choice - 1);
    if (!ok) {
      print('❌ Invalid selection.');
    } else {
      print('✅ Slot removed.');
    }
    _pressEnterToContinue();
  }

  // UI-only helpers
  String _getStatusEmoji(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.pending:
        return '⏳';
      case AppointmentStatus.approved:
        return '✅';
      case AppointmentStatus.rejected:
        return '❌';
      case AppointmentStatus.canceled:
        return '🚫';
    }
  }

  void _pressEnterToContinue() {
    stdout.write('\nPress Enter to continue...');
    stdin.readLineSync();
  }
}