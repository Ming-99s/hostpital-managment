import 'dart:io';
import '../models/user.dart';
import '../models/patient.dart';
import '../models/doctor.dart';
import 'appointmentManager.dart';

/// Enumeration of user roles in the hospital management system
enum UserRole {
  patient,
  doctor,
  manager,
}

/// Extension to provide display names for user roles
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.patient:
        return 'Patient';
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.manager:
        return 'Manager';
    }
  }
}

/// Authentication result class to handle login responses
class AuthResult {
  final bool success;
  final String? errorMessage;
  final User? user;
  final UserRole? role;

  AuthResult({
    required this.success,
    this.errorMessage,
    this.user,
    this.role,
  });

  factory AuthResult.success(User user, UserRole role) {
    return AuthResult(
      success: true,
      user: user,
      role: role,
    );
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// Authentication service for handling user login and validation
class AuthService {
  final AppointmentManager _appointmentManager;
  static const String _managerPassword = "admin123";

  AuthService(this._appointmentManager);

  /// Validates email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Validates password strength
  ValidationResult _validatePassword(String password) {
    if (password.isEmpty) {
      return ValidationResult(false, 'Password cannot be empty');
    }
    if (password.length < 6) {
      return ValidationResult(false, 'Password must be at least 6 characters long');
    }
    return ValidationResult(true, null);
  }

  /// Validates email and password format
  ValidationResult validateCredentials(String email, String password) {
    if (email.isEmpty) {
      return ValidationResult(false, 'Email cannot be empty');
    }
    if (!_isValidEmail(email)) {
      return ValidationResult(false, 'Please enter a valid email address');
    }
    return _validatePassword(password);
  }

  /// Authenticates a patient with email and password
  AuthResult authenticatePatient(String email, String password) {
    // Validate input format
    final validation = validateCredentials(email, password);
    if (!validation.isValid) {
      return AuthResult.failure(validation.errorMessage!);
    }

    // Find patient by email
    final patient = _appointmentManager.patients.firstWhere(
      (p) => p.email.toLowerCase() == email.toLowerCase() && p.isActive,
      orElse: () => throw StateError('Patient not found'),
    );

    try {
      // Check password
      if (patient.password != password) {
        return AuthResult.failure('Invalid email or password');
      }

      return AuthResult.success(patient, UserRole.patient);
    } catch (e) {
      return AuthResult.failure('Invalid email or password');
    }
  }

  /// Authenticates a doctor with email and password
  AuthResult authenticateDoctor(String email, String password) {
    // Validate input format
    final validation = validateCredentials(email, password);
    if (!validation.isValid) {
      return AuthResult.failure(validation.errorMessage!);
    }

    // Find doctor by email
    try {
      final doctor = _appointmentManager.doctors.firstWhere(
        (d) => d.email.toLowerCase() == email.toLowerCase() && d.isActive,
        orElse: () => throw StateError('Doctor not found'),
      );

      // Check password
      if (doctor.password != password) {
        return AuthResult.failure('Invalid email or password');
      }

      return AuthResult.success(doctor, UserRole.doctor);
    } catch (e) {
      return AuthResult.failure('Invalid email or password');
    }
  }

  /// Authenticates a manager with hardcoded password (no email required)
  AuthResult authenticateManager(String password) {
    if (password.isEmpty) {
      return AuthResult.failure('Password cannot be empty');
    }

    if (password != _managerPassword) {
      return AuthResult.failure('Invalid manager password');
    }

    // Create a temporary manager user for session management
    final manager = User(
      username: 'admin',
      password: _managerPassword,
      name: 'Hospital Manager',
      email: 'admin@hospital.com',
      phoneNumber: '+1-555-0000',
      dateOfBirth: DateTime(1980, 1, 1),
      address: 'Hospital Administration',
    );

    return AuthResult.success(manager, UserRole.manager);
  }

  /// Gets user by ID for session validation
  User? getUserById(String userId, UserRole role) {
    switch (role) {
      case UserRole.patient:
        return _appointmentManager.getPatientById(userId);
      case UserRole.doctor:
        return _appointmentManager.getDoctorById(userId);
      case UserRole.manager:
        // Return manager user if ID matches
        return userId == 'admin' ? User(
          username: 'admin',
          password: _managerPassword,
          name: 'Hospital Manager',
          email: 'admin@hospital.com',
          phoneNumber: '+1-555-0000',
          dateOfBirth: DateTime(1980, 1, 1),
          address: 'Hospital Administration',
        ) : null;
    }
  }
}

/// Validation result class for input validation
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult(this.isValid, this.errorMessage);
}