import 'data/appointments_file.dart';
import 'data/User_file.dart';
import 'domain/authService.dart';
import 'domain/user.dart';
import 'ui/auth.dart';
import 'domain/appointmentManager.dart';
import 'domain/appointment.dart';

void main() {
  // Load users and appointments from JSON
  UserRepository userRepo = UserRepository('hostpital-managment/lib/data/users.json');
  DoctorRepository doctorRepo = DoctorRepository('hostpital-managment/lib/data/doctors.json');
  AppointmentRepository appRepo =
      AppointmentRepository('hostpital-managment/lib/data/appointments.json');

  List<User> users = userRepo.readUsers();
  // Load doctors from the dedicated file and merge into users list for runtime
  final doctors = doctorRepo.readDoctors();
  users.addAll(doctors);
  List<Appointment> appointments = appRepo.readAppointments();

  // Create AppointmentManager
  AppointmentManager appointmentManager = AppointmentManager(
    users: users,
    appointments: appointments,
  );

  // Create AuthService
  AuthService authService = AuthService(
    users: users,
    appointmentManager: appointmentManager,
    userRepo: userRepo,
    doctorRepo: doctorRepo,
  );

  // Start the Auth UI
  Auth authUI = Auth(authService: authService);
  authUI.start();

  // Optional: Save back to JSON after program ends
  userRepo.writeUsers(users); // writes patients/admin only
  doctorRepo.writeDoctors(doctors);
  appRepo.writeAppointments(appointments);
}
