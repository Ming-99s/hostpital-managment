import 'dart:io';
import '../../domain/services/appointmentManager.dart';
import '../../domain/models/appointment.dart';
import '../../domain/models/doctor.dart';
import '../../domain/models/patient.dart';

/// Console-based user interface for patients in the Hospital Management System
/// 
/// This class provides a text-based interface for patients to interact with the hospital
/// management system, including viewing appointments, booking new appointments, and
/// managing their profile information.
class PatientConsole {
  final AppointmentManager _appointmentManager;
  final Patient _currentPatient;
  bool _isRunning = true;

  PatientConsole(this._appointmentManager, this._currentPatient);

  /// Starts the patient console interface
  void start() {
    print('🏥 Welcome to Hospital Management System');
    print('👋 Hello, ${_currentPatient.name}!\n');
    
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

  /// Displays the main menu for patients
  void _showMainMenu() {
    print('═══════════════════════════════════════');
    print('🏥 PATIENT PORTAL - ${_currentPatient.name}');
    print('═══════════════════════════════════════');
    print('1. 📅 My Appointments');
    print('2. 🆕 Book New Appointment');
    print('3. 👨‍⚕️ Find Doctors');
    print('4. 👤 My Profile');
    print('5. 📋 My Medical History');
    print('6. 🔔 Appointment Reminders');
    print('7. ⚙️  Settings');
    print('0. 🚪 Logout');
    print('═══════════════════════════════════════');
  }

  /// Handles main menu choices
  void _handleMainMenuChoice(String choice) {
    switch (choice) {
      case '1':
        _showMyAppointments();
        break;
      case '2':
        _bookNewAppointment();
        break;
      case '3':
        _findDoctors();
        break;
      case '4':
        _showMyProfile();
        break;
      case '5':
        _showMedicalHistory();
        break;
      case '6':
        _showAppointmentReminders();
        break;
      case '7':
        _showSettings();
        break;
      case '0':
        _isRunning = false;
        break;
      default:
        print('❌ Invalid choice. Please try again.\n');
    }
  }

  /// Shows patient's appointments
  void _showMyAppointments() {
    while (true) {
      print('\n📅 MY APPOINTMENTS');
      print('─────────────────');
      print('1. View All Appointments');
      print('2. View Upcoming Appointments');
      print('3. View Past Appointments');
      print('4. Cancel Appointment');
      print('5. Reschedule Appointment');
      print('0. Back to Main Menu');
      print('─────────────────');

      final choice = _getInput('Enter your choice: ');
      
      switch (choice) {
        case '1':
          _viewAllMyAppointments();
          break;
        case '2':
          _viewUpcomingAppointments();
          break;
        case '3':
          _viewPastAppointments();
          break;
        case '4':
          _cancelMyAppointment();
          break;
        case '5':
          _rescheduleMyAppointment();
          break;
        case '0':
          return;
        default:
          print('❌ Invalid choice. Please try again.');
      }
    }
  }

  /// Views all patient's appointments
  void _viewAllMyAppointments() {
    print('\n📅 ALL MY APPOINTMENTS');
    print('─────────────────────');
    
    final appointments = _appointmentManager.getAppointmentsByPatient(_currentPatient.id);
    if (appointments.isEmpty) {
      print('No appointments found.');
      return;
    }
    
    appointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    
    for (final appointment in appointments) {
      _displayAppointmentDetails(appointment);
    }
  }

  /// Views upcoming appointments
  void _viewUpcomingAppointments() {
    print('\n📅 UPCOMING APPOINTMENTS');
    print('──────────────────────');
    
    final allAppointments = _appointmentManager.getAppointmentsByPatient(_currentPatient.id);
    final upcomingAppointments = allAppointments.where((a) => a.isUpcoming).toList();
    
    if (upcomingAppointments.isEmpty) {
      print('No upcoming appointments.');
      return;
    }
    
    upcomingAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    for (final appointment in upcomingAppointments) {
      _displayAppointmentDetails(appointment);
      final timeUntil = appointment.timeUntilAppointment;
      if (timeUntil != null) {
        final days = timeUntil.inDays;
        final hours = timeUntil.inHours % 24;
        print('⏰ Time until appointment: ${days}d ${hours}h');
      }
      print('');
    }
  }

  /// Views past appointments
  void _viewPastAppointments() {
    print('\n📅 PAST APPOINTMENTS');
    print('──────────────────');
    
    final allAppointments = _appointmentManager.getAppointmentsByPatient(_currentPatient.id);
    final pastAppointments = allAppointments.where((a) => 
        a.dateTime.isBefore(DateTime.now()) && 
        (a.appointmentStatus == AppointmentStatus.completed || 
         a.appointmentStatus == AppointmentStatus.cancelled ||
         a.appointmentStatus == AppointmentStatus.noShow)).toList();
    
    if (pastAppointments.isEmpty) {
      print('No past appointments.');
      return;
    }
    
    pastAppointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    
    for (final appointment in pastAppointments.take(10)) {
      _displayAppointmentDetails(appointment);
    }
    
    if (pastAppointments.length > 10) {
      print('... and ${pastAppointments.length - 10} more appointments');
    }
  }

  /// Cancels patient's appointment
  void _cancelMyAppointment() {
    print('\n❌ CANCEL APPOINTMENT');
    print('────────────────────');
    
    final upcomingAppointments = _appointmentManager.getAppointmentsByPatient(_currentPatient.id)
        .where((a) => a.isUpcoming).toList();
    
    if (upcomingAppointments.isEmpty) {
      print('No upcoming appointments to cancel.');
      return;
    }
    
    print('Your upcoming appointments:');
    for (int i = 0; i < upcomingAppointments.length; i++) {
      final appointment = upcomingAppointments[i];
      print('${i + 1}. ${appointment.dateTime.toString().substring(0, 16)} - ${appointment.doctor.name}');
      print('   Reason: ${appointment.reason}');
    }
    
    final choice = _getInput('Select appointment to cancel (1-${upcomingAppointments.length}): ');
    final index = int.tryParse(choice);
    
    if (index == null || index < 1 || index > upcomingAppointments.length) {
      print('❌ Invalid selection.');
      return;
    }
    
    final appointment = upcomingAppointments[index - 1];
    final reason = _getInput('Reason for cancellation: ');
    final confirmation = _getInput('Are you sure you want to cancel this appointment? (yes/no): ');
    
    if (confirmation.toLowerCase() == 'yes') {
      if (_appointmentManager.cancelAppointment(appointment.appointmentId, reason)) {
        print('✅ Appointment cancelled successfully!');
        print('The doctor\'s slot has been made available for other patients.');
      } else {
        print('❌ Failed to cancel appointment.');
      }
    } else {
      print('Cancellation aborted.');
    }
  }

  /// Reschedules patient's appointment
  void _rescheduleMyAppointment() {
    print('\n🔄 RESCHEDULE APPOINTMENT');
    print('────────────────────────');
    
    final upcomingAppointments = _appointmentManager.getAppointmentsByPatient(_currentPatient.id)
        .where((a) => a.isUpcoming).toList();
    
    if (upcomingAppointments.isEmpty) {
      print('No upcoming appointments to reschedule.');
      return;
    }
    
    print('Your upcoming appointments:');
    for (int i = 0; i < upcomingAppointments.length; i++) {
      final appointment = upcomingAppointments[i];
      print('${i + 1}. ${appointment.dateTime.toString().substring(0, 16)} - ${appointment.doctor.name}');
      print('   Reason: ${appointment.reason}');
    }
    
    final choice = _getInput('Select appointment to reschedule (1-${upcomingAppointments.length}): ');
    final index = int.tryParse(choice);
    
    if (index == null || index < 1 || index > upcomingAppointments.length) {
      print('❌ Invalid selection.');
      return;
    }
    
    final appointment = upcomingAppointments[index - 1];
    print('Current appointment: ${appointment.dateTime.toString().substring(0, 16)}');
    print('Doctor: ${appointment.doctor.name}');
    
    // Show available slots for the same doctor
    final dateStr = _getInput('Enter new date (YYYY-MM-DD): ');
    try {
      final newDate = DateTime.parse(dateStr);
      final availableSlots = appointment.doctor.getAvailableSlotsForDate(newDate);
      
      if (availableSlots.isEmpty) {
        print('❌ No available slots for ${appointment.doctor.name} on $dateStr');
        return;
      }
      
      print('Available slots:');
      for (int i = 0; i < availableSlots.length; i++) {
        print('${i + 1}. ${availableSlots[i].toString().substring(11, 16)}');
      }
      
      final slotChoice = _getInput('Select new time slot (1-${availableSlots.length}): ');
      final slotIndex = int.tryParse(slotChoice);
      
      if (slotIndex == null || slotIndex < 1 || slotIndex > availableSlots.length) {
        print('❌ Invalid slot selection.');
        return;
      }
      
      final newDateTime = availableSlots[slotIndex - 1];
      final confirmation = _getInput('Reschedule to ${newDateTime.toString().substring(0, 16)}? (yes/no): ');
      
      if (confirmation.toLowerCase() == 'yes') {
        if (_appointmentManager.rescheduleAppointment(appointment.appointmentId, newDateTime)) {
          print('✅ Appointment rescheduled successfully!');
          print('New appointment time: ${newDateTime.toString().substring(0, 16)}');
        } else {
          print('❌ Failed to reschedule appointment.');
        }
      } else {
        print('Rescheduling cancelled.');
      }
    } catch (e) {
      print('❌ Invalid date format. Please use YYYY-MM-DD.');
    }
  }

  /// Books a new appointment
  void _bookNewAppointment() {
    print('\n🆕 BOOK NEW APPOINTMENT');
    print('─────────────────────');
    
    // Show available specialties
    final doctors = _appointmentManager.doctors.where((d) => d.isAvailable && d.isActive).toList();
    if (doctors.isEmpty) {
      print('❌ No doctors are currently available.');
      return;
    }
    
    final specialties = doctors.map((d) => d.specialty).toSet().toList();
    
    print('Available specialties:');
    for (int i = 0; i < specialties.length; i++) {
      print('${i + 1}. ${specialties[i].displayName}');
    }
    
    final specialtyChoice = _getInput('Select specialty (1-${specialties.length}): ');
    final specialtyIndex = int.tryParse(specialtyChoice);
    
    if (specialtyIndex == null || specialtyIndex < 1 || specialtyIndex > specialties.length) {
      print('❌ Invalid specialty selection.');
      return;
    }
    
    final selectedSpecialty = specialties[specialtyIndex - 1];
    final availableDoctors = _appointmentManager.getDoctorsBySpecialty(selectedSpecialty);
    
    if (availableDoctors.isEmpty) {
      print('❌ No doctors available for ${selectedSpecialty.displayName}.');
      return;
    }
    
    print('\nAvailable doctors:');
    for (int i = 0; i < availableDoctors.length; i++) {
      final doctor = availableDoctors[i];
      print('${i + 1}. ${doctor.name}');
      print('   Experience: ${doctor.yearsOfExperience} years');
      print('   Fee: \$${doctor.consultationFee}');
      print('   Next available: ${doctor.getNextAvailableSlot()?.toString().substring(0, 16) ?? 'No slots'}');
      print('');
    }
    
    final doctorChoice = _getInput('Select doctor (1-${availableDoctors.length}): ');
    final doctorIndex = int.tryParse(doctorChoice);
    
    if (doctorIndex == null || doctorIndex < 1 || doctorIndex > availableDoctors.length) {
      print('❌ Invalid doctor selection.');
      return;
    }
    
    final selectedDoctor = availableDoctors[doctorIndex - 1];
    
    // Show available dates
    final dateStr = _getInput('Enter preferred date (YYYY-MM-DD): ');
    try {
      final preferredDate = DateTime.parse(dateStr);
      final availableSlots = selectedDoctor.getAvailableSlotsForDate(preferredDate);
      
      if (availableSlots.isEmpty) {
        print('❌ No available slots for ${selectedDoctor.name} on $dateStr');
        
        // Show next available slots
        final nextSlot = selectedDoctor.getNextAvailableSlot();
        if (nextSlot != null) {
          print('Next available slot: ${nextSlot.toString().substring(0, 16)}');
        }
        return;
      }
      
      print('Available time slots:');
      for (int i = 0; i < availableSlots.length; i++) {
        print('${i + 1}. ${availableSlots[i].toString().substring(11, 16)}');
      }
      
      final slotChoice = _getInput('Select time slot (1-${availableSlots.length}): ');
      final slotIndex = int.tryParse(slotChoice);
      
      if (slotIndex == null || slotIndex < 1 || slotIndex > availableSlots.length) {
        print('❌ Invalid slot selection.');
        return;
      }
      
      final selectedDateTime = availableSlots[slotIndex - 1];
      final reason = _getInput('Reason for appointment: ');
      
      print('\nAppointment Type:');
      print('1. Consultation');
      print('2. Follow-up');
      print('3. Check-up');
      print('4. Emergency');
      print('5. Vaccination');
      
      final typeChoice = _getInput('Select appointment type (1-5): ');
      final appointmentType = _parseAppointmentType(typeChoice);
      
      final durationStr = _getInput('Duration in minutes (default 30): ');
      final duration = durationStr.isEmpty ? 30 : int.tryParse(durationStr) ?? 30;
      
      // Confirmation
      print('\n📋 APPOINTMENT SUMMARY');
      print('─────────────────────');
      print('Patient: ${_currentPatient.name}');
      print('Doctor: ${selectedDoctor.name}');
      print('Specialty: ${selectedDoctor.specialty.displayName}');
      print('Date & Time: ${selectedDateTime.toString().substring(0, 16)}');
      print('Duration: $duration minutes');
      print('Reason: $reason');
      print('Type: ${appointmentType.displayName}');
      print('Fee: \$${selectedDoctor.consultationFee}');
      
      final confirmation = _getInput('\nConfirm booking? (yes/no): ');
      
      if (confirmation.toLowerCase() == 'yes') {
        try {
          final appointment = _appointmentManager.createAppointment(
            patientId: _currentPatient.id,
            doctorId: selectedDoctor.id,
            dateTime: selectedDateTime,
            reason: reason,
            appointmentType: appointmentType,
            durationMinutes: duration,
          );
          
          print('✅ Appointment booked successfully!');
          print('Appointment ID: ${appointment.appointmentId}');
          print('Please arrive 15 minutes before your appointment time.');
          
        } catch (e) {
          print('❌ Failed to book appointment: $e');
        }
      } else {
        print('Booking cancelled.');
      }
      
    } catch (e) {
      print('❌ Invalid date format. Please use YYYY-MM-DD.');
    }
  }

  /// Shows available doctors and their information
  void _findDoctors() {
    while (true) {
      print('\n👨‍⚕️ FIND DOCTORS');
      print('─────────────────');
      print('1. View All Doctors');
      print('2. Search by Specialty');
      print('3. Search by Name');
      print('4. View Doctor Details');
      print('0. Back to Main Menu');
      print('─────────────────');

      final choice = _getInput('Enter your choice: ');
      
      switch (choice) {
        case '1':
          _viewAllDoctors();
          break;
        case '2':
          _searchDoctorsBySpecialty();
          break;
        case '3':
          _searchDoctorsByName();
          break;
        case '4':
          _viewDoctorDetails();
          break;
        case '0':
          return;
        default:
          print('❌ Invalid choice. Please try again.');
      }
    }
  }

  /// Views all available doctors
  void _viewAllDoctors() {
    print('\n👨‍⚕️ ALL AVAILABLE DOCTORS');
    print('─────────────────────────');
    
    final doctors = _appointmentManager.doctors.where((d) => d.isAvailable && d.isActive).toList();
    if (doctors.isEmpty) {
      print('No doctors are currently available.');
      return;
    }
    
    doctors.sort((a, b) => a.name.compareTo(b.name));
    
    for (final doctor in doctors) {
      _displayDoctorSummary(doctor);
    }
  }

  /// Searches doctors by specialty
  void _searchDoctorsBySpecialty() {
    final doctors = _appointmentManager.doctors.where((d) => d.isAvailable && d.isActive).toList();
    final specialties = doctors.map((d) => d.specialty).toSet().toList();
    
    print('\nAvailable specialties:');
    for (int i = 0; i < specialties.length; i++) {
      print('${i + 1}. ${specialties[i].displayName}');
    }
    
    final choice = _getInput('Select specialty (1-${specialties.length}): ');
    final index = int.tryParse(choice);
    
    if (index == null || index < 1 || index > specialties.length) {
      print('❌ Invalid selection.');
      return;
    }
    
    final selectedSpecialty = specialties[index - 1];
    final specialtyDoctors = _appointmentManager.getDoctorsBySpecialty(selectedSpecialty);
    
    print('\n👨‍⚕️ ${selectedSpecialty.displayName.toUpperCase()} DOCTORS');
    print('─────────────────────────────────────');
    
    if (specialtyDoctors.isEmpty) {
      print('No doctors available for this specialty.');
      return;
    }
    
    for (final doctor in specialtyDoctors) {
      _displayDoctorSummary(doctor);
    }
  }

  /// Searches doctors by name
  void _searchDoctorsByName() {
    final query = _getInput('Enter doctor name to search: ');
    final doctors = _appointmentManager.doctors.where((d) =>
        d.name.toLowerCase().contains(query.toLowerCase()) &&
        d.isAvailable && d.isActive).toList();
    
    if (doctors.isEmpty) {
      print('No doctors found matching "$query"');
      return;
    }
    
    print('\n🔍 SEARCH RESULTS');
    print('────────────────');
    for (final doctor in doctors) {
      _displayDoctorSummary(doctor);
    }
  }

  /// Views detailed information about a specific doctor
  void _viewDoctorDetails() {
    final doctorId = _getInput('Enter Doctor ID: ');
    final doctor = _appointmentManager.getDoctorById(doctorId);
    
    if (doctor == null) {
      print('❌ Doctor not found.');
      return;
    }
    
    print('\n👨‍⚕️ DOCTOR DETAILS');
    print('──────────────────');
    print('Name: ${doctor.name}');
    print('ID: ${doctor.id}');
    print('Specialty: ${doctor.specialty.displayName}');
    print('License Number: ${doctor.licenseNumber}');
    print('Experience: ${doctor.yearsOfExperience} years');
    print('Consultation Fee: \$${doctor.consultationFee}');
    print('Email: ${doctor.email}');
    print('Phone: ${doctor.phoneNumber}');
    print('Available: ${doctor.isAvailable ? 'Yes' : 'No'}');
    
    if (doctor.qualifications.isNotEmpty) {
      print('Qualifications:');
      for (final qualification in doctor.qualifications) {
        print('  • $qualification');
      }
    }
    
    // Show next few available slots
    final now = DateTime.now();
    final futureSlots = doctor.availableSlots.where((slot) => slot.isAfter(now)).take(5).toList();
    
    if (futureSlots.isNotEmpty) {
      print('\nNext available slots:');
      for (final slot in futureSlots) {
        print('  • ${slot.toString().substring(0, 16)}');
      }
    } else {
      print('\nNo upcoming available slots.');
    }
  }

  /// Shows patient's profile information
  void _showMyProfile() {
    print('\n👤 MY PROFILE');
    print('────────────');
    print('Name: ${_currentPatient.name}');
    print('ID: ${_currentPatient.id}');
    print('Email: ${_currentPatient.email}');
    print('Phone: ${_currentPatient.phoneNumber}');
    print('Date of Birth: ${_currentPatient.dateOfBirth.toString().substring(0, 10)}');
    print('Age: ${_currentPatient.age} years');
    print('Gender: ${_currentPatient.gender.displayName}');
    print('Blood Type: ${_currentPatient.bloodType.displayName}');
    print('Height: ${_currentPatient.height} cm');
    print('Weight: ${_currentPatient.weight} kg');
    print('BMI: ${_currentPatient.bmi.toStringAsFixed(1)} (${_currentPatient.bmiCategory})');
    print('Address: ${_currentPatient.address}');
    print('Insurance: ${_currentPatient.insuranceProvider} (${_currentPatient.insuranceNumber})');
    print('Last Visit: ${_currentPatient.lastVisit?.toString().substring(0, 10) ?? 'Never'}');
    
    print('\nEmergency Contact:');
    print('  Name: ${_currentPatient.emergencyContact.name}');
    print('  Relationship: ${_currentPatient.emergencyContact.relationship}');
    print('  Phone: ${_currentPatient.emergencyContact.phoneNumber}');
    print('  Email: ${_currentPatient.emergencyContact.email}');
    
    if (_currentPatient.allergies.isNotEmpty) {
      print('\nAllergies:');
      for (final allergy in _currentPatient.allergies) {
        print('  • $allergy');
      }
    }
    
    if (_currentPatient.chronicConditions.isNotEmpty) {
      print('\nChronic Conditions:');
      for (final condition in _currentPatient.chronicConditions) {
        print('  • $condition');
      }
    }
  }

  /// Shows patient's medical history
  void _showMedicalHistory() {
    print('\n📋 MY MEDICAL HISTORY');
    print('────────────────────');
    
    if (_currentPatient.medicalHistory.isEmpty) {
      print('No medical records found.');
      return;
    }
    
    print('Total Records: ${_currentPatient.medicalHistory.length}');
    print('');
    
    for (final record in _currentPatient.medicalHistory.take(10)) {
      print('Date: ${record.date.toString().substring(0, 10)}');
      print('Diagnosis: ${record.diagnosis}');
      print('Treatment: ${record.treatment}');
      if (record.notes.isNotEmpty) {
        print('Notes: ${record.notes}');
      }
      if (record.medications.isNotEmpty) {
        print('Medications: ${record.medications.join(', ')}');
      }
      print('─────────────────────────────────────');
    }
    
    if (_currentPatient.medicalHistory.length > 10) {
      print('... and ${_currentPatient.medicalHistory.length - 10} more records');
    }
  }

  /// Shows appointment reminders
  void _showAppointmentReminders() {
    print('\n🔔 APPOINTMENT REMINDERS');
    print('──────────────────────');
    
    final upcomingAppointments = _appointmentManager.getAppointmentsByPatient(_currentPatient.id)
        .where((a) => a.isUpcoming).toList();
    
    if (upcomingAppointments.isEmpty) {
      print('No upcoming appointments.');
      return;
    }
    
    upcomingAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    final now = DateTime.now();
    
    for (final appointment in upcomingAppointments) {
      final timeUntil = appointment.dateTime.difference(now);
      final hours = timeUntil.inHours;
      
      String urgency = '';
      if (hours <= 2) {
        urgency = '🚨 URGENT - ';
      } else if (hours <= 24) {
        urgency = '⚠️  SOON - ';
      }
      
      print('${urgency}${appointment.dateTime.toString().substring(0, 16)}');
      print('Doctor: ${appointment.doctor.name}');
      print('Reason: ${appointment.reason}');
      print('Time until: ${timeUntil.inDays}d ${timeUntil.inHours % 24}h ${timeUntil.inMinutes % 60}m');
      print('Status: ${appointment.appointmentStatus.displayName}');
      print('─────────────────────────────────────');
    }
  }

  /// Shows settings menu
  void _showSettings() {
    while (true) {
      print('\n⚙️  SETTINGS');
      print('───────────');
      print('1. Change Password');
      print('2. Update Contact Information');
      print('3. Notification Preferences');
      print('4. Privacy Settings');
      print('5. Help & Support');
      print('0. Back to Main Menu');
      print('───────────');

      final choice = _getInput('Enter your choice: ');
      
      switch (choice) {
        case '1':
          _changePassword();
          break;
        case '2':
          _updateContactInfo();
          break;
        case '3':
          _notificationPreferences();
          break;
        case '4':
          _privacySettings();
          break;
        case '5':
          _helpSupport();
          break;
        case '0':
          return;
        default:
          print('❌ Invalid choice. Please try again.');
      }
    }
  }

  /// Changes patient password
  void _changePassword() {
    print('\n🔒 CHANGE PASSWORD');
    print('─────────────────');
    
    final currentPassword = _getInput('Enter current password: ');
    if (currentPassword != _currentPatient.password) {
      print('❌ Incorrect current password.');
      return;
    }
    
    final newPassword = _getInput('Enter new password: ');
    final confirmPassword = _getInput('Confirm new password: ');
    
    if (newPassword != confirmPassword) {
      print('❌ Passwords do not match.');
      return;
    }
    
    if (newPassword.length < 6) {
      print('❌ Password must be at least 6 characters long.');
      return;
    }
    
    // In a real application, you would update the password in the database
    print('✅ Password changed successfully!');
    print('Please remember your new password.');
  }

  /// Updates contact information
  void _updateContactInfo() {
    print('\n📞 UPDATE CONTACT INFORMATION');
    print('────────────────────────────');
    print('Current phone: ${_currentPatient.phoneNumber}');
    print('Current email: ${_currentPatient.email}');
    print('Current address: ${_currentPatient.address}');
    print('');
    print('Note: Contact information updates require admin approval.');
    print('Please contact the hospital administration to update your information.');
  }

  /// Shows notification preferences
  void _notificationPreferences() {
    print('\n🔔 NOTIFICATION PREFERENCES');
    print('──────────────────────────');
    print('1. Email notifications: Enabled');
    print('2. SMS notifications: Enabled');
    print('3. Appointment reminders: 24 hours before');
    print('4. Medical report notifications: Enabled');
    print('');
    print('Note: Notification preferences can be updated through the admin portal.');
  }

  /// Shows privacy settings
  void _privacySettings() {
    print('\n🔒 PRIVACY SETTINGS');
    print('──────────────────');
    print('1. Medical history sharing: Doctors only');
    print('2. Contact information visibility: Private');
    print('3. Appointment history: Private');
    print('4. Emergency contact access: Authorized personnel only');
    print('');
    print('Your privacy is important to us. All medical information is kept confidential.');
  }

  /// Shows help and support information
  void _helpSupport() {
    print('\n❓ HELP & SUPPORT');
    print('────────────────');
    print('Hospital Contact Information:');
    print('📞 Phone: +1-555-0123');
    print('📧 Email: support@hospital.com');
    print('🏥 Address: 123 Medical Center Drive');
    print('');
    print('Emergency: Call 911');
    print('Non-emergency medical advice: Call +1-555-0124');
    print('');
    print('Frequently Asked Questions:');
    print('• How to cancel an appointment? Use option 1 → 4 from main menu');
    print('• How to reschedule? Use option 1 → 5 from main menu');
    print('• How to find a doctor? Use option 3 from main menu');
    print('• Forgot password? Contact hospital administration');
  }

  // Helper Methods

  /// Displays appointment details
  void _displayAppointmentDetails(Appointment appointment) {
    final date = appointment.dateTime.toString().substring(0, 16);
    final status = appointment.appointmentStatus.displayName;
    
    print('ID: ${appointment.appointmentId}');
    print('Date: $date | Status: $status');
    print('Doctor: ${appointment.doctor.name} (${appointment.doctor.specialty.displayName})');
    print('Reason: ${appointment.reason}');
    print('Duration: ${appointment.durationMinutes} min | Fee: \$${appointment.consultationFee}');
    if (appointment.notes.isNotEmpty) {
      print('Notes: ${appointment.notes}');
    }
    print('─────────────────────────────────────────────────────────────');
  }

  /// Displays doctor summary
  void _displayDoctorSummary(Doctor doctor) {
    print('ID: ${doctor.id} | Name: ${doctor.name}');
    print('Specialty: ${doctor.specialty.displayName} | Experience: ${doctor.yearsOfExperience} years');
    print('Fee: \$${doctor.consultationFee} | Available: ${doctor.isAvailable ? 'Yes' : 'No'}');
    final nextSlot = doctor.getNextAvailableSlot();
    print('Next available: ${nextSlot?.toString().substring(0, 16) ?? 'No slots available'}');
    print('─────────────────────────────────────────────────────────────');
  }

  /// Gets user input
  String _getInput(String prompt) {
    stdout.write(prompt);
    return stdin.readLineSync() ?? '';
  }

  /// Parses appointment type from user choice
  AppointmentType _parseAppointmentType(String choice) {
    switch (choice) {
      case '1': return AppointmentType.consultation;
      case '2': return AppointmentType.followUp;
      case '3': return AppointmentType.checkup;
      case '4': return AppointmentType.emergency;
      case '5': return AppointmentType.vaccination;
      default: return AppointmentType.consultation;
    }
  }
}