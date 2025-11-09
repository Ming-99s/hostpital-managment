import 'dart:io';
import 'package:test/test.dart';
import '../../hostpital-managment/lib/data/Repository/User_file.dart';
import '../../hostpital-managment/lib/data/Repository/appointments_file.dart';
import '../../hostpital-managment/lib/domain/Service/userManager.dart';
import '../../hostpital-managment/lib/domain/Service/appointmentManager.dart';


void main() {
  late File userFile;
  late UserRepository userRepo;
  late UserManager userManager;

  setUp(() {
    // Temporary JSON test files
    userFile = File('test/test_users.json');

    userRepo = UserRepository(userFile.path);

    // Managers
    userManager = UserManager(userRepository: userRepo);
    

  });





  
}
