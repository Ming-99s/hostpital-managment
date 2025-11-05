import 'user.dart';
import 'package:uuid/uuid.dart';

enum Gender {male , female}

class Patient extends User {
  final int age;
  final String address;
  final String email;
  final Gender gender;

  // Only generate new ID if none is provided
  Patient({
    required this.age,
    required this.address,
    required this.email,
    required this.gender,
    required String username,
    required String password,

    String? id,
  }) : super(id:id , username: username ,password: password,type:UserType.patient) ;





}
