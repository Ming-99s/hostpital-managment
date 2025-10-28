import 'doctor.dart';
import 'patient.dart';
import 'package:uuid/uuid.dart';

/// Enumeration of appointment statuses
enum AppointmentStatus {
  pending,
  confirmed,
  cancelled,
  completed,
  noShow,
  rescheduled,
}

/// Extension to provide human-readable names for appointment statuses
extension AppointmentStatusExtension on AppointmentStatus {
  String get displayName {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.noShow:
        return 'No Show';
      case AppointmentStatus.rescheduled:
        return 'Rescheduled';
    }
  }

  /// Returns the color associated with each status for UI purposes
  String get colorCode {
    switch (this) {
      case AppointmentStatus.pending:
        return '#FFA500'; // Orange
      case AppointmentStatus.confirmed:
        return '#008000'; // Green
      case AppointmentStatus.cancelled:
        return '#FF0000'; // Red
      case AppointmentStatus.completed:
        return '#0000FF'; // Blue
      case AppointmentStatus.noShow:
        return '#800080'; // Purple
      case AppointmentStatus.rescheduled:
        return '#FFD700'; // Gold
    }
  }
}

/// Enumeration of appointment types
enum AppointmentType {
  consultation,
  followUp,
  checkup,
  surgery,
  emergency,
  vaccination,
  therapy,
  diagnostic,
}

/// Extension for appointment type display names
extension AppointmentTypeExtension on AppointmentType {
  String get displayName {
    switch (this) {
      case AppointmentType.consultation:
        return 'Consultation';
      case AppointmentType.followUp:
        return 'Follow-up';
      case AppointmentType.checkup:
        return 'Check-up';
      case AppointmentType.surgery:
        return 'Surgery';
      case AppointmentType.emergency:
        return 'Emergency';
      case AppointmentType.vaccination:
        return 'Vaccination';
      case AppointmentType.therapy:
        return 'Therapy';
      case AppointmentType.diagnostic:
        return 'Diagnostic';
    }
  }
}

/// Appointment class for managing medical appointments in the hospital system
class Appointment {
  final String appointmentId;
  final Patient patient;
  final Doctor doctor;
  DateTime dateTime;
  AppointmentStatus appointmentStatus;
  AppointmentType appointmentType;
  int durationMinutes;
  String reason;
  String notes;
  final DateTime createdAt;
  DateTime? updatedAt;
  String? cancellationReason;
  DateTime? completedAt;
  double? consultationFee;

  /// Constructor for creating a new Appointment instance
  Appointment({
    required this.patient,
    required this.doctor,
    required this.dateTime,
    required this.reason,
    this.appointmentStatus = AppointmentStatus.pending,
    this.appointmentType = AppointmentType.consultation,
    this.durationMinutes = 30,
    this.notes = '',
    this.consultationFee,
  })  : appointmentId = const Uuid().v4(),
        createdAt = DateTime.now();

  /// Confirms the appointment
  void confirmAppointment() {
    if (appointmentStatus == AppointmentStatus.pending) {
      appointmentStatus = AppointmentStatus.confirmed;
      updatedAt = DateTime.now();
    }
  }

  /// Cancels the appointment with a reason
  void cancelAppointment(String reason) {
    if (appointmentStatus != AppointmentStatus.completed &&
        appointmentStatus != AppointmentStatus.cancelled) {
      appointmentStatus = AppointmentStatus.cancelled;
      cancellationReason = reason;
      updatedAt = DateTime.now();
      
      // Add the slot back to doctor's available slots
      doctor.addAvailableSlot(dateTime);
    }
  }

  /// Marks the appointment as completed
  void completeAppointment() {
    if (appointmentStatus == AppointmentStatus.confirmed) {
      appointmentStatus = AppointmentStatus.completed;
      completedAt = DateTime.now();
      updatedAt = DateTime.now();
      
      // Update patient's last visit
      patient.updateLastVisit(dateTime);
    }
  }

  /// Marks the appointment as no-show
  void markAsNoShow() {
    if (appointmentStatus == AppointmentStatus.confirmed && 
        DateTime.now().isAfter(dateTime.add(Duration(minutes: 15)))) {
      appointmentStatus = AppointmentStatus.noShow;
      updatedAt = DateTime.now();
      
      // Add the slot back to doctor's available slots for future bookings
      doctor.addAvailableSlot(dateTime);
    }
  }

  /// Reschedules the appointment to a new date and time
  bool rescheduleAppointment(DateTime newDateTime) {
    if (appointmentStatus != AppointmentStatus.completed &&
        appointmentStatus != AppointmentStatus.cancelled &&
        doctor.isAvailableAt(newDateTime)) {
      
      // Add old slot back to doctor's availability
      doctor.addAvailableSlot(dateTime);
      
      // Remove new slot from doctor's availability
      doctor.removeAvailableSlot(newDateTime);
      
      // Update appointment details
      dateTime = newDateTime;
      appointmentStatus = AppointmentStatus.rescheduled;
      updatedAt = DateTime.now();
      
      return true;
    }
    return false;
  }

  /// Checks if the appointment is upcoming (in the future)
  bool get isUpcoming {
    return dateTime.isAfter(DateTime.now()) && 
           (appointmentStatus == AppointmentStatus.pending || 
            appointmentStatus == AppointmentStatus.confirmed);
  }

  /// Checks if the appointment is overdue
  bool get isOverdue {
    return dateTime.isBefore(DateTime.now()) && 
           appointmentStatus == AppointmentStatus.confirmed;
  }

  /// Gets the duration until the appointment
  Duration? get timeUntilAppointment {
    if (isUpcoming) {
      return dateTime.difference(DateTime.now());
    }
    return null;
  }

  /// Gets the appointment end time
  DateTime get endTime {
    return dateTime.add(Duration(minutes: durationMinutes));
  }

  /// Checks if the appointment conflicts with another appointment
  bool conflictsWith(Appointment other) {
    if (doctor.id != other.doctor.id) return false;
    
    final thisStart = dateTime;
    final thisEnd = endTime;
    final otherStart = other.dateTime;
    final otherEnd = other.endTime;
    
    return (thisStart.isBefore(otherEnd) && thisEnd.isAfter(otherStart));
  }

  /// Updates appointment notes
  void updateNotes(String newNotes) {
    notes = newNotes;
    updatedAt = DateTime.now();
  }

  /// Sets the consultation fee
  void setConsultationFee(double fee) {
    consultationFee = fee;
    updatedAt = DateTime.now();
  }

  /// Gets a summary of the appointment
  Map<String, dynamic> getAppointmentSummary() {
    return {
      'appointmentId': appointmentId,
      'patientName': patient.name,
      'doctorName': doctor.name,
      'specialty': doctor.specialty.displayName,
      'dateTime': dateTime.toString(),
      'status': appointmentStatus.displayName,
      'type': appointmentType.displayName,
      'duration': '$durationMinutes minutes',
      'reason': reason,
      'consultationFee': consultationFee ?? doctor.consultationFee,
      'isUpcoming': isUpcoming,
      'isOverdue': isOverdue,
    };
  }

  /// Validates if the appointment can be scheduled
  static bool canSchedule(Doctor doctor, DateTime dateTime) {
    return doctor.isAvailableAt(dateTime) && 
           dateTime.isAfter(DateTime.now());
  }

  /// Returns a string representation of the appointment
  @override
  String toString() {
    return 'Appointment{id: $appointmentId, patient: ${patient.name}, '
           'doctor: ${doctor.name}, dateTime: $dateTime, '
           'status: ${appointmentStatus.displayName}, type: ${appointmentType.displayName}}';
  }

  /// Checks if two appointments are equal based on their ID
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Appointment && other.appointmentId == appointmentId;
  }

  /// Returns the hash code for the appointment based on its ID
  @override
  int get hashCode => appointmentId.hashCode;
}
