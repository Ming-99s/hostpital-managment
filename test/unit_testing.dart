import 'dart:io';
import 'package:test/test.dart';

// Relative imports to the nested lib directory
import '../hostpital-managment/lib/data/Repository/User_file.dart';
import '../hostpital-managment/lib/data/Repository/appointments_file.dart';
import '../hostpital-managment/lib/domain/user.dart';
import '../hostpital-managment/lib/domain/patient.dart';
import '../hostpital-managment/lib/domain/doctor.dart';
import '../hostpital-managment/lib/domain/appointment.dart';
import '../hostpital-managment/lib/domain/Service/appointmentManager.dart';
import '../hostpital-managment/lib/domain/Service/userManager.dart';
import '../hostpital-managment/lib/domain/Service/authService.dart';

void main() {
  group('Main wiring: repositories and services', () {
    test('Reads users and appointments from JSON', () {
      final userRepo = UserRepository('hostpital-managment/lib/data/users.json');
      final appRepo = AppointmentRepository('hostpital-managment/lib/data/appointments.json');

      final users = userRepo.readUsers();
      final appointments = appRepo.readAppointments();

      expect(users.isNotEmpty, true, reason: 'users.json should have users');
      expect(appointments.isNotEmpty, true, reason: 'appointments.json should have appointments');

      // Validate types present
      expect(users.any((u) => u.type == UserType.admin), true, reason: 'Should contain an admin');
      expect(users.any((u) => u.type == UserType.patient), true, reason: 'Should contain a patient');
      expect(users.any((u) => u.type == UserType.doctor), true, reason: 'Should contain a doctor');

      // Validate doctor slots parsed
      final doctor = users.whereType<Doctor>().first;
      expect(doctor.availableSlots, isNotEmpty, reason: 'Doctor should have available slots');

      // Validate appointment status parsing
      expect(AppointmentStatus.values.contains(appointments.first.appointmentStatus), true);
    });
  });

  group('AppointmentManager: booking', () {
    test('Adds a pending appointment then approves to remove doctor slot', () {
      final userRepo = UserRepository('hostpital-managment/lib/data/users.json');
      final appRepo = AppointmentRepository('hostpital-managment/lib/data/appointments.json');
      final userMgr = UserManager(userRepository: userRepo);
      final apptMgr = AppointmentManager(appRepo, userMgr);

      final users = userMgr.getallUser();
      final patient = users.firstWhere((u) => u.type == UserType.patient) as Patient;
      final doctor = users.whereType<Doctor>().first;

      // Add a new future slot to ensure availability
      final futureSlot = DateTime.now().add(const Duration(days: 3));
      final normalizedSlot = DateTime(futureSlot.year, futureSlot.month, futureSlot.day, 9, 0); // 9:00 AM
      doctor.availableSlots.add(normalizedSlot);
      // persist doctor with new slot
      userMgr.updateDoctor(doctor, users);
      expect(userMgr.getDoctorById(doctor.id)!.availableSlots.contains(normalizedSlot), true);

      // Create a pending appointment for that slot
      final appt = Appointment(
        patientId: patient.id,
        doctorId: doctor.id,
        dateTime: normalizedSlot,
        appointmentStatus: AppointmentStatus.pending,
      );
      apptMgr.addAppointment(appt);

      // Ensure it was added
      expect(
        apptMgr.getAllAppointment().any((a) => a.appointmentId == appt.appointmentId),
        true,
      );

      // Approve the appointment which should remove the slot
      apptMgr.approveAppointment(appt.appointmentId);

      final doctorReloaded = userMgr.getDoctorById(doctor.id)!;
      expect(doctorReloaded.availableSlots.contains(normalizedSlot), false,
          reason: 'Approved appointment should remove the slot');
    });
  });

  group('AuthService: register and login', () {
    test('Registers patient and doctor, rejects duplicates; login works', () {
      final userRepo = UserRepository('hostpital-managment/lib/data/users.json');
      final appRepo = AppointmentRepository('hostpital-managment/lib/data/appointments.json');
      final userMgr = UserManager(userRepository: userRepo);
      final apptMgr = AppointmentManager(appRepo, userMgr);
      final auth = AuthService(userManager: userMgr, appointmentManager: apptMgr);

      final initialCount = userMgr.getallUser().length;

      // Register a new patient (use intentionally invalid email per current validation logic)
      final newPatient = auth.registerPatient(
        'test_patient_${DateTime.now().millisecondsSinceEpoch}',
        'p@ss',
        'patient_test',
        30,
        '123 Test Street',
        Gender.male,
      );
      expect(newPatient is Patient, true);

      // Register a new doctor (use intentionally invalid email per current validation logic)
      final newDoctor = auth.registerDoctor(
        'test_doctor_${DateTime.now().millisecondsSinceEpoch}',
        'p@ss',
        'doctor_test',
        Specialty.cardiology,
        <DateTime>[],
        '456 Clinic Road',
      );
      expect(newDoctor is Doctor, true);

      expect(userMgr.getallUser().length, initialCount + 2);

      // Duplicate username should throw
      expect(
        () => auth.registerPatient(
          newPatient!.username,
          'x',
          'dup_email',
          20,
          'dup',
          Gender.female,
        ),
        throwsA(isA<Exception>()),
      );

      // Login success and failure (login returns null on failure)
      final anyUser = userMgr.getallUser().first;
      final loggedIn = auth.login(anyUser.username, anyUser.password);
      expect(loggedIn?.username, anyUser.username);

      final failed = auth.login(anyUser.username, 'wrong');
      expect(failed, isNull);
    });
  });

  group('Repositories: write to temp and read back', () {
    test('Writes users and appointments to temp files and reloads', () {
      final userRepoSrc = UserRepository('hostpital-managment/lib/data/users.json');
      final appRepoSrc = AppointmentRepository('hostpital-managment/lib/data/appointments.json');
      final users = userRepoSrc.readUsers();
      final appointments = appRepoSrc.readAppointments();

      final tempDir = Directory.systemTemp.createTempSync('appt_sys_test');
      try {
        final tempUsersPath = '${tempDir.path}${Platform.pathSeparator}users_tmp.json';
        final tempApptsPath = '${tempDir.path}${Platform.pathSeparator}appointments_tmp.json';

        final userRepoTmp = UserRepository(tempUsersPath);
        final appRepoTmp = AppointmentRepository(tempApptsPath);

        userRepoTmp.writeUsers(users);
        appRepoTmp.writeAppointments(appointments);

        final usersReloaded = userRepoTmp.readUsers();
        final apptsReloaded = appRepoTmp.readAppointments();

        expect(usersReloaded.length, users.length);
        expect(apptsReloaded.length, appointments.length);
        expect(usersReloaded.any((u) => u.type == UserType.admin), true);
      } finally {
        // Cleanup temp files
        try {
          tempDir.deleteSync(recursive: true);
        } catch (_) {
          // ignore cleanup errors on Windows if file handles linger
        }
      }
    });
  });
}