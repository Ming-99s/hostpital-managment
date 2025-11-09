import '../../data/Repository/User_file.dart';
import '../admin.dart';
import '../user.dart';
import '../doctor.dart';
import '../patient.dart';

class UserManager {
  final UserRepository userRepository;

  UserManager({required this.userRepository});

  List<User> getallUser(){
    return userRepository.readUsers();
  }
  

  void addUser(User user){
    final users = userRepository.readUsers();
    users.add(user);
    userRepository.writeUsers(users);
  }

  void updateDoctor(Doctor updatedDoctor,List<User> users) {

    for (int i = 0; i < users.length; i++) {
      if (users[i].id == updatedDoctor.id) {
        users[i] = updatedDoctor;
        userRepository.writeUsers(users);
        return;
      }
    }
  }

  bool isUsernameExists(String username) {
    List<User> allUsers = getallUser();
    return allUsers
        .any((user) => user.username.toLowerCase() == username.toLowerCase());
  }

  void removeUser(String userId){
    final users = userRepository.readUsers();
    users.removeWhere((u) => u.id == userId);
    userRepository.writeUsers(users);
  }

    Patient? getPatientById(String patientId) {
    final users = getallUser();
    try {
      return users.firstWhere(
        (user) => user.id == patientId && user is Patient,
      ) as Patient;
    } catch (e) {
      return null;
    }
  }

  Doctor? getDoctorById(String doctorId) {
    final users = getallUser();
    try {
      return users.firstWhere(
        (user) => user.id == doctorId && user is Doctor,
      ) as Doctor;
    } catch (e) {
      return null;
    }
  }

  Map<String, String> getPatientInfo(String patientId) {
    final patient = getPatientById(patientId);
    if (patient != null) {
      return {
        'name': patient.username,
        'email': patient.email,
        'age': patient.age.toString(),
      };
    }
    return {'name': 'Unknown Patient', 'email': 'N/A', 'age': 'N/A'};
  }

  Map<String, String> getDoctorInfo(String doctorId) {
    final doctor = getDoctorById(doctorId);
    if (doctor != null) {
      return {
        'name': doctor.username,
        'specialty': formatSpecialty(doctor.specialty),
        'email': doctor.email,
      };
    }
    return {'name': 'Unknown Doctor', 'specialty': 'Unknown', 'email': 'N/A'};
  }

  String formatSpecialty(Specialty specialty) {
    switch (specialty) {
      case Specialty.generalPractice: return 'General Practice';
      case Specialty.pediatrics: return 'Pediatrics';
      case Specialty.cardiology: return 'Cardiology';
      case Specialty.dermatology: return 'Dermatology';
      case Specialty.neurology: return 'Neurology';
      case Specialty.orthopedics: return 'Orthopedics';
      case Specialty.psychiatry: return 'Psychiatry';
      case Specialty.surgery: return 'Surgery';
      case Specialty.obstetricsGynecology: return 'Obstetrics & Gynecology';
    }
  }
  
}