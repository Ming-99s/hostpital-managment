import 'dart:io';
import 'dart:convert';
import '../domain/appointment.dart';

class AppointmentRepository {
  final String filePath;

  AppointmentRepository(this.filePath);

  List<Appointment> readAppointments() {
    final file = File(filePath);

    if (!file.existsSync()) {
      file.writeAsStringSync(jsonEncode({'appointments': []}));
      return [];
    }

    final content = file.readAsStringSync().trim();
    if (content.isEmpty) return [];

    try {
      final data = jsonDecode(content);
      final appointmentsJson = data['appointments'] as List;

      return appointmentsJson.map((a) {
        return Appointment(
          appointmentId: a['appointmentId'],
          patientId: a['patientId'],
          doctorId: a['doctorId'],
          dateTime: DateTime.parse(a['dateTime']),
          appointmentStatus: AppointmentStatus.values.firstWhere(
            (s) => s.toString() == a['appointmentStatus'],
            orElse: () => AppointmentStatus.pending,
          ),
        );
      }).toList();
    } catch (e) {
      print('Error reading appointments: $e');
      return [];
    }
  }

  void writeAppointments(List<Appointment> appointments) {
    final file = File(filePath);

    final data = {
      'appointments': appointments.map((a) => {
            'appointmentId': a.appointmentId,
            'patientId': a.patientId,
            'doctorId': a.doctorId,
            'dateTime': a.dateTime.toIso8601String(),
            'appointmentStatus': a.appointmentStatus.toString(),
          }).toList(),
    };

    file.writeAsStringSync(JsonEncoder.withIndent('  ').convert(data));
  }
}
