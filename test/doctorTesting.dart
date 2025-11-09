import 'package:test/test.dart';

import '../hostpital-managment/lib/domain/Service/doctorService.dart';
import '../hostpital-managment/lib/domain/Service/userManager.dart';
import '../hostpital-managment/lib/domain/Service/appointmentManager.dart';
import '../hostpital-managment/lib/data/Repository/User_file.dart';
import '../hostpital-managment/lib/data/Repository/appointments_file.dart';
import '../hostpital-managment/lib/domain/doctor.dart';
import '../hostpital-managment/lib/ui/doctorDashboard.dart';

void main() {
  group('DoctorDashboard & DoctorService', () {
    late UserRepository userRepo;
    late AppointmentRepository appointmentRepo;
    late UserManager userManager;
    late AppointmentManager appointmentManager;
    late DoctorService doctorService;
    late DoctorDashboard dashboard;

    setUp(() {
      userRepo = UserRepository('../hostpital-managment/lib/data/users.json');
      appointmentRepo = AppointmentRepository('../hostpital-managment/lib/data/appointments.json');
      userManager = UserManager(userRepository: userRepo);
      appointmentManager = AppointmentManager(appointmentRepo, userManager);
      doctorService = DoctorService(
        appointmentManager: appointmentManager,
        userManager: userManager,
      );
      dashboard = DoctorDashboard(appointmentManager, userManager);
    });

    test('DoctorDashboard initializes correctly', () {
      expect(dashboard, isNotNull);
    });

    test('DoctorService parses and formats date/time', () {
      final dt = doctorService.parseDateTime('2030-01-01', '09:30');
      expect(dt, isNotNull);
      expect(doctorService.formatDate(dt!), '2030-01-01');
      expect(doctorService.formatTime(dt), '9:30 AM');
    });

    test('DoctorService groups schedule by date', () {
      final testDoctor = Doctor(
        username: 'dr_test',
        password: 'secret',
        address: '123 Street',
        email: 'dr@test.com',
        specialty: Specialty.cardiology,
        availableSlots: [
          DateTime(2030, 1, 1, 9, 0),
          DateTime(2030, 1, 1, 10, 0),
          DateTime(2030, 1, 2, 9, 0),
        ],
      );

      final grouped = doctorService.getScheduleGroupedByDate(testDoctor);
      expect(grouped.containsKey('2030-01-01'), isTrue);
      expect(grouped.containsKey('2030-01-02'), isTrue);
      expect(grouped['2030-01-01']!.length, 2);
      expect(grouped['2030-01-02']!.length, 1);
    });

    test('DoctorService getSchedule returns a copy (immutable to caller)', () {
      final testDoctor = Doctor(
        username: 'dr_copy',
        password: 'secret',
        address: '123 Street',
        email: 'dr@copy.com',
        specialty: Specialty.cardiology,
        availableSlots: [DateTime(2030, 1, 1, 9, 0)],
      );

      final slots = doctorService.getSchedule(testDoctor);
      final originalLength = testDoctor.availableSlots.length;
      slots.add(DateTime(2030, 1, 3, 9, 0));
      expect(testDoctor.availableSlots.length, originalLength);
    });
  });
}

