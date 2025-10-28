import '../models/appointment.dart';
import '../models/doctor.dart';
import '../models/patient.dart';

/// Exception class for appointment-related errors
class AppointmentException implements Exception {
  final String message;
  AppointmentException(this.message);
  
  @override
  String toString() => 'AppointmentException: $message';
}

/// Comprehensive Appointment Manager service for handling all appointment operations
class AppointmentManager {
  final List<Patient> patients = [];
  final List<Appointment> appointments = [];
  final List<Doctor> doctors = [];

  // Statistics tracking
  int _totalAppointmentsCreated = 0;
  int _totalAppointmentsCancelled = 0;
  int _totalAppointmentsCompleted = 0;

  /// Adds a new patient to the system
  void addPatient(Patient patient) {
    if (!patients.any((p) => p.id == patient.id)) {
      patients.add(patient);
    } else {
      throw AppointmentException('Patient with ID ${patient.id} already exists');
    }
  }

  /// Adds a new doctor to the system
  void addDoctor(Doctor doctor) {
    if (!doctors.any((d) => d.id == doctor.id)) {
      doctors.add(doctor);
    } else {
      throw AppointmentException('Doctor with ID ${doctor.id} already exists');
    }
  }

  /// Removes a patient from the system
  bool removePatient(String patientId) {
    final patient = getPatientById(patientId);
    if (patient != null) {
      // Cancel all appointments for this patient
      final patientAppointments = getAppointmentsByPatient(patientId);
      for (final appointment in patientAppointments) {
        cancelAppointment(appointment.appointmentId, 'Patient removed from system');
      }
      patients.removeWhere((p) => p.id == patientId);
      return true;
    }
    return false;
  }

  /// Removes a doctor from the system
  bool removeDoctor(String doctorId) {
    final doctor = getDoctorById(doctorId);
    if (doctor != null) {
      // Cancel all appointments for this doctor
      final doctorAppointments = getAppointmentsByDoctor(doctorId);
      for (final appointment in doctorAppointments) {
        cancelAppointment(appointment.appointmentId, 'Doctor no longer available');
      }
      doctors.removeWhere((d) => d.id == doctorId);
      return true;
    }
    return false;
  }

  /// Creates a new appointment
  Appointment createAppointment({
    required String patientId,
    required String doctorId,
    required DateTime dateTime,
    required String reason,
    AppointmentType appointmentType = AppointmentType.consultation,
    int durationMinutes = 30,
    String notes = '',
  }) {
    final patient = getPatientById(patientId);
    final doctor = getDoctorById(doctorId);

    if (patient == null) {
      throw AppointmentException('Patient with ID $patientId not found');
    }
    if (doctor == null) {
      throw AppointmentException('Doctor with ID $doctorId not found');
    }
    if (!doctor.isActive) {
      throw AppointmentException('Doctor is not active');
    }
    if (!doctor.isAvailableAt(dateTime)) {
      throw AppointmentException('Doctor is not available at the requested time');
    }

    // Check for conflicts
    if (hasConflictingAppointment(doctorId, dateTime, durationMinutes)) {
      throw AppointmentException('Doctor has a conflicting appointment at this time');
    }

    final appointment = Appointment(
      patient: patient,
      doctor: doctor,
      dateTime: dateTime,
      reason: reason,
      appointmentType: appointmentType,
      durationMinutes: durationMinutes,
      notes: notes,
      consultationFee: doctor.consultationFee,
    );

    appointments.add(appointment);
    doctor.removeAvailableSlot(dateTime);
    _totalAppointmentsCreated++;

    return appointment;
  }

  /// Updates an existing appointment
  bool updateAppointment(String appointmentId, {
    DateTime? newDateTime,
    String? newReason,
    String? newNotes,
    AppointmentType? newType,
    int? newDuration,
  }) {
    final appointment = getAppointmentById(appointmentId);
    if (appointment == null) return false;

    if (appointment.appointmentStatus == AppointmentStatus.completed ||
        appointment.appointmentStatus == AppointmentStatus.cancelled) {
      throw AppointmentException('Cannot update completed or cancelled appointments');
    }

    if (newDateTime != null && newDateTime != appointment.dateTime) {
      if (!appointment.doctor.isAvailableAt(newDateTime)) {
        throw AppointmentException('Doctor is not available at the new time');
      }
      if (hasConflictingAppointment(appointment.doctor.id, newDateTime, 
          newDuration ?? appointment.durationMinutes, excludeAppointmentId: appointmentId)) {
        throw AppointmentException('Doctor has a conflicting appointment at the new time');
      }
      
      // Update doctor's availability
      appointment.doctor.addAvailableSlot(appointment.dateTime);
      appointment.doctor.removeAvailableSlot(newDateTime);
      appointment.dateTime = newDateTime;
    }

    if (newReason != null) appointment.reason = newReason;
    if (newNotes != null) appointment.updateNotes(newNotes);
    if (newType != null) appointment.appointmentType = newType;
    if (newDuration != null) appointment.durationMinutes = newDuration;

    appointment.updatedAt = DateTime.now();
    return true;
  }

  /// Cancels an appointment
  bool cancelAppointment(String appointmentId, String reason) {
    final appointment = getAppointmentById(appointmentId);
    if (appointment == null) return false;

    appointment.cancelAppointment(reason);
    _totalAppointmentsCancelled++;
    return true;
  }

  /// Confirms an appointment
  bool confirmAppointment(String appointmentId) {
    final appointment = getAppointmentById(appointmentId);
    if (appointment == null) return false;

    appointment.confirmAppointment();
    return true;
  }

  /// Completes an appointment
  bool completeAppointment(String appointmentId) {
    final appointment = getAppointmentById(appointmentId);
    if (appointment == null) return false;

    appointment.completeAppointment();
    _totalAppointmentsCompleted++;
    return true;
  }

  /// Marks an appointment as no-show
  bool markAppointmentAsNoShow(String appointmentId) {
    final appointment = getAppointmentById(appointmentId);
    if (appointment == null) return false;

    appointment.markAsNoShow();
    return true;
  }

  /// Reschedules an appointment
  bool rescheduleAppointment(String appointmentId, DateTime newDateTime) {
    final appointment = getAppointmentById(appointmentId);
    if (appointment == null) return false;

    if (hasConflictingAppointment(appointment.doctor.id, newDateTime, 
        appointment.durationMinutes, excludeAppointmentId: appointmentId)) {
      throw AppointmentException('Doctor has a conflicting appointment at the new time');
    }

    return appointment.rescheduleAppointment(newDateTime);
  }

  /// Gets an appointment by ID
  Appointment? getAppointmentById(String appointmentId) {
    try {
      return appointments.firstWhere((a) => a.appointmentId == appointmentId);
    } catch (e) {
      return null;
    }
  }

  /// Gets a patient by ID
  Patient? getPatientById(String patientId) {
    try {
      return patients.firstWhere((p) => p.id == patientId);
    } catch (e) {
      return null;
    }
  }

  /// Gets a doctor by ID
  Doctor? getDoctorById(String doctorId) {
    try {
      return doctors.firstWhere((d) => d.id == doctorId);
    } catch (e) {
      return null;
    }
  }

  /// Gets all appointments for a specific patient
  List<Appointment> getAppointmentsByPatient(String patientId) {
    return appointments.where((a) => a.patient.id == patientId).toList();
  }

  /// Gets all appointments for a specific doctor
  List<Appointment> getAppointmentsByDoctor(String doctorId) {
    return appointments.where((a) => a.doctor.id == doctorId).toList();
  }

  /// Gets appointments by status
  List<Appointment> getAppointmentsByStatus(AppointmentStatus status) {
    return appointments.where((a) => a.appointmentStatus == status).toList();
  }

  /// Gets appointments for a specific date
  List<Appointment> getAppointmentsByDate(DateTime date) {
    return appointments.where((a) {
      return a.dateTime.year == date.year &&
          a.dateTime.month == date.month &&
          a.dateTime.day == date.day;
    }).toList();
  }

  /// Gets appointments within a date range
  List<Appointment> getAppointmentsInRange(DateTime startDate, DateTime endDate) {
    return appointments.where((a) {
      return a.dateTime.isAfter(startDate.subtract(const Duration(days: 1))) &&
          a.dateTime.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Gets upcoming appointments
  List<Appointment> getUpcomingAppointments() {
    return appointments.where((a) => a.isUpcoming).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  /// Gets overdue appointments
  List<Appointment> getOverdueAppointments() {
    return appointments.where((a) => a.isOverdue).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  /// Gets available doctors for a specific specialty
  List<Doctor> getDoctorsBySpecialty(Specialty specialty) {
    return doctors.where((d) => d.specialty == specialty && d.isActive && d.isAvailable).toList();
  }

  /// Gets available time slots for a doctor on a specific date
  List<DateTime> getAvailableSlots(String doctorId, DateTime date) {
    final doctor = getDoctorById(doctorId);
    if (doctor == null) return [];
    
    return doctor.getAvailableSlotsForDate(date);
  }

  /// Checks if there's a conflicting appointment
  bool hasConflictingAppointment(String doctorId, DateTime dateTime, int durationMinutes, {String? excludeAppointmentId}) {
    final doctorAppointments = getAppointmentsByDoctor(doctorId);
    final newAppointmentEnd = dateTime.add(Duration(minutes: durationMinutes));

    for (final appointment in doctorAppointments) {
      if (excludeAppointmentId != null && appointment.appointmentId == excludeAppointmentId) {
        continue;
      }
      
      if (appointment.appointmentStatus == AppointmentStatus.cancelled ||
          appointment.appointmentStatus == AppointmentStatus.noShow) {
        continue;
      }

      final existingStart = appointment.dateTime;
      final existingEnd = appointment.endTime;

      if (dateTime.isBefore(existingEnd) && newAppointmentEnd.isAfter(existingStart)) {
        return true;
      }
    }
    return false;
  }

  /// Automatically marks overdue appointments as no-show
  void processOverdueAppointments() {
    final overdue = getOverdueAppointments();
    for (final appointment in overdue) {
      if (appointment.appointmentStatus == AppointmentStatus.confirmed) {
        markAppointmentAsNoShow(appointment.appointmentId);
      }
    }
  }

  /// Gets system statistics
  Map<String, dynamic> getSystemStatistics() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayAppointments = getAppointmentsByDate(today);
    
    return {
      'totalPatients': patients.length,
      'totalDoctors': doctors.length,
      'totalAppointments': appointments.length,
      'appointmentsCreated': _totalAppointmentsCreated,
      'appointmentsCancelled': _totalAppointmentsCancelled,
      'appointmentsCompleted': _totalAppointmentsCompleted,
      'todayAppointments': todayAppointments.length,
      'upcomingAppointments': getUpcomingAppointments().length,
      'overdueAppointments': getOverdueAppointments().length,
      'pendingAppointments': getAppointmentsByStatus(AppointmentStatus.pending).length,
      'confirmedAppointments': getAppointmentsByStatus(AppointmentStatus.confirmed).length,
    };
  }

  /// Searches appointments by patient name or doctor name
  List<Appointment> searchAppointments(String query) {
    final lowerQuery = query.toLowerCase();
    return appointments.where((a) {
      return a.patient.name.toLowerCase().contains(lowerQuery) ||
          a.doctor.name.toLowerCase().contains(lowerQuery) ||
          a.reason.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Gets appointments that need attention (overdue, pending confirmation, etc.)
  List<Appointment> getAppointmentsNeedingAttention() {
    final needsAttention = <Appointment>[];
    
    // Add overdue appointments
    needsAttention.addAll(getOverdueAppointments());
    
    // Add pending appointments older than 24 hours
    final pendingAppointments = getAppointmentsByStatus(AppointmentStatus.pending);
    final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));
    needsAttention.addAll(pendingAppointments.where((a) => a.createdAt.isBefore(oneDayAgo)));
    
    return needsAttention;
  }

  /// Clears all data (for testing purposes)
  void clearAllData() {
    appointments.clear();
    patients.clear();
    doctors.clear();
    _totalAppointmentsCreated = 0;
    _totalAppointmentsCancelled = 0;
    _totalAppointmentsCompleted = 0;
  }

  /// Returns a summary of the appointment manager
  @override
  String toString() {
    return 'AppointmentManager{patients: ${patients.length}, doctors: ${doctors.length}, appointments: ${appointments.length}}';
  }
}
