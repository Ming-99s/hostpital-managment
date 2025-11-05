import 'user.dart';

enum Specialty {
  generalPractice,
  pediatrics,
  cardiology,
  dermatology,
  neurology,
  orthopedics,
  psychiatry,
  surgery,
  obstetricsGynecology,
}



// Doctor class
class Doctor extends User{
  final String address;
  final String email;
  final Specialty specialty;
  final List<DateTime> availableSlots;

  Doctor({
    String? id,
    required String username,
    required String password,
    required this.address,
    required this.email,
    required this.specialty,
    required this.availableSlots,
  }) : super(id: id,username: username,password: password,type:UserType.doctor);

}
