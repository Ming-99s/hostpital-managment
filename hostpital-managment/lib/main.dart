import 'data/Repository/appointments_file.dart';
import 'data/Repository/User_file.dart';
import 'domain/Service/authService.dart';
import 'domain/Service/userManager.dart';
import 'ui/authUI.dart';
import 'domain/Service/appointmentManager.dart';

void main() {
  // Load users and appointments from JSON
  // Use paths relative to the project root (outer folder)
  // so running `dart lib/main.dart` from the root works.
  UserRepository userRepo = UserRepository('hostpital-managment/lib/data/users.json');
  AppointmentRepository appRepo = AppointmentRepository('hostpital-managment/lib/data/appointments.json');

  UserManager userManager = UserManager(userRepository: userRepo);

  // Create AppointmentManager
  AppointmentManager appointmentManager = AppointmentManager(appRepo, userManager);

  // Create AuthService
  AuthService authService = AuthService(userManager: userManager, appointmentManager: appointmentManager);

  // Start the Auth UI
  AuthUI auth = AuthUI(authService: authService,userManager: userManager,appointmentManager: appointmentManager);
  auth.startAuthUI();


}
