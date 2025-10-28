// Base User class
import 'package:uuid/uuid.dart';

/// Base User class that serves as the foundation for all user types in the hospital management system
/// Provides common properties and methods for user authentication and management
class User {
  final String id;
  final String username;
  final String password;
  final String name;
  final String email;
  final String phoneNumber;
  final DateTime registerDate;
  final DateTime dateOfBirth;
  final String address;
  bool isActive;

  /// Constructor for creating a new User instance
  /// Automatically generates a unique ID and sets the registration date
  User({
    required this.username,
    required this.password,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.address,
    this.isActive = true,
  }) : registerDate = DateTime.now(), id = const Uuid().v4();

  /// Authenticates a user with provided credentials
  /// Returns true if the username and password match
  bool login(String username, String password) {
    return this.username == username && this.password == password && isActive;
  }

  /// Deactivates the user account
  void deactivateAccount() {
    isActive = false;
  }

  /// Reactivates the user account
  void activateAccount() {
    isActive = true;
  }

  /// Calculates the user's age based on their date of birth
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  /// Returns a string representation of the user
  @override
  String toString() {
    return 'User{id: $id, username: $username, name: $name, email: $email, isActive: $isActive}';
  }

  /// Checks if two users are equal based on their ID
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  /// Returns the hash code for the user based on their ID
  @override
  int get hashCode => id.hashCode;
}