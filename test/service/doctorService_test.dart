import 'dart:io';
import 'package:test/test.dart';

import '../../hostpital-managment/lib/data/Repository/User_file.dart';
import '../../hostpital-managment/lib/data/Repository/appointments_file.dart';
import '../../hostpital-managment/lib/domain/Service/userManager.dart';
import '../../hostpital-managment/lib/domain/Service/appointmentManager.dart';
import '../../hostpital-managment/lib/domain/Service/doctorService.dart';
import '../../hostpital-managment/lib/domain/doctor.dart';
import '../../hostpital-managment/lib/domain/appointment.dart';

void main() {
  late File userFile;
  late File appointmentFile;
  late UserRepository userRepo;
  late AppointmentRepository appointmentRepo;
  late UserManager userManager;
  late AppointmentManager appointmentManager;
  late DoctorService doctorService;

  // Fixture IDs from test JSON
  const String doctorId = '476ece1d-d670-479b-8847-f3f4032e4c0d'; // dr_filter
  const String patientId = '586bae66-bc18-4528-8263-33e15efe8a6b'; // pat1
  const String apptA1 = 'a1'; // approved
  const String apptA2 = 'a2'; // pending
  const String apptA3 = 'a3'; // past approved

  late Doctor doctor;
  late DateTime a1Date;
  late DateTime a2Date;

  setUp(() {
    userFile = File('test/test_users.json');
    appointmentFile = File('test/test_appointments.json');

    userRepo = UserRepository(userFile.path);
    appointmentRepo = AppointmentRepository(appointmentFile.path);

    userManager = UserManager(userRepository: userRepo);
    appointmentManager = AppointmentManager(appointmentRepo, userManager);
    doctorService = DoctorService(appointmentManager: appointmentManager, userManager: userManager);

    final d = userManager.getDoctorById(doctorId);
    if (d == null) {
      throw Exception('Test fixture doctor not found');
    }
    doctor = d;

    final a1 = appointmentManager.getAppointmentById(apptA1);
    final a2 = appointmentManager.getAppointmentById(apptA2);
    if (a1 == null || a2 == null) {
      throw Exception('Test fixture appointments not found');
    }
    a1Date = a1.dateTime;
    a2Date = a2.dateTime;
  });

  tearDown(() {
    // Reset appointments to their original statuses for repeatable tests
    final a1 = appointmentManager.getAppointmentById(apptA1);
    if (a1 != null) {
      a1.appointmentStatus = AppointmentStatus.approved;
      appointmentManager.updateAppointment(a1, appointmentManager.getAllAppointment());
    }

    final a2 = appointmentManager.getAppointmentById(apptA2);
    if (a2 != null) {
      a2.appointmentStatus = AppointmentStatus.pending;
      appointmentManager.updateAppointment(a2, appointmentManager.getAllAppointment());
    }

    // Ensure doctor has at least one slot; add current time if empty
    final freshDoctor = userManager.getDoctorById(doctorId);
    if (freshDoctor != null) {
      if (freshDoctor.availableSlots.isEmpty) {
        freshDoctor.availableSlots.add(DateTime.now().add(Duration(minutes: 5)));
      }
      userManager.updateDoctor(freshDoctor, userManager.getallUser());
    }
  });

  group('DoctorService - Appointments and Lookups', () {
    test('getAppointmentsForDoctor filters and sorts by time', () {
      final appts = doctorService.getAppointmentsForDoctor(doctor);
      expect(appts.length, 3);
      expect(appts.first.appointmentId, apptA3); // 2025-11-08 first
      expect(appts.last.appointmentId, apptA2);  // later on 2025-11-09
    });

    test('getPatientName returns username for known patient', () {
      final name = doctorService.getPatientName(patientId);
      expect(name, 'pat1');
    });
  });

  group('DoctorService - Actions', () {
    test('approveAppointment updates status when slot matches', () {
      // Prepare: ensure doctor has an available slot exactly matching a2
      final freshDoctor = userManager.getDoctorById(doctorId)!;
      final hasSlot = freshDoctor.availableSlots.any((s) => s.year == a2Date.year && s.month == a2Date.month && s.day == a2Date.day && s.hour == a2Date.hour && s.minute == a2Date.minute);
      if (!hasSlot) {
        freshDoctor.availableSlots.add(a2Date);
        userManager.updateDoctor(freshDoctor, userManager.getallUser());
      }

      final ok = doctorService.approveAppointment(freshDoctor, apptA2);
      expect(ok, isTrue);

      final updated = appointmentManager.getAppointmentById(apptA2);
      expect(updated, isNotNull);
      expect(updated!.appointmentStatus, AppointmentStatus.approved);
    });

    test('rejectAppointment sets pending to rejected', () {
      // Ensure pending
      final a2 = appointmentManager.getAppointmentById(apptA2);
      if (a2 == null) return;
      a2.appointmentStatus = AppointmentStatus.pending;
      appointmentManager.updateAppointment(a2, appointmentManager.getAllAppointment());

      final ok = doctorService.rejectAppointment(doctor, apptA2);
      expect(ok, isTrue);

      final updated = appointmentManager.getAppointmentById(apptA2);
      expect(updated, isNotNull);
      expect(updated!.appointmentStatus, AppointmentStatus.rejected);
    });

    test('cancelAppointment returns slot for approved appointment', () {
      // Ensure approved
      final a1 = appointmentManager.getAppointmentById(apptA1);
      if (a1 == null) return;
      a1.appointmentStatus = AppointmentStatus.approved;
      appointmentManager.updateAppointment(a1, appointmentManager.getAllAppointment());

      final ok = doctorService.cancelAppointment(doctor, apptA1);
      expect(ok, isTrue);

      final updated = appointmentManager.getAppointmentById(apptA1);
      expect(updated, isNotNull);
      expect(updated!.appointmentStatus, AppointmentStatus.canceled);

      // Slot should be returned to doctor
      final freshDoctor = userManager.getDoctorById(doctorId)!;
      final hasReturnedSlot = freshDoctor.availableSlots.any((s) => s.year == a1Date.year && s.month == a1Date.month && s.day == a1Date.day && s.hour == a1Date.hour && s.minute == a1Date.minute);
      expect(hasReturnedSlot, isTrue);
    });
  });

  group('DoctorService - Utilities', () {
    test('parseDateTime, formatDate and formatTime', () {
      final dt = doctorService.parseDateTime('2025-12-01', '14:05');
      expect(dt, isNotNull);
      expect(doctorService.formatDate(dt!), '2025-12-01');
      expect(doctorService.formatTime(dt), '2:05 PM');

      final invalid = doctorService.parseDateTime('2025/12/01', 'aa:bb');
      expect(invalid, isNull);
    });

    test('addTimeSlot prevents past/duplicate and remove by index works', () {
      final d = userManager.getDoctorById(doctorId)!;
      final futureSlot = DateTime.now().add(Duration(days: 3, hours: 1));

      // Add new future slot
      final added = doctorService.addTimeSlot(d, futureSlot);
      expect(added, isTrue);

      // Adding duplicate minute should fail
      final dup = doctorService.addTimeSlot(d, futureSlot);
      expect(dup, isFalse);

      // Remove the slot we just added
      final idx = d.availableSlots.indexWhere((s) => s.year == futureSlot.year && s.month == futureSlot.month && s.day == futureSlot.day && s.hour == futureSlot.hour && s.minute == futureSlot.minute);
      expect(idx >= 0, isTrue);
      final removed = doctorService.removeTimeSlotByIndex(d, idx);
      expect(removed, isTrue);
    });
  });
}