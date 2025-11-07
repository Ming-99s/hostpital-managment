import 'dart:io';
import 'package:test/test.dart';

// Relative imports to the nested lib directory
import '../hostpital-managment/lib/data/User_file.dart';
import '../hostpital-managment/lib/data/appointments_file.dart';
import '../hostpital-managment/lib/domain/user.dart';
import '../hostpital-managment/lib/domain/patient.dart';
import '../hostpital-managment/lib/domain/doctor.dart';
import '../hostpital-managment/lib/domain/appointment.dart';
import '../hostpital-managment/lib/domain/appointmentManager.dart';
import '../hostpital-managment/lib/domain/authService.dart';

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

  group('AppointmentManager: booking and approving', () {
    test('Books and approves an appointment, removing doctor slot', () {
      final userRepo = UserRepository('hostpital-managment/lib/data/users.json');
      final appRepo = AppointmentRepository('hostpital-managment/lib/data/appointments.json');
      final users = userRepo.readUsers();
      final appointments = appRepo.readAppointments();

      final mgr = AppointmentManager(users: users, appointments: appointments);

      final patient = users.firstWhere((u) => u.type == UserType.patient);
      final doctor = users.whereType<Doctor>().first;

      // Add a new future slot to ensure availability
      final futureSlot = DateTime.now().add(const Duration(days: 3));
      final normalizedSlot = DateTime(futureSlot.year, futureSlot.month, futureSlot.day, 9, 0); // 9:00 AM
      doctor.availableSlots.add(normalizedSlot);
      expect(doctor.availableSlots.contains(normalizedSlot), true);

      final appt = mgr.bookAppointment(patient.id, doctor.id, normalizedSlot);
      expect(appt, isNotNull, reason: 'Appointment should be booked when slot is available');
      expect(appt!.appointmentStatus, AppointmentStatus.pending);
      expect(mgr.allAppointments.any((a) => a.appointmentId == appt.appointmentId), true);

      mgr.approveAppointment(appt.appointmentId);
      expect(appt.appointmentStatus, AppointmentStatus.approved);
      expect(doctor.availableSlots.contains(normalizedSlot), false, reason: 'Approved slot should be removed');
    });
  });

  group('AuthService: register and login', () {
    test('Registers patient and doctor, rejects duplicates and admin registration', () {
      final userRepo = UserRepository('hostpital-managment/lib/data/users.json');
      final appRepo = AppointmentRepository('hostpital-managment/lib/data/appointments.json');
      final users = userRepo.readUsers();
      final appointments = appRepo.readAppointments();

      final mgr = AppointmentManager(users: users, appointments: appointments);
      final auth = AuthService(users: users, appointmentManager: mgr);

      final initialCount = auth.allUsers.length;

      // Register a new patient
      final newPatient = auth.register(
        type: UserType.patient,
        username: 'test_patient_${DateTime.now().millisecondsSinceEpoch}',
        password: 'p@ss',
        email: 'patient@test.com',
        address: '123 Test Street',
        age: 30,
        gender: Gender.male,
      );
      expect(newPatient is Patient, true);

      // Register a new doctor
      final newDoctor = auth.register(
        type: UserType.doctor,
        username: 'test_doctor_${DateTime.now().millisecondsSinceEpoch}',
        password: 'p@ss',
        email: 'doctor@test.com',
        address: '456 Clinic Road',
        specialty: Specialty.cardiology,
      );
      expect(newDoctor is Doctor, true);

      expect(auth.allUsers.length, initialCount + 2);

      // Duplicate username should throw
      expect(
        () => auth.register(
          type: UserType.patient,
          username: newPatient.username,
          password: 'x',
          email: 'dup@test.com',
          address: 'dup',
          age: 20,
          gender: Gender.female,
        ),
        throwsA(isA<Exception>()),
      );

      // Cannot register admin
      expect(
        () => auth.register(
          type: UserType.admin,
          username: 'no_admin',
          password: 'x',
        ),
        throwsA(isA<Exception>()),
      );

      // Login success and failure
      final anyUser = users.first;
      final loggedIn = auth.login(username: anyUser.username, password: anyUser.password);
      expect(loggedIn.username, anyUser.username);

      expect(
        () => auth.login(username: anyUser.username, password: 'wrong'),
        throwsA(isA<Exception>()),
      );
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