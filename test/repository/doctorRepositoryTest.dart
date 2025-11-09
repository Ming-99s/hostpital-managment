import 'package:test/test.dart';

import '../../hostpital-managment/lib/data/Repository/User_file.dart';
import '../../hostpital-managment/lib/domain/doctor.dart';
import '../../hostpital-managment/lib/domain/user.dart';

void main() {
  group('UserRepository doctor persistence', () {
    late UserRepository userRepo;

    setUp(() {
      userRepo = UserRepository('test/test_users.json');
      // Reset test file to a known empty state
      userRepo.writeUsers([]);
    });

    test('write and read single Doctor with slots', () {
      final slots = [
        DateTime(2030, 1, 1, 9, 0),
        DateTime(2030, 1, 1, 10, 30),
      ];
      final doctor = Doctor(
        username: 'dr_jane',
        password: 'secret',
        address: '123 Clinic Rd',
        email: 'jane@clinic.test',
        specialty: Specialty.cardiology,
        availableSlots: slots,
      );

      userRepo.writeUsers([doctor]);

      final users = userRepo.readUsers();
      final doctors = users.where((u) => u is Doctor).cast<Doctor>().toList();

      expect(doctors.length, 1);
      expect(doctors.first.username, 'dr_jane');
      expect(doctors.first.email, 'jane@clinic.test');
      expect(doctors.first.specialty, Specialty.cardiology);
      expect(doctors.first.availableSlots.length, 2);
      expect(doctors.first.availableSlots[0], DateTime(2030, 1, 1, 9, 0));
      expect(doctors.first.availableSlots[1], DateTime(2030, 1, 1, 10, 30));
    });

    test('update Doctor and persist changes', () {
      final doctor = Doctor(
        username: 'dr_update',
        password: 'secret',
        address: 'Old Address',
        email: 'update@clinic.test',
        specialty: Specialty.dermatology,
        availableSlots: [DateTime(2030, 6, 1, 8, 0)],
      );

      userRepo.writeUsers([doctor]);

      // Read, update address, write back
      final users = userRepo.readUsers();
      final idx = users.indexWhere((u) => u is Doctor && (u as Doctor).username == 'dr_update');
      final original = users[idx] as Doctor;
      users[idx] = Doctor(
        id: original.id,
        username: original.username,
        password: original.password,
        address: 'New Address',
        email: original.email,
        specialty: original.specialty,
        availableSlots: original.availableSlots,
      );

      userRepo.writeUsers(users);

      final after = userRepo.readUsers().where((u) => u is Doctor).cast<Doctor>().toList();
      expect(after.length, 1);
      expect(after.first.address, 'New Address');
      expect(after.first.id, original.id); // id preserved
    });

    test('append multiple Doctors and read them all', () {
      final d1 = Doctor(
        username: 'dr_one',
        password: 'onepass',
        address: 'One St',
        email: 'one@clinic.test',
        specialty: Specialty.neurology,
        availableSlots: [],
      );
      userRepo.writeUsers([d1]);

      final d2 = Doctor(
        username: 'dr_two',
        password: 'twopass',
        address: 'Two St',
        email: 'two@clinic.test',
        specialty: Specialty.orthopedics,
        availableSlots: [DateTime(2030, 12, 25, 15, 0)],
      );

      final users = userRepo.readUsers();
      users.add(d2);
      userRepo.writeUsers(users);

      final doctors = userRepo.readUsers().where((u) => u is Doctor).cast<Doctor>().toList();
      expect(doctors.length, 2);
      expect(doctors.map((d) => d.username).toSet(), {'dr_one', 'dr_two'});
      final two = doctors.firstWhere((d) => d.username == 'dr_two');
      expect(two.availableSlots.length, 1);
      expect(two.availableSlots.first, DateTime(2030, 12, 25, 15, 0));
    });
  });
}