import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import '../../hostpital-managment/lib/domain/user.dart';
import '../../hostpital-managment/lib/domain/doctor.dart';

void main() {
  group('Test model Doctor', () {
    test('Doctor object is created correctly', () {
      final doctor = Doctor(
        address: 'Phnom Penh',
        email: 'doctor@example.com',
        specialty: Specialty.cardiology,
        availableSlots: [
          DateTime(2025, 1, 1, 9, 0),
          DateTime(2025, 1, 1, 10, 0),
        ],
        username: 'DrMing',
        password: 'secret',
      );

      expect(doctor.username, equals('DrMing'));
      expect(doctor.password, equals('secret'));
      expect(doctor.address, equals('Phnom Penh'));
      expect(doctor.email, equals('doctor@example.com'));
      expect(doctor.type, equals(UserType.doctor));
      expect(doctor.specialty, equals(Specialty.cardiology));
      expect(doctor.availableSlots.length, equals(2));
      expect(doctor.availableSlots[0], equals(DateTime(2025, 1, 1, 9, 0)));
      expect(doctor.availableSlots[1], equals(DateTime(2025, 1, 1, 10, 0)));
    });
  });
}