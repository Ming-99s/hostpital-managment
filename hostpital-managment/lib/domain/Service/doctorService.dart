import '../appointment.dart';
import '../doctor.dart';
import 'appointmentManager.dart';
import 'userManager.dart';

class DoctorService {
  final AppointmentManager appointmentManager;
  final UserManager userManager;

  DoctorService({
    required this.appointmentManager,
    required this.userManager,
  });

  // Schedule retrieval
  List<DateTime> getSchedule(Doctor doctor) {
    return List<DateTime>.from(doctor.availableSlots);
  }

  Map<String, List<DateTime>> getScheduleGroupedByDate(Doctor doctor) {
    final slots = getSchedule(doctor);
    final grouped = <String, List<DateTime>>{};
    for (final slot in slots) {
      final key = _dateKey(slot);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(slot);
    }
    for (final key in grouped.keys) {
      grouped[key]!.sort((a, b) => a.compareTo(b));
    }
    return grouped;
  }

  // Appointments retrieval
  List<Appointment> getAppointmentsForDoctor(Doctor doctor) {
    final appointments = appointmentManager.getAllAppointment();
    final filtered = appointments.where((a) => a.doctorId == doctor.id).toList();
    filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return filtered;
  }

  // Lookups
  String getPatientName(String patientId) {
    final patient = userManager.getPatientById(patientId);
    return patient?.username ?? '[Unknown Patient]';
  }

  // Doctor actions on appointments (wrapping AppointmentManager with ownership checks)
  bool approveAppointment(Doctor doctor, String appointmentId) {
    final appt = appointmentManager.getAppointmentById(appointmentId);
    if (appt == null || appt.doctorId != doctor.id) return false;
    appointmentManager.approveAppointment(appointmentId);
    return true;
  }

  bool rejectAppointment(Doctor doctor, String appointmentId) {
    final appt = appointmentManager.getAppointmentById(appointmentId);
    if (appt == null || appt.doctorId != doctor.id) return false;
    appointmentManager.rejectAppointment(appointmentId);
    return true;
  }

  bool cancelAppointment(Doctor doctor, String appointmentId) {
    final appt = appointmentManager.getAppointmentById(appointmentId);
    if (appt == null || appt.doctorId != doctor.id) return false;
    appointmentManager.cancelAppointment(appointmentId);
    return true;
  }

  bool deleteAppointment(Doctor doctor, String appointmentId) {
    final appt = appointmentManager.getAppointmentById(appointmentId);
    if (appt == null || appt.doctorId != doctor.id) return false;
    appointmentManager.removeAppointment(appointmentId);
    return true;
  }

  // Availability management
  bool addTimeSlot(Doctor doctor, DateTime dt) {
    final now = DateTime.now();
    if (!dt.isAfter(now)) {
      return false; // must be future time
    }
    if (doctor.availableSlots.any((s) => _sameMinute(s, dt))) {
      return false; // duplicate
    }

    doctor.availableSlots.add(dt);
    doctor.availableSlots.sort((a, b) => a.compareTo(b));

    // persist
    final users = userManager.getallUser();
    userManager.updateDoctor(doctor, users);
    return true;
  }

  bool removeTimeSlotByIndex(Doctor doctor, int index) {
    if (index < 0 || index >= doctor.availableSlots.length) {
      return false;
    }
    doctor.availableSlots.removeAt(index);

    // persist
    final users = userManager.getallUser();
    userManager.updateDoctor(doctor, users);
    return true;
  }

  // Parsing & formatting
  DateTime? parseDateTime(String date, String time) {
    try {
      final dateParts = date.split('-').map(int.parse).toList(); // YYYY-MM-DD
      final timeParts = time.split(':').map(int.parse).toList(); // HH:MM
      return DateTime(dateParts[0], dateParts[1], dateParts[2], timeParts[0], timeParts[1]);
    } catch (_) {
      return null;
    }
  }

  String formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  String formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  // helpers
  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  bool _sameMinute(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day && a.hour == b.hour && a.minute == b.minute;
}