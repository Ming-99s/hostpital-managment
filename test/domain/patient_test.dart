
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import '../../hostpital-managment/lib/domain/user.dart';
import '../../hostpital-managment/lib/domain/patient.dart';

void main(){
  group(
    'Test model Patient', 
    (){
      test('Patient object is created correctly', 
      (){
        final patient = 
        Patient(
          age: 12,
          address: 'Phnom Penh', 
          email: 'Lyming@gmail.com', 
          gender: Gender.male,
          username: 'Ming',
          password: '1234');

        expect(patient.username, equals('Ming'));
        expect(patient.age, equals(12));
        expect(patient.email, equals('Lyming@gmail.com'));
        expect(patient.password, equals('1234'));
        expect(patient.address, equals('Phnom Penh'));
        expect(patient.type,equals(UserType.patient)  );

      });


      
    });
} 