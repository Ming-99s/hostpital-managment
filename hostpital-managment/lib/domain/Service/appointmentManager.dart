import '../../data/Repository/appointments_file.dart';
import '../appointment.dart';
import 'userManager.dart';

class AppointmentManager {
  final AppointmentRepository appointmentRepo;
  final UserManager userManager;

  AppointmentManager(this.appointmentRepo, this.userManager);

  List<Appointment> getAllAppointment() {
    return appointmentRepo.readAppointments();
  }

  Appointment? getAppointmentById(String appointmentId) {
    final appointments = getAllAppointment();
    try {
      return appointments.firstWhere((a) => a.appointmentId == appointmentId);
    } catch (e) {
      return null;
    }
  }

  void updateAppointment(Appointment updatedAppointment,List<Appointment> appointments) {

    for (int i = 0; i < appointments.length; i++) {
      if (appointments[i].appointmentId == updatedAppointment.appointmentId) {
        appointments[i] = updatedAppointment;
        appointmentRepo.writeAppointments(appointments);

        return;
      }
    }

    print('Appointment not found!');
  }

  void addAppointment(Appointment appointment) {
    final appointments = appointmentRepo.readAppointments();
    appointments.add(appointment);
    appointmentRepo.writeAppointments(appointments);
  }

  void removeAppointment(String appointmentId) {
    final appointments = appointmentRepo.readAppointments();
    appointments.removeWhere((a) => a.appointmentId == appointmentId);
    appointmentRepo.writeAppointments(appointments);
  }

  void approveAppointment(String appointmentId) {
    final appointments = appointmentRepo.readAppointments();
    final appointment = getAppointmentById(appointmentId);
    final users = userManager.getallUser();

    if (appointment == null) {
      print('Appointment not found.');
      return;
    }

    final doctor = userManager.getDoctorById(appointment.doctorId);

    if (appointment.appointmentStatus == AppointmentStatus.pending) {
      if (doctor!.availableSlots.contains(appointment.dateTime)) {
        doctor.availableSlots.remove(appointment.dateTime);
        appointment.appointmentStatus = AppointmentStatus.approved;
        updateAppointment(appointment, appointments);
        userManager.updateDoctor(doctor, users);
        print('Appointment approved.');
        return;
      } else {
        print('Only pending appointments can be approved.');
        return;
      }
    }
    print('Appointment not found.');
  }

  void cancelAppointment(String appointmentId) {
    final appointments = appointmentRepo.readAppointments();
    final appointment = getAppointmentById(appointmentId);
  final users = userManager.getallUser();

    if (appointment == null) {
      print('Appointment not found.');
      return;
    }

    final doctor = userManager.getDoctorById(appointment.doctorId);

    if (appointment.appointmentStatus == AppointmentStatus.approved) {
        doctor!.availableSlots.add(appointment.dateTime);
        appointment.appointmentStatus = AppointmentStatus.canceled;
        updateAppointment(appointment, appointments);
        userManager.updateDoctor(doctor, users);
        print('Appointment cancelled.');
        return;
      
    } else if (appointment.appointmentStatus == AppointmentStatus.pending) {
      appointment.appointmentStatus = AppointmentStatus.canceled;
      updateAppointment(appointment, appointments);
      print('Appointment cancelled.');
      return;
    } else {
      print('Cannot cancel this appointment.');
      return;
    }
  }

  void rejectAppointment(String appointmentId) {
    final appointments = appointmentRepo.readAppointments();
    final appointment = getAppointmentById(appointmentId);

    if (appointment == null) {
      print('Appointment not found.');
      return;
    }

    if (appointment.appointmentStatus == AppointmentStatus.pending) {
      appointment.appointmentStatus = AppointmentStatus.rejected;
      updateAppointment(appointment, appointments);
      print('Appointment rejected.');
      return;
    } else {
      print('Only pending appointments can be rejected.');
      return;
    }
  }
}
