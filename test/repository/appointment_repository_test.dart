import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';

import '../../hostpital-managment/lib/data/Repository/appointments_file.dart';
import '../../hostpital-managment/lib/domain/appointment.dart';

void main() {
  late File tmpAppointmentsFile;
  late AppointmentRepository appointmentRepo;

  setUp(() {
    // Create a temp copy of the appointments fixture so tests don’t affect shared data
    final fixture = File('test/test_appointments.json');
    tmpAppointmentsFile = File('test/tmp_appointments_repo.json');
    tmpAppointmentsFile.writeAsStringSync(fixture.readAsStringSync());

    appointmentRepo = AppointmentRepository(tmpAppointmentsFile.path);
  });

  tearDown(() {
    if (tmpAppointmentsFile.existsSync()) {
      tmpAppointmentsFile.deleteSync();
    }
  });

  group('AppointmentRepository read and JSON persistence', () {
    test('Reads fixtures and maps to Appointment objects', () {
      final appts = appointmentRepo.readAppointments();
      expect(appts.length, equals(3));

      final a1 = appts.where((a) => a.appointmentId == 'a1').cast<Appointment>().firstOrNull;
      expect(a1, isNotNull);
      expect(a1!.patientId, equals('586bae66-bc18-4528-8263-33e15efe8a6b'));
      expect(a1.doctorId, equals('476ece1d-d670-479b-8847-f3f4032e4c0d'));
      expect(a1.appointmentStatus, equals(AppointmentStatus.approved));
      expect(a1.dateTime.year, equals(2025));
      expect(a1.dateTime.month, equals(11));
    });

    test('Writing appointments persists and reloads correctly', () {
      // Arrange: read existing appointments, append a new one
      final initialAppts = appointmentRepo.readAppointments();
      final newAppt = Appointment(
        appointmentId: 'a_new',
        patientId: '586bae66-bc18-4528-8263-33e15efe8a6b',
        doctorId: '476ece1d-d670-479b-8847-f3f4032e4c0d',
        dateTime: DateTime(2025, 11, 10, 9, 30),
        appointmentStatus: AppointmentStatus.pending,
      );

      final updated = List<Appointment>.from(initialAppts)..add(newAppt);

      // Act: write to JSON and read back
      appointmentRepo.writeAppointments(updated);
      final reloaded = appointmentRepo.readAppointments();

      // Assert: object reconstruction matches expected fields
      final loadedNew = reloaded.where((a) => a.appointmentId == 'a_new').cast<Appointment>().firstOrNull;
      expect(loadedNew, isNotNull);
      expect(loadedNew!.patientId, equals(newAppt.patientId));
      expect(loadedNew.doctorId, equals(newAppt.doctorId));
      expect(loadedNew.appointmentStatus, equals(AppointmentStatus.pending));
      expect(loadedNew.dateTime.year, equals(2025));
      expect(loadedNew.dateTime.month, equals(11));
      expect(loadedNew.dateTime.day, equals(10));
      expect(loadedNew.dateTime.hour, equals(9));
      expect(loadedNew.dateTime.minute, equals(30));

      // Bonus: verify raw JSON structure contains expected keys/types
      final content = File(tmpAppointmentsFile.path).readAsStringSync();
      final data = jsonDecode(content) as Map<String, dynamic>;
      final apptsJson = (data['appointments'] as List).cast<Map<String, dynamic>>();
      final jsonNew = apptsJson.firstWhere((a) => a['appointmentId'] == 'a_new');
      expect(jsonNew['appointmentStatus'], equals('AppointmentStatus.pending'));
      expect(jsonNew['patientId'], equals('586bae66-bc18-4528-8263-33e15efe8a6b'));
      expect(jsonNew['doctorId'], equals('476ece1d-d670-479b-8847-f3f4032e4c0d'));
      // Ensure ISO-8601 format (contains a 'T' separator)
      expect((jsonNew['dateTime'] as String).contains('T'), isTrue);
    });
  });
}