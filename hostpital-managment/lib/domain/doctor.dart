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
class Doctor extends User {
  final Specialty specialty;
  List<DateTime> availableSlots = [];
  final String address;
  final String email;

  Doctor(
      {required int id,
      required String username,
      required String password,
      required String name,
      required this.specialty,
      required this.availableSlots,
      required this.address,
      required this.email})
      : super( username: username, password: password);

  void addAvailableSlot(DateTime slot) {
    availableSlots.add(slot);
  }

  void removeAvailableSlot(DateTime slot) {
    availableSlots.remove(slot);
  }

  
}