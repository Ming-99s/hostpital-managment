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
  AppointmentRepository appRepo =
      AppointmentRepository('hostpital-managment/lib/data/users.json');

  List<User> users = userRepo.readUsers();
  List<Appointment> appointments = appRepo.readAppointments();

  // Create AppointmentManager
  AppointmentManager appointmentManager = AppointmentManager(
    users: users,
    appointments: appointments,
  );

  // Create AuthService
  AuthService authService =
      AuthService(users: users, appointmentManager: appointmentManager);

  // Start the Auth UI
  Auth authUI = Auth(authService: authService);
  authUI.start();

  // Optional: Save back to JSON after program ends
  userRepo.writeUsers(users);
  appRepo.writeAppointments(appointments);
}
