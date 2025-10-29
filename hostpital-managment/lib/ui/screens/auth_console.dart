import 'dart:io';
import '../../domain/services/auth_service.dart';
import '../../domain/services/session_service.dart';
import '../../domain/services/appointmentManager.dart';
import '../../domain/models/patient.dart';
import '../../domain/models/doctor.dart';
import 'user_console.dart';
import 'doctor_console.dart';
import 'manager_console.dart';

/// Main authentication console that handles login and routes users to appropriate interfaces
class AuthConsole {
  final AppointmentManager _appointmentManager;
  final AuthService _authService;
  final SessionService _sessionService;
  bool _isRunning = true;

  AuthConsole(this._appointmentManager) 
    : _authService = AuthService(_appointmentManager),
      _sessionService = SessionService(AuthService(_appointmentManager));

  /// Starts the authentication console
  void start() {
    print('🏥 Welcome to Hospital Management System');
    print('========================================');
    print('🔐 Please login to continue\n');
    
    while (_isRunning) {
      try {
        _showLoginMenu();
        final choice = _getInput('Select login type: ');
        _handleLoginChoice(choice);
      } catch (e) {
        print('❌ An error occurred: $e');
        print('Please try again.\n');
      }
    }
    
    print('👋 Thank you for using Hospital Management System!');
  }

  /// Displays the login menu
  void _showLoginMenu() {
    print('═══════════════════════════════════════');
    print('🔐 LOGIN TO HOSPITAL MANAGEMENT SYSTEM');
    print('═══════════════════════════════════════');
    print('1. 👤 Patient Login');
    print('2. 👨‍⚕️ Doctor Login');
    print('3. 👨‍💼 Manager Login');
    print('4. ❓ Help & Information');
    print('0. 🚪 Exit');
    print('═══════════════════════════════════════');
  }

  /// Handles login menu choices
  void _handleLoginChoice(String choice) {
    switch (choice) {
      case '1':
        _handlePatientLogin();
        break;
      case '2':
        _handleDoctorLogin();
        break;
      case '3':
        _handleManagerLogin();
        break;
      case '4':
        _showHelpInformation();
        break;
      case '0':
        _isRunning = false;
        break;
      default:
        print('❌ Invalid choice. Please try again.\n');
    }
  }

  /// Handles patient login
  void _handlePatientLogin() {
    print('\n👤 PATIENT LOGIN');
    print('───────────────');
    
    // Show loading state
    print('🔄 Preparing patient login...');
    
    final email = _getInput('Email: ');
    if (email.isEmpty) {
      print('❌ Email cannot be empty.\n');
      return;
    }

    final password = _getSecureInput('Password: ');
    if (password.isEmpty) {
      print('❌ Password cannot be empty.\n');
      return;
    }

    // Show authentication in progress
    print('🔄 Authenticating...');
    
    try {
      final result = _authService.authenticatePatient(email, password);
      
      if (result.success && result.user != null) {
        // Create session
        _sessionService.createSession(result.user!, result.role!);
        
        print('✅ Login successful!');
        print('👋 Welcome, ${result.user!.name}!\n');
        
        // Start patient console
        final patientConsole = PatientConsole(_appointmentManager, result.user! as Patient);
        patientConsole.start();
        
        // Clear session after logout
        _sessionService.clearSession();
        print('\n🔐 Logged out successfully.\n');
        
      } else {
        print('❌ ${result.errorMessage}\n');
        _showLoginHelp();
      }
    } catch (e) {
      print('❌ Login failed: $e\n');
    }
  }

  /// Handles doctor login
  void _handleDoctorLogin() {
    print('\n👨‍⚕️ DOCTOR LOGIN');
    print('─────────────');
    
    // Show loading state
    print('🔄 Preparing doctor login...');
    
    final email = _getInput('Email: ');
    if (email.isEmpty) {
      print('❌ Email cannot be empty.\n');
      return;
    }

    final password = _getSecureInput('Password: ');
    if (password.isEmpty) {
      print('❌ Password cannot be empty.\n');
      return;
    }

    // Show authentication in progress
    print('🔄 Authenticating...');
    
    try {
      final result = _authService.authenticateDoctor(email, password);
      
      if (result.success && result.user != null) {
        // Create session
        _sessionService.createSession(result.user!, result.role!);
        
        print('✅ Login successful!');
        print('👋 Welcome, Dr. ${result.user!.name}!\n');
        
        // Start doctor console
        final doctorConsole = DoctorConsole(_appointmentManager, result.user! as Doctor);
        doctorConsole.start();
        
        // Clear session after logout
        _sessionService.clearSession();
        print('\n🔐 Logged out successfully.\n');
        
      } else {
        print('❌ ${result.errorMessage}\n');
        _showLoginHelp();
      }
    } catch (e) {
      print('❌ Login failed: $e\n');
    }
  }

  /// Handles manager login
  void _handleManagerLogin() {
    print('\n👨‍💼 MANAGER LOGIN');
    print('─────────────');
    print('ℹ️  Manager access requires the admin password only.\n');
    
    // Show loading state
    print('🔄 Preparing manager login...');
    
    final password = _getSecureInput('Admin Password: ');
    if (password.isEmpty) {
      print('❌ Password cannot be empty.\n');
      return;
    }

    // Show authentication in progress
    print('🔄 Authenticating...');
    
    try {
      final result = _authService.authenticateManager(password);
      
      if (result.success && result.user != null) {
        // Create session
        _sessionService.createSession(result.user!, result.role!);
        
        print('✅ Login successful!');
        print('👋 Welcome, ${result.user!.name}!\n');
        
        // Start manager console
        final managerConsole = HospitalConsole(_appointmentManager);
        managerConsole.start();
        
        // Clear session after logout
        _sessionService.clearSession();
        print('\n🔐 Logged out successfully.\n');
        
      } else {
        print('❌ ${result.errorMessage}\n');
        print('💡 Hint: The default admin password is "admin123"\n');
      }
    } catch (e) {
      print('❌ Login failed: $e\n');
    }
  }

  /// Shows help and information
  void _showHelpInformation() {
    print('\n❓ HELP & INFORMATION');
    print('───────────────────');
    print('🏥 Hospital Management System Login Help');
    print('');
    print('👤 PATIENT LOGIN:');
    print('   • Use your registered email address');
    print('   • Enter your account password');
    print('   • Contact reception if you forgot your credentials');
    print('');
    print('👨‍⚕️ DOCTOR LOGIN:');
    print('   • Use your hospital-provided email address');
    print('   • Enter your doctor account password');
    print('   • Contact IT support for password reset');
    print('');
    print('👨‍💼 MANAGER LOGIN:');
    print('   • Only requires the admin password');
    print('   • No email address needed');
    print('   • Contact system administrator for access');
    print('');
    print('📞 SUPPORT CONTACTS:');
    print('   • Reception: +1-555-0123');
    print('   • IT Support: +1-555-0126');
    print('   • Emergency: 911');
    print('');
    print('🔒 SECURITY TIPS:');
    print('   • Never share your login credentials');
    print('   • Use a strong, unique password');
    print('   • Log out when finished');
    print('   • Report suspicious activity immediately');
    print('');
    
    _getInput('Press Enter to continue...');
  }

  /// Shows login help after failed attempts
  void _showLoginHelp() {
    print('💡 LOGIN HELP:');
    print('   • Check your email address spelling');
    print('   • Ensure your password is correct');
    print('   • Make sure your account is active');
    print('   • Contact support if you need assistance');
  }

  /// Gets user input with prompt
  String _getInput(String prompt) {
    stdout.write(prompt);
    return stdin.readLineSync() ?? '';
  }

  /// Gets secure input (password) with obscured display
  String _getSecureInput(String prompt) {
    stdout.write(prompt);
    
    // In a real application, you would use a library to hide password input
    // For this console demo, we'll just use regular input with a warning
    print('⚠️  Note: Password will be visible on screen in this demo');
    stdout.write('Enter password: ');
    
    final password = stdin.readLineSync() ?? '';
    
    // Clear the line for security (basic attempt)
    print('\x1B[1A\x1B[2K'); // Move up one line and clear it
    
    return password;
  }

  /// Validates session and shows session info (for debugging)
  void _showSessionInfo() {
    if (_sessionService.isLoggedIn) {
      final sessionInfo = _sessionService.getSessionInfo();
      print('🔐 Session Info:');
      print('   User: ${sessionInfo['userName']}');
      print('   Role: ${sessionInfo['role']}');
      print('   Duration: ${sessionInfo['sessionDuration']}');
      print('   Valid: ${sessionInfo['isValid']}');
    } else {
      print('🔐 No active session');
    }
  }

  /// Demonstrates authentication features (for testing)
  void _demonstrateAuth() {
    print('\n🧪 AUTHENTICATION DEMO');
    print('────────────────────');
    print('This demo shows the authentication system features:');
    print('');
    
    // Show sample credentials
    print('📋 SAMPLE CREDENTIALS:');
    print('');
    print('Patient Login:');
    print('  Email: john.doe@email.com');
    print('  Password: password123');
    print('');
    print('Doctor Login:');
    print('  Email: emily.johnson@hospital.com');
    print('  Password: doctor123');
    print('');
    print('Manager Login:');
    print('  Password: admin123');
    print('');
    
    _getInput('Press Enter to continue...');
  }

  /// Shows system status and statistics
  void _showSystemStatus() {
    print('\n📊 SYSTEM STATUS');
    print('───────────────');
    
    final stats = _appointmentManager.getSystemStatistics();
    print('Total Patients: ${stats['totalPatients']}');
    print('Total Doctors: ${stats['totalDoctors']}');
    print('Total Appointments: ${stats['totalAppointments']}');
    print('');
    
    print('🔐 Authentication Status:');
    print('Session Active: ${_sessionService.isLoggedIn}');
    if (_sessionService.isLoggedIn) {
      print('Current User: ${_sessionService.currentSession?.userName}');
      print('User Role: ${_sessionService.currentSession?.role.displayName}');
    }
    print('');
    
    _getInput('Press Enter to continue...');
  }
}

/// Route guard class for protecting console access
class RouteGuard {
  final SessionService _sessionService;

  RouteGuard(this._sessionService);

  /// Checks if user has permission to access a specific role's console
  bool canAccess(UserRole requiredRole) {
    if (!_sessionService.isLoggedIn) {
      return false;
    }

    return _sessionService.hasRole(requiredRole);
  }

  /// Validates session before allowing access
  bool validateAccess(UserRole requiredRole) {
    if (!_sessionService.validateSession()) {
      print('❌ Session expired. Please login again.');
      return false;
    }

    if (!canAccess(requiredRole)) {
      print('❌ Access denied. Insufficient permissions.');
      return false;
    }

    return true;
  }

  /// Updates activity timestamp for session management
  void updateActivity() {
    _sessionService.updateActivity();
  }
}