import 'user.dart';
enum Gender {male , female}

// Patient class
class Patient extends User {
  final int age;
  final String address;
  final String email;
  final Gender gender;

  Patient(
      {required String id,
      required String username,
      required String password,
      required String name,
      required this.age,
      required this.address,
      required this.email,
      required this.gender})
      : super( username: username, password: password);

}