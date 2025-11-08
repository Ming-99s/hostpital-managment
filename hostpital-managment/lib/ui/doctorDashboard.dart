import 'dart:io';
import '../domain/Service/appointmentManager.dart';
import '../domain/user.dart';
import '../domain/doctor.dart'; 
import '../domain/appointment.dart';

class DoctorDashboard {
  final AppointmentManager appointmentManager;

  DoctorDashboard(this.appointmentManager);

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
      print('   Specialty: ${_formatSpecialty(doctor.specialty)}');
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

  // === My Schedule ===
  void _viewMySchedule(Doctor doctor) {
    final slots = List<DateTime>.from(doctor.availableSlots);

    print('\n🗓️ === MY SCHEDULE ===');
    if (slots.isEmpty) {
      print('📭 No available slots set.');
      _pressEnterToContinue();
      return;
    }

    // Group by date
    final grouped = <String, List<DateTime>>{};
    for (final slot in slots) {
      final dateKey = _dateKey(slot);
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(slot);
    }

    for (final date in grouped.keys) {
      print('\n📅 $date:');
      grouped[date]!.sort((a, b) => a.compareTo(b));
      for (final slot in grouped[date]!) {
        print('   • ${_formatTime(slot)}');
      }
    }
    _pressEnterToContinue();
  }

  // === My Appointments (upcoming or all non-historic) ===
  void _viewMyAppointments(Doctor doctor) {
    final myAppointments = appointmentManager.allAppointments
        .where((a) => a.doctorId == doctor.id)
        .toList();

    if (myAppointments.isEmpty) {
      print('\n📭 No appointments found.');
      _pressEnterToContinue();
      return;
    }

    print('\n📋 === MY APPOINTMENTS ===');
    myAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    for (var i = 0; i < myAppointments.length; i++) {
      final appt = myAppointments[i];
      final patientName = _getPatientName(appt.patientId);
      print('\n${i + 1}. ${_getStatusEmoji(appt.appointmentStatus)} Appointment #${appt.appointmentId}');
      print('   Patient: $patientName');
      print('   Date: ${_formatDate(appt.dateTime)} at ${_formatTime(appt.dateTime)}');
      print('   Status: ${appt.appointmentStatus.name.toUpperCase()}');
    }
    _pressEnterToContinue();
  }

  // === Today\'s Appointments ===
  void _viewTodaysAppointments(Doctor doctor) {
    final now = DateTime.now();
    final todayAppts = appointmentManager.allAppointments
        .where((a) => a.doctorId == doctor.id)
        .where((a) => a.dateTime.year == now.year && a.dateTime.month == now.month && a.dateTime.day == now.day)
        .toList();

    print('\n📅 === TODAY\'S APPOINTMENTS ===');
    if (todayAppts.isEmpty) {
      print('📭 No appointments scheduled for today.');
      _pressEnterToContinue();
      return;
    }

    todayAppts.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    for (var i = 0; i < todayAppts.length; i++) {
      final appt = todayAppts[i];
      final patientName = _getPatientName(appt.patientId);
      print('\n${i + 1}. ${_getStatusEmoji(appt.appointmentStatus)} ${_formatTime(appt.dateTime)}');
      print('   Patient: $patientName');
      print('   Status: ${appt.appointmentStatus.name.toUpperCase()}');
    }
    _pressEnterToContinue();
  }

  // === Appointment History (past appointments) ===
  void _viewAppointmentHistory(Doctor doctor) {
    final now = DateTime.now();
    final history = appointmentManager.allAppointments
        .where((a) => a.doctorId == doctor.id)
        .where((a) => a.dateTime.isBefore(now))
        .toList();

    print('\n🧾 === APPOINTMENT HISTORY ===');
    if (history.isEmpty) {
      print('📭 No past appointments found.');
      _pressEnterToContinue();
      return;
    }

    history.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    for (var i = 0; i < history.length; i++) {
      final appt = history[i];
      final patientName = _getPatientName(appt.patientId);
      print('\n${i + 1}. ${_getStatusEmoji(appt.appointmentStatus)} Appointment #${appt.appointmentId}');
      print('   Patient: $patientName');
      print('   Date: ${_formatDate(appt.dateTime)} at ${_formatTime(appt.dateTime)}');
      print('   Status: ${appt.appointmentStatus.name.toUpperCase()}');
    }
    _pressEnterToContinue();
  }

  // === Manage Availability ===
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
    final dateStr = stdin.readLineSync();
    if (dateStr == null || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateStr.trim())) {
      // Allow non-strict; we will try parse below anyway
    }

    stdout.write('Enter time (HH:MM 24h): ');
    final timeStr = stdin.readLineSync();

    if (dateStr == null || timeStr == null) {
      print('❌ Invalid input.');
      _pressEnterToContinue();
      return;
    }

    final dt = _parseDateTime(dateStr.trim(), timeStr.trim());
    if (dt == null) {
      print('❌ Could not parse date/time.');
      _pressEnterToContinue();
      return;
    }

    // Reject past or present (must be strictly in the future)
    final now = DateTime.now();
    if (!dt.isAfter(now)) {
      print('❌ Selected time is in the past. Please choose a future time.');
      _pressEnterToContinue();
      return;
    }

    if (doctor.availableSlots.any((s) => _sameMinute(s, dt))) {
      print('⚠️ Slot already exists.');
    } else {
      doctor.availableSlots.add(dt);
      doctor.availableSlots.sort((a, b) => a.compareTo(b));
      print('✅ Slot added: ${_formatDate(dt)} ${_formatTime(dt)}');
    }
    _pressEnterToContinue();
  }

  void _removeTimeSlot(Doctor doctor) {
    if (doctor.availableSlots.isEmpty) {
      print('\n📭 No slots to remove.');
      _pressEnterToContinue();
      return;
    }

    print('\n🗓️ Select a slot to remove:');
    for (var i = 0; i < doctor.availableSlots.length; i++) {
      final s = doctor.availableSlots[i];
      print('${i + 1}. ${_formatDate(s)} ${_formatTime(s)}');
    }

    stdout.write('Enter number: ');
    final input = stdin.readLineSync();
    final choice = int.tryParse(input ?? '');
    if (choice == null || choice < 1 || choice > doctor.availableSlots.length) {
      print('❌ Invalid selection.');
      _pressEnterToContinue();
      return;
    }

    final removed = doctor.availableSlots.removeAt(choice - 1);
    print('✅ Removed slot: ${_formatDate(removed)} ${_formatTime(removed)}');
    _pressEnterToContinue();
  }

  // === Helpers ===
  String _getPatientName(String patientId) {
    try {
      final patient = appointmentManager.allUsers
          .firstWhere((u) => u.id == patientId && u.type == UserType.patient);
      return patient.username;
    } catch (_) {
      return '[Unknown Patient]';
    }
  }

  String _getStatusEmoji(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.pending:
        return '⏳';
      case AppointmentStatus.approved:
        return '✅';
      case AppointmentStatus.reject:
        return '❌';
      case AppointmentStatus.canceled:
        return '🚫';
    }
  }

  String _formatSpecialty(Specialty specialty) {
    return specialty.toString().split('.').last.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (m) => ' ${m.group(0)}',
    ).trim();
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  bool _sameMinute(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day && a.hour == b.hour && a.minute == b.minute;

  DateTime? _parseDateTime(String date, String time) {
    try {
      final dateParts = date.split('-').map(int.parse).toList();
      final timeParts = time.split(':').map(int.parse).toList();
      return DateTime(dateParts[0], dateParts[1], dateParts[2], timeParts[0], timeParts[1]);
    } catch (_) {
      return null;
    }
  }

  void _pressEnterToContinue() {
    stdout.write('\nPress Enter to continue...');
    stdin.readLineSync();
  }
}