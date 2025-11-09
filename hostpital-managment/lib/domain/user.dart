// Base User class
import 'package:uuid/uuid.dart';
enum UserType { patient, doctor, admin }

class User {
  final String id;
  final String username;
  final String password;
  final DateTime registerDate;
  final UserType type;

  User(
      {
      String? id,
      required this.username,
      required this.password,
      required this.type}) : registerDate = DateTime.now() , id = id ?? Uuid().v4();



}