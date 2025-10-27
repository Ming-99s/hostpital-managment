import 'doctor.dart';
import 'patient.dart';
import 'package:uuid/uuid.dart';


enum AppointmentStatus{pending,reject,approved}

// Appointment class
class Appointment {
  final Patient patient;
  final Doctor doctor;
  DateTime dateTime;
  final String appointmentId ;
  AppointmentStatus appointmentStatus;


  Appointment(
      {required this.patient,
       required this.doctor, 
       required this.dateTime,
       required this.appointmentStatus}) : appointmentId = Uuid().v4();

  
}
