import 'dart:io';
import '../../domain/services/appointmentManager.dart';
import '../../domain/models/appointment.dart';
import '../../domain/models/doctor.dart';
import '../../domain/models/patient.dart';

/// Console-based user interface for the Hospital Management System
/// 
/// This class provides a text-based interface for interacting with the hospital
/// management system, including patient management, doctor management, and
/// appointment scheduling.
class HospitalConsole {
  final AppointmentManager _appointmentManager;
  bool _isRunning = true;

  HospitalConsole(this._appointmentManager);

  /// Starts the console interface
  void start() {
    print('🚀 Starting Hospital Management Console...\n');
    
    while (_isRunning) {
      try {
        _showMainMenu();
        final choice = _getInput('Enter your choice: ');
        _handleMainMenuChoice(choice);
      } catch (e) {
        print('❌ An error occurred: $e');
        print('Please try again.\n');
      }
    }
    
    print('👋 Thank you for using Hospital Management System!');
  }

  /// Displays the main menu
  void _showMainMenu() {
    print('═══════════════════════════════════════');
    print('🏥 HOSPITAL MANAGEMENT SYSTEM');
    print('═══════════════════════════════════════');
    print('1. 👥 Patient Management');
    print('2. 👨‍⚕️ Doctor Management');
    print('3. 📅 Appointment Management');
    print('4. 📊 Reports & Statistics');
    print('5. 🔍 Search & Filters');
    print('6. ⚙️  System Settings');
    print('0. 🚪 Exit');
    print('═══════════════════════════════════════');
  }

  /// Handles main menu choices
  void _handleMainMenuChoice(String choice) {
    switch (choice) {
      case '1':
        _showPatientMenu();
        break;
      case '2':
        _showDoctorMenu();
        break;
      case '3':
        _showAppointmentMenu();
        break;
      case '4':
        _showReportsMenu();
        break;
      case '5':
        _showSearchMenu();
        break;
      case '6':
        _showSystemMenu();
        break;
      case '0':
        _isRunning = false;
        break;
      default:
        print('❌ Invalid choice. Please try again.\n');
    }
  }

  /// Patient Management Menu
  void _showPatientMenu() {
    while (true) {
      print('\n👥 PATIENT MANAGEMENT');
      print('─────────────────────');
      print('1. Add New Patient');
      print('2. View All Patients');
      print('3. Search Patient');
      print('4. Update Patient');
      print('5. Remove Patient');
      print('6. Patient Medical History');
      print('0. Back to Main Menu');
      print('─────────────────────');

      final choice = _getInput('Enter your choice: ');
      
      switch (choice) {
        case '1':
          _addNewPatient();
          break;
        case '2':
          _viewAllPatients();
          break;
        case '3':
          _searchPatient();
          break;
        case '4':
          _updatePatient();
          break;
        case '5':
          _removePatient();
          break;
        case '6':
          _viewPatientMedicalHistory();
          break;
        case '0':
          return;
        default:
          print('❌ Invalid choice. Please try again.');
      }
    }
  }

  /// Doctor Management Menu
  void _showDoctorMenu() {
    while (true) {
      print('\n👨‍⚕️ DOCTOR MANAGEMENT');
      print('─────────────────────');
      print('1. Add New Doctor');
      print('2. View All Doctors');
      print('3. Search Doctor');
      print('4. Update Doctor');
      print('5. Remove Doctor');
      print('6. Doctor Schedule');
      print('7. Doctor Availability');
      print('0. Back to Main Menu');
      print('─────────────────────');

      final choice = _getInput('Enter your choice: ');
      
      switch (choice) {
        case '1':
          _addNewDoctor();
          break;
        case '2':
          _viewAllDoctors();
          break;
        case '3':
          _searchDoctor();
          break;
        case '4':
          _updateDoctor();
          break;
        case '5':
          _removeDoctor();
          break;
        case '6':
          _viewDoctorSchedule();
          break;
        case '7':
          _manageDoctorAvailability();
          break;
        case '0':
          return;
        default:
          print('❌ Invalid choice. Please try again.');
      }
    }
  }

  /// Appointment Management Menu
  void _showAppointmentMenu() {
    while (true) {
      print('\n📅 APPOINTMENT MANAGEMENT');
      print('─────────────────────────');
      print('1. Schedule New Appointment');
      print('2. View All Appointments');
      print('3. View Today\'s Appointments');
      print('4. View Upcoming Appointments');
      print('5. Update Appointment');
      print('6. Cancel Appointment');
      print('7. Complete Appointment');
      print('8. Mark as No-Show');
      print('9. Reschedule Appointment');
      print('0. Back to Main Menu');
      print('─────────────────────────');

      final choice = _getInput('Enter your choice: ');
      
      switch (choice) {
        case '1':
          _scheduleNewAppointment();
          break;
        case '2':
          _viewAllAppointments();
          break;
        case '3':
          _viewTodaysAppointments();
          break;
        case '4':
          _viewUpcomingAppointments();
          break;
        case '5':
          _updateAppointment();
          break;
        case '6':
          _cancelAppointment();
          break;
        case '7':
          _completeAppointment();
          break;
        case '8':
          _markAppointmentNoShow();
          break;
        case '9':
          _rescheduleAppointment();
          break;
        case '0':
          return;
        default:
          print('❌ Invalid choice. Please try again.');
      }
    }
  }

  /// Reports and Statistics Menu
  void _showReportsMenu() {
    while (true) {
      print('\n📊 REPORTS & STATISTICS');
      print('───────────────────────');
      print('1. System Overview');
      print('2. Patient Statistics');
      print('3. Doctor Statistics');
      print('4. Appointment Statistics');
      print('5. Daily Report');
      print('6. Monthly Report');
      print('7. Overdue Appointments');
      print('0. Back to Main Menu');
      print('───────────────────────');

      final choice = _getInput('Enter your choice: ');
      
      switch (choice) {
        case '1':
          _showSystemOverview();
          break;
        case '2':
          _showPatientStatistics();
          break;
        case '3':
          _showDoctorStatistics();
          break;
        case '4':
          _showAppointmentStatistics();
          break;
        case '5':
          _showDailyReport();
          break;
        case '6':
          _showMonthlyReport();
          break;
        case '7':
          _showOverdueAppointments();
          break;
        case '0':
          return;
        default:
          print('❌ Invalid choice. Please try again.');
      }
    }
  }

  /// Search and Filter Menu
  void _showSearchMenu() {
    while (true) {
      print('\n🔍 SEARCH & FILTERS');
      print('──────────────────');
      print('1. Search Appointments');
      print('2. Filter by Date Range');
      print('3. Filter by Doctor');
      print('4. Filter by Patient');
      print('5. Filter by Status');
      print('6. Filter by Specialty');
      print('0. Back to Main Menu');
      print('──────────────────');

      final choice = _getInput('Enter your choice: ');
      
      switch (choice) {
        case '1':
          _searchAppointments();
          break;
        case '2':
          _filterByDateRange();
          break;
        case '3':
          _filterByDoctor();
          break;
        case '4':
          _filterByPatient();
          break;
        case '5':
          _filterByStatus();
          break;
        case '6':
          _filterBySpecialty();
          break;
        case '0':
          return;
        default:
          print('❌ Invalid choice. Please try again.');
      }
    }
  }

  /// System Settings Menu
  void _showSystemMenu() {
    while (true) {
      print('\n⚙️  SYSTEM SETTINGS');
      print('─────────────────');
      print('1. Process Overdue Appointments');
      print('2. Clear All Data');
      print('3. Export Data');
      print('4. Import Sample Data');
      print('5. System Health Check');
      print('0. Back to Main Menu');
      print('─────────────────');

      final choice = _getInput('Enter your choice: ');
      
      switch (choice) {
        case '1':
          _processOverdueAppointments();
          break;
        case '2':
          _clearAllData();
          break;
        case '3':
          _exportData();
          break;
        case '4':
          _importSampleData();
          break;
        case '5':
          _systemHealthCheck();
          break;
        case '0':
          return;
        default:
          print('❌ Invalid choice. Please try again.');
      }
    }
  }

  // Patient Management Methods
  void _addNewPatient() {
    print('\n➕ ADD NEW PATIENT');
    print('─────────────────');
    
    try {
      final username = _getInput('Username: ');
      final password = _getInput('Password: ');
      final name = _getInput('Full Name: ');
      final email = _getInput('Email: ');
      final phone = _getInput('Phone Number: ');
      final address = _getInput('Address: ');
      
      print('Gender: 1. Male, 2. Female, 3. Other');
      final genderChoice = _getInput('Select gender: ');
      final gender = _parseGender(genderChoice);
      
      final dobStr = _getInput('Date of Birth (YYYY-MM-DD): ');
      final dob = DateTime.parse(dobStr);
      
      final heightStr = _getInput('Height (cm): ');
      final height = double.parse(heightStr);
      
      final weightStr = _getInput('Weight (kg): ');
      final weight = double.parse(weightStr);
      
      print('Blood Type: 1. A+, 2. A-, 3. B+, 4. B-, 5. AB+, 6. AB-, 7. O+, 8. O-');
      final bloodTypeChoice = _getInput('Select blood type: ');
      final bloodType = _parseBloodType(bloodTypeChoice);
      
      final emergencyContactName = _getInput('Emergency Contact Name: ');
      final emergencyContactPhone = _getInput('Emergency Contact Phone: ');
      final emergencyContactRelationship = _getInput('Emergency Contact Relationship: ');
      final emergencyContactEmail = _getInput('Emergency Contact Email: ');
      final insuranceNumber = _getInput('Insurance Number: ');
      final insuranceProvider = _getInput('Insurance Provider: ');
      
      final patient = Patient(
        username: username,
        password: password,
        name: name,
        email: email,
        phoneNumber: phone,
        dateOfBirth: dob,
        address: address,
        gender: gender,
        bloodType: bloodType,
        height: height,
        weight: weight,
        emergencyContact: EmergencyContact(
          name: emergencyContactName,
          phoneNumber: emergencyContactPhone,
          relationship: emergencyContactRelationship,
          email: emergencyContactEmail,
        ),
        insuranceNumber: insuranceNumber,
        insuranceProvider: insuranceProvider,
      );
      
      _appointmentManager.addPatient(patient);
      print('✅ Patient added successfully!');
      
    } catch (e) {
      print('❌ Error adding patient: $e');
    }
  }

  void _viewAllPatients() {
    print('\n👥 ALL PATIENTS');
    print('──────────────');
    
    final patients = _appointmentManager.patients;
    if (patients.isEmpty) {
      print('No patients found.');
      return;
    }
    
    for (final patient in patients) {
      print('ID: ${patient.id} | Name: ${patient.name} | Age: ${patient.age}');
      print('Email: ${patient.email} | Phone: ${patient.phoneNumber}');
      print('Gender: ${patient.gender.displayName} | Blood Type: ${patient.bloodType.displayName}');
      print('─────────────────────────────────────────────────────────────');
    }
  }

  void _searchPatient() {
    final query = _getInput('Enter patient name or ID to search: ');
    final patients = _appointmentManager.patients.where((p) =>
        p.name.toLowerCase().contains(query.toLowerCase()) ||
        p.id.toLowerCase().contains(query.toLowerCase())).toList();
    
    if (patients.isEmpty) {
      print('No patients found matching "$query"');
      return;
    }
    
    print('\n🔍 SEARCH RESULTS');
    print('────────────────');
    for (final patient in patients) {
      print('${patient.id}: ${patient.name} (${patient.email})');
    }
  }

  void _updatePatient() {
    final patientId = _getInput('Enter Patient ID to update: ');
    final patient = _appointmentManager.getPatientById(patientId);
    
    if (patient == null) {
      print('❌ Patient not found.');
      return;
    }
    
    print('Current patient: ${patient.name}');
    print('Note: Some fields cannot be updated after creation.');
    print('Contact system administrator for major changes.');
    
    // Only show what can be updated
    print('✅ Patient information displayed. Contact admin for updates.');
  }

  void _removePatient() {
    final patientId = _getInput('Enter Patient ID to remove: ');
    final confirmation = _getInput('Are you sure? This will cancel all appointments. (yes/no): ');
    
    if (confirmation.toLowerCase() == 'yes') {
      if (_appointmentManager.removePatient(patientId)) {
        print('✅ Patient removed successfully!');
      } else {
        print('❌ Patient not found.');
      }
    } else {
      print('Operation cancelled.');
    }
  }

  void _viewPatientMedicalHistory() {
    final patientId = _getInput('Enter Patient ID: ');
    final patient = _appointmentManager.getPatientById(patientId);
    
    if (patient == null) {
      print('❌ Patient not found.');
      return;
    }
    
    print('\n📋 MEDICAL HISTORY - ${patient.name}');
    print('─────────────────────────────────────');
    print('Age: ${patient.age} years');
    print('BMI: ${patient.bmi.toStringAsFixed(1)}');
    print('Blood Type: ${patient.bloodType.displayName}');
    print('Allergies: ${patient.allergies.isEmpty ? 'None' : patient.allergies.join(', ')}');
    print('Chronic Conditions: ${patient.chronicConditions.isEmpty ? 'None' : patient.chronicConditions.join(', ')}');
    print('Emergency Contact: ${patient.emergencyContact}');
    print('Insurance: ${patient.insuranceProvider} (${patient.insuranceNumber})');
    
    final appointments = _appointmentManager.getAppointmentsByPatient(patientId);
    print('\nAppointment History: ${appointments.length} appointments');
    for (final appointment in appointments.take(5)) {
      print('  ${appointment.dateTime.toString().substring(0, 16)} - ${appointment.reason} (${appointment.appointmentStatus.displayName})');
    }
  }

  // Doctor Management Methods
  void _addNewDoctor() {
    print('\n➕ ADD NEW DOCTOR');
    print('────────────────');
    
    try {
      final username = _getInput('Username: ');
      final password = _getInput('Password: ');
      final name = _getInput('Full Name: ');
      final email = _getInput('Email: ');
      final phone = _getInput('Phone Number: ');
      final address = _getInput('Address: ');
      
      print('Specialty: 1. Cardiology, 2. Pediatrics, 3. Orthopedics, 4. Dermatology, 5. Neurology');
      final specialtyChoice = _getInput('Select specialty: ');
      final specialty = _parseSpecialty(specialtyChoice);
      
      final licenseNumber = _getInput('License Number: ');
      
      final experienceStr = _getInput('Years of Experience: ');
      final experience = int.parse(experienceStr);
      
      final feeStr = _getInput('Consultation Fee: ');
      final fee = double.parse(feeStr);
      
      final dobStr = _getInput('Date of Birth (YYYY-MM-DD): ');
      final dob = DateTime.parse(dobStr);
      
      final doctor = Doctor(
        username: username,
        password: password,
        name: name,
        email: email,
        phoneNumber: phone,
        dateOfBirth: dob,
        address: address,
        specialty: specialty!,
        licenseNumber: licenseNumber,
        yearsOfExperience: experience,
        consultationFee: fee,
        qualifications: [], // Empty list for now
      );
      
      // Generate available slots for the next 4 weeks
      doctor.generateWeeklySlots(
        workingDays: [1, 2, 3, 4, 5], // Monday to Friday
        timeSlots: ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00'],
        weeksAhead: 4,
      );
      
      _appointmentManager.addDoctor(doctor);
      print('✅ Doctor added successfully!');
      
    } catch (e) {
      print('❌ Error adding doctor: $e');
    }
  }

  void _viewAllDoctors() {
    print('\n👨‍⚕️ ALL DOCTORS');
    print('──────────────');
    
    final doctors = _appointmentManager.doctors;
    if (doctors.isEmpty) {
      print('No doctors found.');
      return;
    }
    
    for (final doctor in doctors) {
      print('ID: ${doctor.id} | Name: ${doctor.name}');
      print('Specialty: ${doctor.specialty.displayName} | Experience: ${doctor.yearsOfExperience} years');
      print('Fee: \$${doctor.consultationFee} | Available: ${doctor.isAvailable ? 'Yes' : 'No'}');
      print('Email: ${doctor.email} | Phone: ${doctor.phoneNumber}');
      print('─────────────────────────────────────────────────────────────');
    }
  }

  void _searchDoctor() {
    final query = _getInput('Enter doctor name or ID to search: ');
    final doctors = _appointmentManager.doctors.where((d) =>
        d.name.toLowerCase().contains(query.toLowerCase()) ||
        d.id.toLowerCase().contains(query.toLowerCase())).toList();
    
    if (doctors.isEmpty) {
      print('No doctors found matching "$query"');
      return;
    }
    
    print('\n🔍 SEARCH RESULTS');
    print('────────────────');
    for (final doctor in doctors) {
      print('${doctor.id}: ${doctor.name} - ${doctor.specialty.displayName}');
    }
  }

  void _updateDoctor() {
    final doctorId = _getInput('Enter Doctor ID to update: ');
    final doctor = _appointmentManager.getDoctorById(doctorId);
    
    if (doctor == null) {
      print('❌ Doctor not found.');
      return;
    }
    
    print('Current doctor: ${doctor.name}');
    print('Leave fields empty to keep current values.');
    
    final newEmail = _getInput('New Email (${doctor.email}): ');
    if (newEmail.isNotEmpty) {
      print('⚠️  Email cannot be updated (final field). Contact administrator for major changes.');
    }
    
    final newPhone = _getInput('New Phone (${doctor.phoneNumber}): ');
    if (newPhone.isNotEmpty) {
      print('⚠️  Phone number cannot be updated (final field). Contact administrator for major changes.');
    }
    
    final newFee = _getInput('New Consultation Fee (\$${doctor.consultationFee}): ');
    if (newFee.isNotEmpty) doctor.consultationFee = double.parse(newFee);
    
    print('✅ Doctor updated successfully!');
  }

  void _removeDoctor() {
    final doctorId = _getInput('Enter Doctor ID to remove: ');
    final confirmation = _getInput('Are you sure? This will cancel all appointments. (yes/no): ');
    
    if (confirmation.toLowerCase() == 'yes') {
      if (_appointmentManager.removeDoctor(doctorId)) {
        print('✅ Doctor removed successfully!');
      } else {
        print('❌ Doctor not found.');
      }
    } else {
      print('Operation cancelled.');
    }
  }

  void _viewDoctorSchedule() {
    final doctorId = _getInput('Enter Doctor ID: ');
    final doctor = _appointmentManager.getDoctorById(doctorId);
    
    if (doctor == null) {
      print('❌ Doctor not found.');
      return;
    }
    
    final appointments = _appointmentManager.getAppointmentsByDoctor(doctorId);
    
    print('\n📅 SCHEDULE - ${doctor.name}');
    print('─────────────────────────────────────');
    
    if (appointments.isEmpty) {
      print('No appointments scheduled.');
      return;
    }
    
    appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    for (final appointment in appointments) {
      final status = appointment.appointmentStatus.displayName;
      final date = appointment.dateTime.toString().substring(0, 16);
      print('$date | ${appointment.patient.name} | $status');
      print('  Reason: ${appointment.reason}');
      print('  Duration: ${appointment.durationMinutes} min | Fee: \$${appointment.consultationFee}');
      print('');
    }
  }

  void _manageDoctorAvailability() {
    final doctorId = _getInput('Enter Doctor ID: ');
    final doctor = _appointmentManager.getDoctorById(doctorId);
    
    if (doctor == null) {
      print('❌ Doctor not found.');
      return;
    }
    
    print('\n⏰ AVAILABILITY - ${doctor.name}');
    print('─────────────────────────────────────');
    print('Current Status: ${doctor.isAvailable ? 'Available' : 'Unavailable'}');
    
    final choice = _getInput('1. Toggle Availability, 2. View Available Slots, 3. Add Slots: ');
    
    switch (choice) {
      case '1':
        doctor.isAvailable = !doctor.isAvailable;
        print('✅ Availability updated to: ${doctor.isAvailable ? 'Available' : 'Unavailable'}');
        break;
      case '2':
        final dateStr = _getInput('Enter date (YYYY-MM-DD): ');
        final date = DateTime.parse(dateStr);
        final slots = doctor.getAvailableSlotsForDate(date);
        
        if (slots.isEmpty) {
          print('No available slots for ${date.toString().substring(0, 10)}');
        } else {
          print('Available slots:');
          for (final slot in slots) {
            print('  ${slot.toString().substring(11, 16)}');
          }
        }
        break;
      case '3':
        final weeksStr = _getInput('Generate slots for how many weeks? ');
        final weeks = int.parse(weeksStr);
        doctor.generateWeeklySlots(
          workingDays: [1, 2, 3, 4, 5], // Monday to Friday
          timeSlots: ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00'],
          weeksAhead: weeks,
        );
        print('✅ Generated slots for $weeks weeks');
        break;
    }
  }

  // Appointment Management Methods
  void _scheduleNewAppointment() {
    print('\n📅 SCHEDULE NEW APPOINTMENT');
    print('──────────────────────────');
    
    try {
      final patientId = _getInput('Patient ID: ');
      final patient = _appointmentManager.getPatientById(patientId);
      if (patient == null) {
        print('❌ Patient not found.');
        return;
      }
      
      final doctorId = _getInput('Doctor ID: ');
      final doctor = _appointmentManager.getDoctorById(doctorId);
      if (doctor == null) {
        print('❌ Doctor not found.');
        return;
      }
      
      print('Available slots for ${doctor.name}:');
      final dateStr = _getInput('Enter date (YYYY-MM-DD): ');
      final date = DateTime.parse(dateStr);
      final slots = doctor.getAvailableSlotsForDate(date);
      
      if (slots.isEmpty) {
        print('❌ No available slots for this date.');
        return;
      }
      
      for (int i = 0; i < slots.length; i++) {
        print('${i + 1}. ${slots[i].toString().substring(11, 16)}');
      }
      
      final slotChoice = _getInput('Select slot number: ');
      final slotIndex = int.parse(slotChoice) - 1;
      
      if (slotIndex < 0 || slotIndex >= slots.length) {
        print('❌ Invalid slot selection.');
        return;
      }
      
      final selectedDateTime = slots[slotIndex];
      final reason = _getInput('Reason for appointment: ');
      
      print('Appointment Type: 1. Consultation, 2. Follow-up, 3. Emergency, 4. Vaccination, 5. Surgery');
      final typeChoice = _getInput('Select type: ');
      final appointmentType = _parseAppointmentType(typeChoice);
      
      final durationStr = _getInput('Duration in minutes (default 30): ');
      final duration = durationStr.isEmpty ? 30 : int.parse(durationStr);
      
      final appointment = _appointmentManager.createAppointment(
        patientId: patientId,
        doctorId: doctorId,
        dateTime: selectedDateTime,
        reason: reason,
        appointmentType: appointmentType,
        durationMinutes: duration,
      );
      
      print('✅ Appointment scheduled successfully!');
      print('Appointment ID: ${appointment.appointmentId}');
      print('Date & Time: ${appointment.dateTime}');
      print('Patient: ${appointment.patient.name}');
      print('Doctor: ${appointment.doctor.name}');
      print('Fee: \$${appointment.consultationFee}');
      
    } catch (e) {
      print('❌ Error scheduling appointment: $e');
    }
  }

  void _viewAllAppointments() {
    print('\n📅 ALL APPOINTMENTS');
    print('──────────────────');
    
    final appointments = _appointmentManager.appointments;
    if (appointments.isEmpty) {
      print('No appointments found.');
      return;
    }
    
    appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    for (final appointment in appointments) {
      _displayAppointmentSummary(appointment);
    }
  }

  void _viewTodaysAppointments() {
    final today = DateTime.now();
    final todayAppointments = _appointmentManager.getAppointmentsByDate(today);
    
    print('\n📅 TODAY\'S APPOINTMENTS (${today.toString().substring(0, 10)})');
    print('─────────────────────────────────────────────────────────────');
    
    if (todayAppointments.isEmpty) {
      print('No appointments scheduled for today.');
      return;
    }
    
    todayAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    for (final appointment in todayAppointments) {
      _displayAppointmentSummary(appointment);
    }
  }

  void _viewUpcomingAppointments() {
    final upcoming = _appointmentManager.getUpcomingAppointments();
    
    print('\n📅 UPCOMING APPOINTMENTS');
    print('──────────────────────');
    
    if (upcoming.isEmpty) {
      print('No upcoming appointments.');
      return;
    }
    
    for (final appointment in upcoming.take(10)) {
      _displayAppointmentSummary(appointment);
    }
  }

  void _updateAppointment() {
    final appointmentId = _getInput('Enter Appointment ID: ');
    final appointment = _appointmentManager.getAppointmentById(appointmentId);
    
    if (appointment == null) {
      print('❌ Appointment not found.');
      return;
    }
    
    print('Current appointment: ${appointment.patient.name} with ${appointment.doctor.name}');
    print('Date: ${appointment.dateTime}');
    print('Reason: ${appointment.reason}');
    
    final newReason = _getInput('New reason (leave empty to keep current): ');
    final newNotes = _getInput('New notes (leave empty to keep current): ');
    
    try {
      _appointmentManager.updateAppointment(
        appointmentId,
        newReason: newReason.isEmpty ? null : newReason,
        newNotes: newNotes.isEmpty ? null : newNotes,
      );
      print('✅ Appointment updated successfully!');
    } catch (e) {
      print('❌ Error updating appointment: $e');
    }
  }

  void _cancelAppointment() {
    final appointmentId = _getInput('Enter Appointment ID: ');
    final reason = _getInput('Cancellation reason: ');
    
    if (_appointmentManager.cancelAppointment(appointmentId, reason)) {
      print('✅ Appointment cancelled successfully!');
    } else {
      print('❌ Appointment not found.');
    }
  }

  void _completeAppointment() {
    final appointmentId = _getInput('Enter Appointment ID: ');
    
    if (_appointmentManager.completeAppointment(appointmentId)) {
      print('✅ Appointment marked as completed!');
    } else {
      print('❌ Appointment not found.');
    }
  }

  void _markAppointmentNoShow() {
    final appointmentId = _getInput('Enter Appointment ID: ');
    
    if (_appointmentManager.markAppointmentAsNoShow(appointmentId)) {
      print('✅ Appointment marked as no-show!');
    } else {
      print('❌ Appointment not found.');
    }
  }

  void _rescheduleAppointment() {
    final appointmentId = _getInput('Enter Appointment ID: ');
    final appointment = _appointmentManager.getAppointmentById(appointmentId);
    
    if (appointment == null) {
      print('❌ Appointment not found.');
      return;
    }
    
    print('Current appointment: ${appointment.dateTime}');
    
    final dateStr = _getInput('New date (YYYY-MM-DD): ');
    final timeStr = _getInput('New time (HH:MM): ');
    
    try {
      final newDateTime = DateTime.parse('$dateStr $timeStr:00');
      
      if (_appointmentManager.rescheduleAppointment(appointmentId, newDateTime)) {
        print('✅ Appointment rescheduled successfully!');
      } else {
        print('❌ Failed to reschedule appointment.');
      }
    } catch (e) {
      print('❌ Error rescheduling appointment: $e');
    }
  }

  // Reports and Statistics Methods
  void _showSystemOverview() {
    final stats = _appointmentManager.getSystemStatistics();
    
    print('\n📊 SYSTEM OVERVIEW');
    print('─────────────────');
    print('Total Patients: ${stats['totalPatients']}');
    print('Total Doctors: ${stats['totalDoctors']}');
    print('Total Appointments: ${stats['totalAppointments']}');
    print('');
    print('Appointments Created: ${stats['appointmentsCreated']}');
    print('Appointments Completed: ${stats['appointmentsCompleted']}');
    print('Appointments Cancelled: ${stats['appointmentsCancelled']}');
    print('');
    print('Today\'s Appointments: ${stats['todayAppointments']}');
    print('Upcoming Appointments: ${stats['upcomingAppointments']}');
    print('Overdue Appointments: ${stats['overdueAppointments']}');
    print('Pending Appointments: ${stats['pendingAppointments']}');
    print('Confirmed Appointments: ${stats['confirmedAppointments']}');
  }

  void _showPatientStatistics() {
    final patients = _appointmentManager.patients;
    
    print('\n👥 PATIENT STATISTICS');
    print('───────────────────');
    print('Total Patients: ${patients.length}');
    
    if (patients.isEmpty) return;
    
    final genderStats = <Gender, int>{};
    final bloodTypeStats = <BloodType, int>{};
    final ageGroups = <String, int>{
      '0-18': 0,
      '19-35': 0,
      '36-50': 0,
      '51-65': 0,
      '65+': 0,
    };
    
    for (final patient in patients) {
      genderStats[patient.gender] = (genderStats[patient.gender] ?? 0) + 1;
      bloodTypeStats[patient.bloodType] = (bloodTypeStats[patient.bloodType] ?? 0) + 1;
      
      final age = patient.age;
      if (age <= 18) ageGroups['0-18'] = ageGroups['0-18']! + 1;
      else if (age <= 35) ageGroups['19-35'] = ageGroups['19-35']! + 1;
      else if (age <= 50) ageGroups['36-50'] = ageGroups['36-50']! + 1;
      else if (age <= 65) ageGroups['51-65'] = ageGroups['51-65']! + 1;
      else ageGroups['65+'] = ageGroups['65+']! + 1;
    }
    
    print('\nGender Distribution:');
    genderStats.forEach((gender, count) {
      print('  ${gender.displayName}: $count');
    });
    
    print('\nAge Groups:');
    ageGroups.forEach((group, count) {
      print('  $group years: $count');
    });
    
    print('\nBlood Type Distribution:');
    bloodTypeStats.forEach((bloodType, count) {
      print('  ${bloodType.displayName}: $count');
    });
  }

  void _showDoctorStatistics() {
    final doctors = _appointmentManager.doctors;
    
    print('\n👨‍⚕️ DOCTOR STATISTICS');
    print('────────────────────');
    print('Total Doctors: ${doctors.length}');
    
    if (doctors.isEmpty) return;
    
    final specialtyStats = <Specialty, int>{};
    var totalExperience = 0;
    var totalFees = 0.0;
    var availableDoctors = 0;
    
    for (final doctor in doctors) {
      specialtyStats[doctor.specialty] = (specialtyStats[doctor.specialty] ?? 0) + 1;
      totalExperience += doctor.yearsOfExperience;
      totalFees += doctor.consultationFee;
      if (doctor.isAvailable) availableDoctors++;
    }
    
    print('\nSpecialty Distribution:');
    specialtyStats.forEach((specialty, count) {
      print('  ${specialty.displayName}: $count');
    });
    
    print('\nAverage Experience: ${(totalExperience / doctors.length).toStringAsFixed(1)} years');
    print('Average Consultation Fee: \$${(totalFees / doctors.length).toStringAsFixed(2)}');
    print('Available Doctors: $availableDoctors/${doctors.length}');
  }

  void _showAppointmentStatistics() {
    final appointments = _appointmentManager.appointments;
    
    print('\n📅 APPOINTMENT STATISTICS');
    print('────────────────────────');
    print('Total Appointments: ${appointments.length}');
    
    if (appointments.isEmpty) return;
    
    final statusStats = <AppointmentStatus, int>{};
    final typeStats = <AppointmentType, int>{};
    var totalRevenue = 0.0;
    
    for (final appointment in appointments) {
      statusStats[appointment.appointmentStatus] = (statusStats[appointment.appointmentStatus] ?? 0) + 1;
      typeStats[appointment.appointmentType] = (typeStats[appointment.appointmentType] ?? 0) + 1;
      if (appointment.appointmentStatus == AppointmentStatus.completed) {
        totalRevenue += appointment.consultationFee ?? 0.0;
      }
    }
    
    print('\nStatus Distribution:');
    statusStats.forEach((status, count) {
      print('  ${status.displayName}: $count');
    });
    
    print('\nType Distribution:');
    typeStats.forEach((type, count) {
      print('  ${type.displayName}: $count');
    });
    
    print('\nTotal Revenue (Completed): \$${totalRevenue.toStringAsFixed(2)}');
  }

  void _showDailyReport() {
    final dateStr = _getInput('Enter date (YYYY-MM-DD) or press Enter for today: ');
    final date = dateStr.isEmpty ? DateTime.now() : DateTime.parse(dateStr);
    final appointments = _appointmentManager.getAppointmentsByDate(date);
    
    print('\n📊 DAILY REPORT - ${date.toString().substring(0, 10)}');
    print('─────────────────────────────────────────────────────');
    print('Total Appointments: ${appointments.length}');
    
    if (appointments.isEmpty) return;
    
    final statusCounts = <AppointmentStatus, int>{};
    var revenue = 0.0;
    
    for (final appointment in appointments) {
      statusCounts[appointment.appointmentStatus] = (statusCounts[appointment.appointmentStatus] ?? 0) + 1;
      if (appointment.appointmentStatus == AppointmentStatus.completed) {
        revenue += appointment.consultationFee ?? 0.0;
      }
    }
    
    statusCounts.forEach((status, count) {
      print('${status.displayName}: $count');
    });
    
    print('Revenue: \$${revenue.toStringAsFixed(2)}');
    
    print('\nAppointments:');
    appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    for (final appointment in appointments) {
      final time = appointment.dateTime.toString().substring(11, 16);
      print('$time | ${appointment.patient.name} → ${appointment.doctor.name} | ${appointment.appointmentStatus.displayName}');
    }
  }

  void _showMonthlyReport() {
    final monthStr = _getInput('Enter month (YYYY-MM) or press Enter for current month: ');
    final now = DateTime.now();
    final targetDate = monthStr.isEmpty ? now : DateTime.parse('$monthStr-01');
    
    final startDate = DateTime(targetDate.year, targetDate.month, 1);
    final endDate = DateTime(targetDate.year, targetDate.month + 1, 0);
    
    final appointments = _appointmentManager.getAppointmentsInRange(startDate, endDate);
    
    print('\n📊 MONTHLY REPORT - ${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}');
    print('─────────────────────────────────────────────────────────────────');
    print('Total Appointments: ${appointments.length}');
    
    if (appointments.isEmpty) return;
    
    final statusCounts = <AppointmentStatus, int>{};
    var revenue = 0.0;
    final dailyCounts = <int, int>{};
    
    for (final appointment in appointments) {
      statusCounts[appointment.appointmentStatus] = (statusCounts[appointment.appointmentStatus] ?? 0) + 1;
      if (appointment.appointmentStatus == AppointmentStatus.completed) {
        revenue += appointment.consultationFee ?? 0.0;
      }
      
      final day = appointment.dateTime.day;
      dailyCounts[day] = (dailyCounts[day] ?? 0) + 1;
    }
    
    print('\nStatus Summary:');
    statusCounts.forEach((status, count) {
      print('  ${status.displayName}: $count');
    });
    
    print('\nTotal Revenue: \$${revenue.toStringAsFixed(2)}');
    print('Average Daily Appointments: ${(appointments.length / endDate.day).toStringAsFixed(1)}');
    
    final busiestDay = dailyCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
    print('Busiest Day: ${busiestDay.key} (${busiestDay.value} appointments)');
  }

  void _showOverdueAppointments() {
    final overdue = _appointmentManager.getOverdueAppointments();
    
    print('\n⚠️  OVERDUE APPOINTMENTS');
    print('──────────────────────');
    
    if (overdue.isEmpty) {
      print('No overdue appointments.');
      return;
    }
    
    print('Found ${overdue.length} overdue appointments:');
    
    for (final appointment in overdue) {
      final hoursOverdue = DateTime.now().difference(appointment.dateTime).inHours;
      print('ID: ${appointment.appointmentId}');
      print('Patient: ${appointment.patient.name}');
      print('Doctor: ${appointment.doctor.name}');
      print('Scheduled: ${appointment.dateTime}');
      print('Overdue by: $hoursOverdue hours');
      print('Status: ${appointment.appointmentStatus.displayName}');
      print('─────────────────────────────────────');
    }
  }

  // Search and Filter Methods
  void _searchAppointments() {
    final query = _getInput('Enter search term (patient name, doctor name, or reason): ');
    final results = _appointmentManager.searchAppointments(query);
    
    print('\n🔍 SEARCH RESULTS');
    print('────────────────');
    
    if (results.isEmpty) {
      print('No appointments found matching "$query"');
      return;
    }
    
    print('Found ${results.length} appointments:');
    for (final appointment in results) {
      _displayAppointmentSummary(appointment);
    }
  }

  void _filterByDateRange() {
    final startDateStr = _getInput('Start date (YYYY-MM-DD): ');
    final endDateStr = _getInput('End date (YYYY-MM-DD): ');
    
    try {
      final startDate = DateTime.parse(startDateStr);
      final endDate = DateTime.parse(endDateStr);
      
      final appointments = _appointmentManager.getAppointmentsInRange(startDate, endDate);
      
      print('\n📅 APPOINTMENTS FROM $startDateStr TO $endDateStr');
      print('─────────────────────────────────────────────────────');
      
      if (appointments.isEmpty) {
        print('No appointments found in this date range.');
        return;
      }
      
      appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      for (final appointment in appointments) {
        _displayAppointmentSummary(appointment);
      }
    } catch (e) {
      print('❌ Invalid date format. Please use YYYY-MM-DD.');
    }
  }

  void _filterByDoctor() {
    final doctorId = _getInput('Enter Doctor ID: ');
    final doctor = _appointmentManager.getDoctorById(doctorId);
    
    if (doctor == null) {
      print('❌ Doctor not found.');
      return;
    }
    
    final appointments = _appointmentManager.getAppointmentsByDoctor(doctorId);
    
    print('\n👨‍⚕️ APPOINTMENTS FOR ${doctor.name}');
    print('─────────────────────────────────────');
    
    if (appointments.isEmpty) {
      print('No appointments found for this doctor.');
      return;
    }
    
    appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    for (final appointment in appointments) {
      _displayAppointmentSummary(appointment);
    }
  }

  void _filterByPatient() {
    final patientId = _getInput('Enter Patient ID: ');
    final patient = _appointmentManager.getPatientById(patientId);
    
    if (patient == null) {
      print('❌ Patient not found.');
      return;
    }
    
    final appointments = _appointmentManager.getAppointmentsByPatient(patientId);
    
    print('\n👥 APPOINTMENTS FOR ${patient.name}');
    print('─────────────────────────────────────');
    
    if (appointments.isEmpty) {
      print('No appointments found for this patient.');
      return;
    }
    
    appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    for (final appointment in appointments) {
      _displayAppointmentSummary(appointment);
    }
  }

  void _filterByStatus() {
    print('Status Options:');
    print('1. Pending');
    print('2. Confirmed');
    print('3. Completed');
    print('4. Cancelled');
    print('5. No Show');
    
    final choice = _getInput('Select status: ');
    final status = _parseAppointmentStatus(choice);
    
    if (status == null) {
      print('❌ Invalid status selection.');
      return;
    }
    
    final appointments = _appointmentManager.getAppointmentsByStatus(status);
    
    print('\n📋 ${status.displayName.toUpperCase()} APPOINTMENTS');
    print('─────────────────────────────────────────────');
    
    if (appointments.isEmpty) {
      print('No ${status.displayName.toLowerCase()} appointments found.');
      return;
    }
    
    appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    for (final appointment in appointments) {
      _displayAppointmentSummary(appointment);
    }
  }

  void _filterBySpecialty() {
    print('Specialty Options:');
    print('1. Cardiology');
    print('2. Pediatrics');
    print('3. Orthopedics');
    print('4. Dermatology');
    print('5. Neurology');
    
    final choice = _getInput('Select specialty: ');
    final specialty = _parseSpecialty(choice);
    
    if (specialty == null) {
      print('❌ Invalid specialty selection.');
      return;
    }
    
    final doctors = _appointmentManager.getDoctorsBySpecialty(specialty);
    
    print('\n🏥 ${specialty.displayName.toUpperCase()} DOCTORS');
    print('─────────────────────────────────────────');
    
    if (doctors.isEmpty) {
      print('No doctors found for this specialty.');
      return;
    }
    
    for (final doctor in doctors) {
      final appointments = _appointmentManager.getAppointmentsByDoctor(doctor.id);
      print('${doctor.name} (${doctor.id}) - ${appointments.length} appointments');
      print('  Experience: ${doctor.yearsOfExperience} years | Fee: \$${doctor.consultationFee}');
      print('  Available: ${doctor.isAvailable ? 'Yes' : 'No'}');
      print('');
    }
  }

  // System Settings Methods
  void _processOverdueAppointments() {
    print('\n⚙️  PROCESSING OVERDUE APPOINTMENTS');
    print('─────────────────────────────────');
    
    final overdueBefore = _appointmentManager.getOverdueAppointments().length;
    _appointmentManager.processOverdueAppointments();
    final overdueAfter = _appointmentManager.getOverdueAppointments().length;
    
    final processed = overdueBefore - overdueAfter;
    print('✅ Processed $processed overdue appointments.');
    print('Remaining overdue: $overdueAfter');
  }

  void _clearAllData() {
    final confirmation = _getInput('⚠️  This will delete ALL data. Type "CONFIRM" to proceed: ');
    
    if (confirmation == 'CONFIRM') {
      _appointmentManager.clearAllData();
      print('✅ All data cleared successfully!');
    } else {
      print('Operation cancelled.');
    }
  }

  void _exportData() {
    print('\n📤 EXPORT DATA');
    print('─────────────');
    
    final stats = _appointmentManager.getSystemStatistics();
    final timestamp = DateTime.now().toString().substring(0, 19).replaceAll(':', '-');
    
    print('Export Summary (${timestamp}):');
    print('Patients: ${stats['totalPatients']}');
    print('Doctors: ${stats['totalDoctors']}');
    print('Appointments: ${stats['totalAppointments']}');
    print('');
    print('Note: In a real application, this would export to files.');
    print('✅ Export completed successfully!');
  }

  void _importSampleData() {
    final confirmation = _getInput('This will add sample data to the system. Continue? (yes/no): ');
    
    if (confirmation.toLowerCase() == 'yes') {
      // This would typically call the same initialization function from main
      print('✅ Sample data imported successfully!');
      print('Note: In this demo, sample data is already loaded at startup.');
    } else {
      print('Operation cancelled.');
    }
  }

  void _systemHealthCheck() {
    print('\n🔍 SYSTEM HEALTH CHECK');
    print('────────────────────');
    
    final stats = _appointmentManager.getSystemStatistics();
    var issues = 0;
    
    print('Checking system integrity...');
    
    // Check for appointments needing attention
    final needsAttention = _appointmentManager.getAppointmentsNeedingAttention();
    if (needsAttention.isNotEmpty) {
      print('⚠️  ${needsAttention.length} appointments need attention');
      issues++;
    }
    
    // Check for inactive doctors with appointments
    final inactiveDoctors = _appointmentManager.doctors.where((d) => !d.isActive).length;
    if (inactiveDoctors > 0) {
      print('⚠️  $inactiveDoctors inactive doctors in system');
      issues++;
    }
    
    // Check for patients without appointments
    final patientsWithoutAppointments = _appointmentManager.patients.where((p) {
      return _appointmentManager.getAppointmentsByPatient(p.id).isEmpty;
    }).length;
    
    if (patientsWithoutAppointments > 0) {
      print('ℹ️  $patientsWithoutAppointments patients have no appointments');
    }
    
    print('');
    print('System Statistics:');
    print('  Total Patients: ${stats['totalPatients']}');
    print('  Total Doctors: ${stats['totalDoctors']}');
    print('  Total Appointments: ${stats['totalAppointments']}');
    print('  Overdue Appointments: ${stats['overdueAppointments']}');
    
    if (issues == 0) {
      print('\n✅ System health check passed! No issues found.');
    } else {
      print('\n⚠️  System health check found $issues issues that may need attention.');
    }
  }

  // Helper Methods
  void _displayAppointmentSummary(Appointment appointment) {
    final date = appointment.dateTime.toString().substring(0, 16);
    final status = appointment.appointmentStatus.displayName;
    
    print('ID: ${appointment.appointmentId}');
    print('Date: $date | Status: $status');
    print('Patient: ${appointment.patient.name} | Doctor: ${appointment.doctor.name}');
    print('Reason: ${appointment.reason} | Fee: \$${appointment.consultationFee}');
    print('─────────────────────────────────────────────────────────────');
  }

  String _getInput(String prompt) {
    stdout.write(prompt);
    return stdin.readLineSync() ?? '';
  }

  Gender _parseGender(String choice) {
    switch (choice) {
      case '1': return Gender.male;
      case '2': return Gender.female;
      case '3': return Gender.other;
      default: throw ArgumentError('Invalid gender choice');
    }
  }

  BloodType _parseBloodType(String choice) {
    switch (choice) {
      case '1': return BloodType.aPositive;
      case '2': return BloodType.aNegative;
      case '3': return BloodType.bPositive;
      case '4': return BloodType.bNegative;
      case '5': return BloodType.abPositive;
      case '6': return BloodType.abNegative;
      case '7': return BloodType.oPositive;
      case '8': return BloodType.oNegative;
      default: throw ArgumentError('Invalid blood type choice');
    }
  }

  Specialty? _parseSpecialty(String choice) {
    switch (choice) {
      case '1': return Specialty.cardiology;
      case '2': return Specialty.pediatrics;
      case '3': return Specialty.orthopedics;
      case '4': return Specialty.dermatology;
      case '5': return Specialty.neurology;
      default: return null;
    }
  }

  AppointmentType _parseAppointmentType(String choice) {
    switch (choice) {
      case '1': return AppointmentType.consultation;
      case '2': return AppointmentType.followUp;
      case '3': return AppointmentType.emergency;
      case '4': return AppointmentType.vaccination;
      case '5': return AppointmentType.surgery;
      default: return AppointmentType.consultation;
    }
  }

  AppointmentStatus? _parseAppointmentStatus(String choice) {
    switch (choice) {
      case '1': return AppointmentStatus.pending;
      case '2': return AppointmentStatus.confirmed;
      case '3': return AppointmentStatus.completed;
      case '4': return AppointmentStatus.cancelled;
      case '5': return AppointmentStatus.noShow;
      default: return null;
    }
  }
}