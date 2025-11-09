import 'dart:io';
import 'package:test/test.dart';
import '../../hostpital-managment/lib/data/Repository/User_file.dart';
import '../../hostpital-managment/lib/data/Repository/appointments_file.dart';
import '../../hostpital-managment/lib/domain/Service/userManager.dart';
import '../../hostpital-managment/lib/domain/Service/appointmentManager.dart';
import '../../hostpital-managment/lib/domain/doctor.dart';
import '../../hostpital-managment/lib/domain/patient.dart';
import '../../hostpital-managment/lib/domain/appointment.dart';


void main() {
  late File userFile;
  late File appointmentFile;
  late UserRepository userRepo;
  late AppointmentRepository appointmentRepo;
  late UserManager userManager;
  late AppointmentManager appointmentManager;

  setUp(() {
    // Temporary JSON test files
    userFile = File('test/test_users.json');
    appointmentFile = File('test/test_appointments.json');

    userRepo = UserRepository(userFile.path);
    appointmentRepo = AppointmentRepository(appointmentFile.path);

    // Managers
    userManager = UserManager(userRepository: userRepo);
    appointmentManager = AppointmentManager(appointmentRepo, userManager);

  });

  tearDown((){
    final appoinment = appointmentManager.getAppointmentById('a1');
    if(appoinment == null){
      return;
    }
    appoinment.appointmentStatus = AppointmentStatus.pending;
    final doctor = userManager.getDoctorById(appoinment.doctorId);
    if(doctor!.availableSlots.isEmpty){
        doctor.availableSlots.add(DateTime.now());
    }
    appointmentManager.updateAppointment(appoinment, appointmentManager.getAllAppointment());
    userManager.updateDoctor(doctor, userManager.getallUser());

  });



  test('Approve appointment should remove doctor slot', () {
    appointmentManager.approveAppointment('a1');
    final appoinmentUpdate = appointmentManager.getAppointmentById('a1');
    if(appoinmentUpdate == null){
      return;
    }
    expect(appoinmentUpdate.appointmentStatus, AppointmentStatus.approved);
  });

  test('Cancel approved appointment should return slot', () {
    appointmentManager.approveAppointment('a1');
    appointmentManager.cancelAppointment('a1');
    final appoinmentUpdate = appointmentManager.getAppointmentById('a1');
    if(appoinmentUpdate == null){
      return;
    }
    expect(appoinmentUpdate.appointmentStatus, AppointmentStatus.canceled);
  });

  test('Reject pending appointment should change status', () {
    appointmentManager.rejectAppointment('a1');
    final appoinmentUpdate = appointmentManager.getAppointmentById('a1');
    if(appoinmentUpdate == null){
      return;
    }
    expect(appoinmentUpdate.appointmentStatus, AppointmentStatus.rejected);
  });

  test('Cancel pending appointment should set to canceled', () {
    appointmentManager.cancelAppointment('a1');
    final appoinmentUpdate = appointmentManager.getAppointmentById('a1');
    if(appoinmentUpdate == null){
      return;
    }
    expect(appoinmentUpdate.appointmentStatus, AppointmentStatus.canceled);
  });
}
