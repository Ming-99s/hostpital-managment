
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import '../../hostpital-managment/lib/domain/appointment.dart';
import '../../hostpital-managment/lib/domain/doctor.dart';
import '../../hostpital-managment/lib/domain/patient.dart';



void main(){
  group(
    'Test model Doctor', 
    (){
      test('appointment object is created correctly', 
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
      final patient = 
        Patient(
          age: 12,
          address: 'Phnom Penh', 
          email: 'Lyming@gmail.com', 
          gender: Gender.male,
          username: 'Ming',
          password: '1234');
        
        final appointment = 
          Appointment(
            patientId: patient.id, 
            doctorId: doctor.id, 
            dateTime: DateTime.parse('2025-11-06T09:00:00.000'),
            appointmentStatus: AppointmentStatus.pending);

          expect(appointment.patientId, patient.id);
          expect(appointment.doctorId, doctor.id);
          expect(appointment.dateTime, DateTime.parse('2025-11-06T09:00:00.000'));
          expect(appointment.appointmentStatus, AppointmentStatus.pending);



      });


      
    });
} 