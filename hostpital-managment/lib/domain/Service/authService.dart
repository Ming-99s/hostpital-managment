import '../user.dart';
import '../patient.dart';
import '../doctor.dart';
import 'userManager.dart';

class AuthService {
  final UserManager userManager;

  AuthService({required this.userManager});

  User? registerPatient(String username, String password, String email, int age ,String address,Gender gender) {
    try {
      if (userManager.isUsernameExists(username)) {
        throw Exception('Username already exists');
      }

      if (userManager.isValidEmail(email)) {
        throw Exception('Invalid email format');
      }

      if (age < 0 || age > 150) {
        throw Exception('Invalid age');
      }

      final newPatient = Patient(
        username: username,
        address: address,
        password: password, 
        email: email,
        age: age,
        gender: gender
      );

      userManager.addUser(newPatient);

      return newPatient;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  User? registerDoctor(String username, String password, String email, Specialty specialty, List<DateTime> availableSlots,String address) {
    try {
      if (userManager.isUsernameExists(username)) {
        throw Exception('Username already exists');
      }

      if (userManager.isValidEmail(email)) {
        throw Exception('Invalid email format');
      }

      final newDoctor = Doctor(
        username: username,
        password: password, 
        email: email,
        address: address,
        specialty: specialty,
        availableSlots: availableSlots,
      );

      userManager.addUser(newDoctor);

      return newDoctor;
    } catch (e) {
      throw Exception('Doctor registration failed: $e');
    }
  }

  User? login(String username, String password) {
    try {
      final allUsers = userManager.getallUser();
      
      final user = allUsers.firstWhere(
        (user) => user.username == username && user.password == password,
      );

      return user;
    } catch (e) {
      return null;
    }
  }

  bool validateCredentials(String username, String password) {
    return login(username, password) != null;
  }



  /// Checks if username is available
  bool isUsernameAvailable(String username) {
    return !userManager.isUsernameExists(username);
  }


}