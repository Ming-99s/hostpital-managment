import 'user.dart';

/// Enumeration of medical specialties available in the hospital
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
  oncology,
  radiology,
  anesthesiology,
  pathology,
  emergencyMedicine,
}

/// Extension to provide human-readable names for specialties
extension SpecialtyExtension on Specialty {
  String get displayName {
    switch (this) {
      case Specialty.generalPractice:
        return 'General Practice';
      case Specialty.pediatrics:
        return 'Pediatrics';
      case Specialty.cardiology:
        return 'Cardiology';
      case Specialty.dermatology:
        return 'Dermatology';
      case Specialty.neurology:
        return 'Neurology';
      case Specialty.orthopedics:
        return 'Orthopedics';
      case Specialty.psychiatry:
        return 'Psychiatry';
      case Specialty.surgery:
        return 'Surgery';
      case Specialty.obstetricsGynecology:
        return 'Obstetrics & Gynecology';
      case Specialty.oncology:
        return 'Oncology';
      case Specialty.radiology:
        return 'Radiology';
      case Specialty.anesthesiology:
        return 'Anesthesiology';
      case Specialty.pathology:
        return 'Pathology';
      case Specialty.emergencyMedicine:
        return 'Emergency Medicine';
    }
  }
}

/// Doctor class extending User with medical professional specific properties and methods
class Doctor extends User {
  final Specialty specialty;
  final String licenseNumber;
  final int yearsOfExperience;
  double consultationFee;
  List<DateTime> availableSlots = [];
  final List<String> qualifications;
  bool isAvailable;

  /// Constructor for creating a new Doctor instance
  Doctor({
    required String username,
    required String password,
    required String name,
    required String email,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required String address,
    required this.specialty,
    required this.licenseNumber,
    required this.yearsOfExperience,
    required this.consultationFee,
    required this.qualifications,
    List<DateTime>? availableSlots,
    this.isAvailable = true,
    bool isActive = true,
  }) : super(
          username: username,
          password: password,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          dateOfBirth: dateOfBirth,
          address: address,
          isActive: isActive,
        ) {
    this.availableSlots = availableSlots ?? [];
  }

  /// Adds a new available time slot for appointments
  void addAvailableSlot(DateTime slot) {
    if (!availableSlots.contains(slot) && slot.isAfter(DateTime.now())) {
      availableSlots.add(slot);
      availableSlots.sort(); // Keep slots sorted chronologically
    }
  }

  /// Removes an available time slot
  void removeAvailableSlot(DateTime slot) {
    availableSlots.remove(slot);
  }

  /// Adds multiple available slots at once
  void addMultipleSlots(List<DateTime> slots) {
    for (DateTime slot in slots) {
      addAvailableSlot(slot);
    }
  }

  /// Clears all past available slots (slots before current time)
  void clearPastSlots() {
    final now = DateTime.now();
    availableSlots.removeWhere((slot) => slot.isBefore(now));
  }

  /// Gets available slots for a specific date
  List<DateTime> getAvailableSlotsForDate(DateTime date) {
    return availableSlots.where((slot) {
      return slot.year == date.year &&
          slot.month == date.month &&
          slot.day == date.day;
    }).toList();
  }

  /// Checks if the doctor is available at a specific time
  bool isAvailableAt(DateTime dateTime) {
    return isAvailable && 
           isActive && 
           availableSlots.contains(dateTime) &&
           dateTime.isAfter(DateTime.now());
  }

  /// Sets the doctor's availability status
  void setAvailability(bool available) {
    isAvailable = available;
  }

  /// Gets the next available appointment slot
  DateTime? getNextAvailableSlot() {
    final now = DateTime.now();
    final futureSlots = availableSlots.where((slot) => slot.isAfter(now)).toList();
    if (futureSlots.isEmpty) return null;
    futureSlots.sort();
    return futureSlots.first;
  }

  /// Generates weekly recurring slots for the doctor
  void generateWeeklySlots({
    required List<int> workingDays, // 1-7 (Monday-Sunday)
    required List<String> timeSlots, // e.g., ['09:00', '10:00', '11:00']
    required int weeksAhead,
  }) {
    final now = DateTime.now();
    
    for (int week = 0; week < weeksAhead; week++) {
      for (int day in workingDays) {
        final targetDate = now.add(Duration(days: (7 * week) + (day - now.weekday)));
        
        for (String timeSlot in timeSlots) {
          final timeParts = timeSlot.split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          
          final slotDateTime = DateTime(
            targetDate.year,
            targetDate.month,
            targetDate.day,
            hour,
            minute,
          );
          
          if (slotDateTime.isAfter(now)) {
            addAvailableSlot(slotDateTime);
          }
        }
      }
    }
  }

  /// Returns a string representation of the doctor
  @override
  String toString() {
    return 'Doctor{id: $id, name: $name, specialty: ${specialty.displayName}, '
           'licenseNumber: $licenseNumber, yearsOfExperience: $yearsOfExperience, '
           'isAvailable: $isAvailable, availableSlots: ${availableSlots.length}}';
  }
}