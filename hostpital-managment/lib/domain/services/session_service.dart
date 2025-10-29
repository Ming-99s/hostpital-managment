import '../models/user.dart';
import 'auth_service.dart';

/// Session information for authenticated users
class UserSession {
  final String userId;
  final String userName;
  final String userEmail;
  final UserRole role;
  final DateTime loginTime;
  DateTime lastActivity;

  UserSession({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.role,
    required this.loginTime,
    required this.lastActivity,
  });

  /// Checks if the session is still valid (not expired)
  bool get isValid {
    final now = DateTime.now();
    final sessionDuration = now.difference(lastActivity);
    // Session expires after 2 hours of inactivity
    return sessionDuration.inHours < 2;
  }

  /// Updates the last activity timestamp
  void updateActivity() {
    lastActivity = DateTime.now();
  }

  /// Gets the session duration
  Duration get sessionDuration {
    return DateTime.now().difference(loginTime);
  }

  @override
  String toString() {
    return 'UserSession{userId: $userId, userName: $userName, role: ${role.displayName}, loginTime: $loginTime}';
  }
}

/// Service for managing user sessions and authentication state
class SessionService {
  UserSession? _currentSession;
  final AuthService _authService;

  SessionService(this._authService);

  /// Gets the current active session
  UserSession? get currentSession => _currentSession;

  /// Checks if a user is currently logged in
  bool get isLoggedIn => _currentSession != null && _currentSession!.isValid;

  /// Gets the current user's role
  UserRole? get currentUserRole => _currentSession?.role;

  /// Gets the current user ID
  String? get currentUserId => _currentSession?.userId;

  /// Creates a new session for the authenticated user
  void createSession(User user, UserRole role) {
    final now = DateTime.now();
    _currentSession = UserSession(
      userId: user.id,
      userName: user.name,
      userEmail: user.email,
      role: role,
      loginTime: now,
      lastActivity: now,
    );
  }

  /// Updates the current session's last activity
  void updateActivity() {
    if (_currentSession != null) {
      _currentSession!.updateActivity();
    }
  }

  /// Validates the current session and refreshes if needed
  bool validateSession() {
    if (_currentSession == null) {
      return false;
    }

    if (!_currentSession!.isValid) {
      // Session expired, clear it
      clearSession();
      return false;
    }

    // Update activity timestamp
    updateActivity();
    return true;
  }

  /// Clears the current session (logout)
  void clearSession() {
    _currentSession = null;
  }

  /// Gets the current authenticated user
  User? getCurrentUser() {
    if (!validateSession()) {
      return null;
    }

    return _authService.getUserById(_currentSession!.userId, _currentSession!.role);
  }

  /// Checks if the current user has the specified role
  bool hasRole(UserRole role) {
    return isLoggedIn && _currentSession!.role == role;
  }

  /// Checks if the current user is a patient
  bool get isPatient => hasRole(UserRole.patient);

  /// Checks if the current user is a doctor
  bool get isDoctor => hasRole(UserRole.doctor);

  /// Checks if the current user is a manager
  bool get isManager => hasRole(UserRole.manager);

  /// Gets session information for display
  Map<String, dynamic> getSessionInfo() {
    if (_currentSession == null) {
      return {'isLoggedIn': false};
    }

    return {
      'isLoggedIn': true,
      'userId': _currentSession!.userId,
      'userName': _currentSession!.userName,
      'userEmail': _currentSession!.userEmail,
      'role': _currentSession!.role.displayName,
      'loginTime': _currentSession!.loginTime.toString(),
      'sessionDuration': _formatDuration(_currentSession!.sessionDuration),
      'isValid': _currentSession!.isValid,
    };
  }

  /// Formats duration for display
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Forces session expiration (for testing or admin purposes)
  void expireSession() {
    if (_currentSession != null) {
      _currentSession!.lastActivity = DateTime.now().subtract(const Duration(hours: 3));
    }
  }

  /// Extends the current session (resets activity timer)
  void extendSession() {
    if (_currentSession != null) {
      _currentSession!.updateActivity();
    }
  }
}