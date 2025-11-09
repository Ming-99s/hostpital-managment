
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import '../../hostpital-managment/lib/domain/user.dart';
import '../../hostpital-managment/lib/domain/doctor.dart';
void main(){
  group(
    'Test model Doctor', 
    (){
      test('Doctor object is created correctly', 
      (){
        final doctor = 
        Doctor(
          specialty: Specialty.cardiology,
          address: 'Phnom Penh', 
          email: 'Lyming@gmail.com', 
          username: 'Damn',
          password: '1234',
          availableSlots: [],
          );
          

        expect(doctor.username, equals('Ming'));
        expect(doctor.email, equals('Lyming@gmail.com'));
        expect(doctor.password, equals('1234'));
        expect(doctor.address, equals('Phnom Penh'));
        expect(doctor.type,equals(UserType.doctor)  );
        expect(doctor.specialty, equals(Specialty.cardiology));

      });


      
    });
} 