// Base User class
import 'package:uuid/uuid.dart';

class User {
  final String id;
  final String username;
  final String password;
  final DateTime registerDate;


  User(
      {required this.username,
      required this.password}) : registerDate = DateTime.now() , id = Uuid().v4();

  bool login(String username, String password) {
    return this.username == username && this.password == password;
  }

}