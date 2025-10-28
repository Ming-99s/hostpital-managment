import 'user.dart';

/// Enumeration of blood types
enum BloodType {
  aPositive,
  aNegative,
  bPositive,
  bNegative,
  abPositive,
  abNegative,
  oPositive,
  oNegative,
}

/// Extension to provide string representation of blood types
extension BloodTypeExtension on BloodType {
  String get displayName {
    switch (this) {
      case BloodType.aPositive:
        return 'A+';
      case BloodType.aNegative:
        return 'A-';
      case BloodType.bPositive:
        return 'B+';
      case BloodType.bNegative:
        return 'B-';
      case BloodType.abPositive:
        return 'AB+';
      case BloodType.abNegative:
        return 'AB-';
      case BloodType.oPositive:
        return 'O+';
      case BloodType.oNegative:
        return 'O-';
    }
  }
}

/// Enumeration of gender options
enum Gender {
  male,
  female,
  other,
}

/// Extension to provide string representation of gender
extension GenderExtension on Gender {
  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }
}

/// Medical record entry for tracking patient's medical history
class MedicalRecord {
  final String id;
  final DateTime date;
  final String diagnosis;
  final String treatment;
  final String doctorId;
  final String notes;
  final List<String> medications;

  MedicalRecord({
    required this.id,
    required this.date,
    required this.diagnosis,
    required this.treatment,
    required this.doctorId,
    required this.notes,
    required this.medications,
  });

  @override
  String toString() {
    return 'MedicalRecord{date: $date, diagnosis: $diagnosis, treatment: $treatment}';
  }
}

/// Emergency contact information
class EmergencyContact {
  final String name;
  final String phoneNumber;
  final String relationship;
  final String email;

  EmergencyContact({
    required this.name,
    required this.phoneNumber,
    required this.relationship,
    required this.email,
  });

  @override
  String toString() {
    return 'EmergencyContact{name: $name, relationship: $relationship, phone: $phoneNumber}';
  }
}

/// Patient class extending User with medical and health-related properties
class Patient extends User {
  final Gender gender;
  final BloodType bloodType;
  final double height; // in cm
  final double weight; // in kg
  final List<String> allergies;
  final List<String> chronicConditions;
  final List<MedicalRecord> medicalHistory;
  final EmergencyContact emergencyContact;
  final String insuranceNumber;
  final String insuranceProvider;
  DateTime? lastVisit;

  /// Constructor for creating a new Patient instance
  Patient({
    required String username,
    required String password,
    required String name,
    required String email,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required String address,
    required this.gender,
    required this.bloodType,
    required this.height,
    required this.weight,
    required this.emergencyContact,
    required this.insuranceNumber,
    required this.insuranceProvider,
    List<String>? allergies,
    List<String>? chronicConditions,
    List<MedicalRecord>? medicalHistory,
    this.lastVisit,
    bool isActive = true,
  })  : allergies = allergies ?? [],
        chronicConditions = chronicConditions ?? [],
        medicalHistory = medicalHistory ?? [],
        super(
          username: username,
          password: password,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          dateOfBirth: dateOfBirth,
          address: address,
          isActive: isActive,
        );

  /// Calculates BMI (Body Mass Index)
  double get bmi {
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  /// Gets BMI category based on WHO standards
  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal weight';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  /// Adds a new allergy to the patient's record
  void addAllergy(String allergy) {
    if (!allergies.contains(allergy)) {
      allergies.add(allergy);
    }
  }

  /// Removes an allergy from the patient's record
  void removeAllergy(String allergy) {
    allergies.remove(allergy);
  }

  /// Adds a chronic condition to the patient's record
  void addChronicCondition(String condition) {
    if (!chronicConditions.contains(condition)) {
      chronicConditions.add(condition);
    }
  }

  /// Removes a chronic condition from the patient's record
  void removeChronicCondition(String condition) {
    chronicConditions.remove(condition);
  }

  /// Adds a new medical record entry
  void addMedicalRecord(MedicalRecord record) {
    medicalHistory.add(record);
    medicalHistory.sort((a, b) => b.date.compareTo(a.date)); // Sort by date, newest first
  }

  /// Gets medical records within a specific date range
  List<MedicalRecord> getMedicalRecordsInRange(DateTime startDate, DateTime endDate) {
    return medicalHistory.where((record) {
      return record.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          record.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Gets the most recent medical record
  MedicalRecord? getLatestMedicalRecord() {
    if (medicalHistory.isEmpty) return null;
    return medicalHistory.first; // Already sorted by date
  }

  /// Updates the last visit date
  void updateLastVisit(DateTime visitDate) {
    lastVisit = visitDate;
  }

  /// Checks if the patient has a specific allergy
  bool hasAllergy(String allergy) {
    return allergies.contains(allergy);
  }

  /// Checks if the patient has a specific chronic condition
  bool hasChronicCondition(String condition) {
    return chronicConditions.contains(condition);
  }

  /// Gets all medications from medical history
  List<String> getAllMedications() {
    final allMedications = <String>{};
    for (final record in medicalHistory) {
      allMedications.addAll(record.medications);
    }
    return allMedications.toList();
  }

  /// Returns a comprehensive health summary
  Map<String, dynamic> getHealthSummary() {
    return {
      'patientId': id,
      'name': name,
      'age': age,
      'gender': gender.displayName,
      'bloodType': bloodType.displayName,
      'bmi': bmi.toStringAsFixed(1),
      'bmiCategory': bmiCategory,
      'allergies': allergies,
      'chronicConditions': chronicConditions,
      'lastVisit': lastVisit?.toString() ?? 'Never',
      'totalMedicalRecords': medicalHistory.length,
      'emergencyContact': emergencyContact.toString(),
    };
  }

  /// Returns a string representation of the patient
  @override
  String toString() {
    return 'Patient{id: $id, name: $name, age: $age, gender: ${gender.displayName}, '
           'bloodType: ${bloodType.displayName}, bmi: ${bmi.toStringAsFixed(1)}, '
           'allergies: ${allergies.length}, conditions: ${chronicConditions.length}}';
  }
}