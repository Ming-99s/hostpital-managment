import 'dart:io';
import '../../domain/services/appointmentManager.dart';
import '../../domain/models/appointment.dart';
import '../../domain/models/doctor.dart';
import '../../domain/models/patient.dart';

/// Console-based user interface for doctors in the Hospital Management System
/// 
/// This class provides a text-based interface for doctors to interact with the hospital
/// management system, including viewing their appointments, managing their schedule,
/// and accessing patient information for their appointments.
class DoctorConsole {
  final AppointmentManager _appointmentManager;
  final Doctor _currentDoctor;
  bool _isRunning = true;

  DoctorConsole(this._appointmentManager, this._currentDoctor);

  /// Starts the doctor console interface
  void start() {
    print('🏥 Welcome to Hospital Management System - Doctor Portal');
    print('👨‍⚕️ Hello, ${_currentDoctor.name}!');
    print('🩺 Specialty: ${_currentDoctor.specialty.displayName}');
    print('📋 License: ${_currentDoctor.licenseNumber}\n');
    
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

  /// Displays the main menu for doctors
  void _showMainMenu() {
    print('═══════════════════════════════════════');
    print('🩺 DOCTOR PORTAL - ${_currentDoctor.name}');
    print('═══════════════════════════════════════');
    print('1. 📅 My Schedule');
    print('2. 👥 My Patients');
    print('3. 🆕 Today\'s Appointments');
    print('4. 📋 Appointment History');
    print('5. ⏰ Manage Availability');
    print('6. 📊 My Statistics');
    print('7. 👤 My Profile');
    print('8. ⚙️  Settings');
    print('0. 🚪 Logout');
    print('═══════════════════════════════════════');
  }

  /// Handles main menu choices
  void _handleMainMenuChoice(String choice) {
    switch (choice) {
      case '1':
        _showMySchedule();
        break;
      case '2':
        _showMyPatients();
        break;
      case '3':
        _showTodaysAppointments();
        break;
      case '4':
        _showAppointmentHistory();
        break;
      case '5':
        _manageAvailability();
        break;
      case '6':
        _showMyStatistics();
        break;
      case '7':
        _showMyProfile();
        break;
      case '8':
        _showSettings();
        break;
      case '0':
        _isRunning = false;
        break;
      default:
        print('❌ Invalid choice. Please try again.\n');
    }
  }

  /// Shows doctor's schedule
  void _showMySchedule() {
    while (true) {
      print('\n📅 MY SCHEDULE');
      print('─────────────');
      print('1. View This Week\'s Schedule');
      print('2. View Next Week\'s Schedule');
      print('3. View Specific Date');
      print('4. View All Upcoming Appointments');
      print('5. Update Appointment Status');
      print('6. Add Notes to Appointment');
      print('0. Back to Main Menu');
      print('─────────────');

      final choice = _getInput('Enter your choice: ');
      
      switch (choice) {
        case '1':
          _viewWeeklySchedule(0);
          break;
        case '2':
          _viewWeeklySchedule(1);
          break;
        case '3':
          _viewSpecificDateSchedule();
          break;
        case '4':
          _viewUpcomingAppointments();
          break;
        case '5':
          _updateAppointmentStatus();
          break;
        case '6':
          _addAppointmentNotes();
          break;
        case '0':
          return;
        default:
          print('❌ Invalid choice. Please try again.');
      }
    }
  }

  /// Views weekly schedule
  void _viewWeeklySchedule(int weeksFromNow) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)).add(Duration(days: 7 * weeksFromNow));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    final weekAppointments = _appointmentManager.getAppointmentsByDoctor(_currentDoctor.id)
        .where((a) => a.dateTime.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                     a.dateTime.isBefore(endOfWeek.add(const Duration(days: 1))))
        .toList();
    
    final weekTitle = weeksFromNow == 0 ? 'THIS WEEK' : 'NEXT WEEK';
    print('\n📅 $weekTitle\'S SCHEDULE (${startOfWeek.toString().substring(0, 10)} - ${endOfWeek.toString().substring(0, 10)})');
    print('─────────────────────────────────────────────────────────────');
    
    if (weekAppointments.isEmpty) {
      print('No appointments scheduled for this week.');
      return;
    }
    
    weekAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    String currentDay = '';
    for (final appointment in weekAppointments) {
      final appointmentDay = appointment.dateTime.toString().substring(0, 10);
      if (appointmentDay != currentDay) {
        currentDay = appointmentDay;
        final dayName = _getDayName(appointment.dateTime.weekday);
        print('\n📆 $dayName, $currentDay');
        print('─────────────────────────');
      }
      
      _displayAppointmentSummary(appointment);
    }
  }

  /// Views schedule for a specific date
  void _viewSpecificDateSchedule() {
    final dateStr = _getInput('Enter date (YYYY-MM-DD): ');
    try {
      final date = DateTime.parse(dateStr);
      final dayAppointments = _appointmentManager.getAppointmentsByDoctor(_currentDoctor.id)
          .where((a) => a.dateTime.year == date.year &&
                       a.dateTime.month == date.month &&
                       a.dateTime.day == date.day)
          .toList();
      
      print('\n📅 SCHEDULE FOR ${date.toString().substring(0, 10)}');
      print('─────────────────────────────────────────────');
      
      if (dayAppointments.isEmpty) {
        print('No appointments scheduled for this date.');
        return;
      }
      
      dayAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      
      for (final appointment in dayAppointments) {
        _displayAppointmentDetails(appointment);
      }
    } catch (e) {
      print('❌ Invalid date format. Please use YYYY-MM-DD.');
    }
  }

  /// Views all upcoming appointments
  void _viewUpcomingAppointments() {
    final upcomingAppointments = _appointmentManager.getAppointmentsByDoctor(_currentDoctor.id)
        .where((a) => a.isUpcoming)
        .toList();
    
    print('\n📅 UPCOMING APPOINTMENTS');
    print('──────────────────────');
    
    if (upcomingAppointments.isEmpty) {
      print('No upcoming appointments.');
      return;
    }
    
    upcomingAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    for (final appointment in upcomingAppointments.take(10)) {
      _displayAppointmentDetails(appointment);
    }
    
    if (upcomingAppointments.length > 10) {
      print('... and ${upcomingAppointments.length - 10} more appointments');
    }
  }

  /// Updates appointment status
  void _updateAppointmentStatus() {
    final appointmentId = _getInput('Enter Appointment ID: ');
    final appointment = _appointmentManager.getAppointmentById(appointmentId);
    
    if (appointment == null || appointment.doctor.id != _currentDoctor.id) {
      print('❌ Appointment not found or not assigned to you.');
      return;
    }
    
    print('\nCurrent appointment: ${appointment.patient.name}');
    print('Date: ${appointment.dateTime.toString().substring(0, 16)}');
    print('Current Status: ${appointment.appointmentStatus.displayName}');
    
    print('\nUpdate Status:');
    print('1. Confirm Appointment');
    print('2. Complete Appointment');
    print('3. Mark as No-Show');
    print('4. Cancel Appointment');
    
    final choice = _getInput('Select new status: ');
    
    switch (choice) {
      case '1':
        if (_appointmentManager.confirmAppointment(appointmentId)) {
          print('✅ Appointment confirmed successfully!');
        } else {
          print('❌ Failed to confirm appointment.');
        }
        break;
      case '2':
        if (_appointmentManager.completeAppointment(appointmentId)) {
          print('✅ Appointment marked as completed!');
          _promptForMedicalNotes(appointment);
        } else {
          print('❌ Failed to complete appointment.');
        }
        break;
      case '3':
        if (_appointmentManager.markAppointmentAsNoShow(appointmentId)) {
          print('✅ Appointment marked as no-show!');
        } else {
          print('❌ Failed to mark appointment as no-show.');
        }
        break;
      case '4':
        final reason = _getInput('Cancellation reason: ');
        if (_appointmentManager.cancelAppointment(appointmentId, reason)) {
          print('✅ Appointment cancelled successfully!');
        } else {
          print('❌ Failed to cancel appointment.');
        }
        break;
      default:
        print('❌ Invalid choice.');
    }
  }

  /// Prompts for medical notes after completing an appointment
  void _promptForMedicalNotes(Appointment appointment) {
    print('\n📝 Add medical notes for this appointment:');
    final notes = _getInput('Medical notes (optional): ');
    
    if (notes.isNotEmpty) {
      try {
        _appointmentManager.updateAppointment(appointment.appointmentId, newNotes: notes);
        print('✅ Medical notes added successfully!');
      } catch (e) {
        print('⚠️  Notes could not be saved: $e');
      }
    }
  }

  /// Adds notes to an appointment
  void _addAppointmentNotes() {
    final appointmentId = _getInput('Enter Appointment ID: ');
    final appointment = _appointmentManager.getAppointmentById(appointmentId);
    
    if (appointment == null || appointment.doctor.id != _currentDoctor.id) {
      print('❌ Appointment not found or not assigned to you.');
      return;
    }
    
    print('\nAppointment: ${appointment.patient.name}');
    print('Date: ${appointment.dateTime.toString().substring(0, 16)}');
    print('Current Notes: ${appointment.notes.isEmpty ? 'None' : appointment.notes}');
    
    final newNotes = _getInput('Enter new notes: ');
    
    if (newNotes.isNotEmpty) {
      try {
        _appointmentManager.updateAppointment(appointmentId, newNotes: newNotes);
        print('✅ Notes updated successfully!');
      } catch (e) {
        print('❌ Failed to update notes: $e');
      }
    }
  }

  /// Shows doctor's patients
  void _showMyPatients() {
    final myAppointments = _appointmentManager.getAppointmentsByDoctor(_currentDoctor.id);
    final patientIds = myAppointments.map((a) => a.patient.id).toSet();
    final myPatients = patientIds.map((id) => _appointmentManager.getPatientById(id)).where((p) => p != null).cast<Patient>().toList();
    
    print('\n👥 MY PATIENTS');
    print('─────────────');
    
    if (myPatients.isEmpty) {
      print('No patients found.');
      return;
    }
    
    myPatients.sort((a, b) => a.name.compareTo(b.name));
    
    for (final patient in myPatients) {
      final patientAppointments = myAppointments.where((a) => a.patient.id == patient.id).length;
      print('Name: ${patient.name} | Age: ${patient.age} | Gender: ${patient.gender.displayName}');
      print('Blood Type: ${patient.bloodType.displayName} | Total Appointments: $patientAppointments');
      print('Last Visit: ${patient.lastVisit?.toString().substring(0, 10) ?? 'Never'}');
      
      if (patient.allergies.isNotEmpty) {
        print('⚠️  Allergies: ${patient.allergies.join(', ')}');
      }
      if (patient.chronicConditions.isNotEmpty) {
        print('🩺 Chronic Conditions: ${patient.chronicConditions.join(', ')}');
      }
      
      print('─────────────────────────────────────────────────────────────');
    }
  }

  /// Shows today's appointments
  void _showTodaysAppointments() {
    final today = DateTime.now();
    final todayAppointments = _appointmentManager.getAppointmentsByDoctor(_currentDoctor.id)
        .where((a) => a.dateTime.year == today.year &&
                     a.dateTime.month == today.month &&
                     a.dateTime.day == today.day)
        .toList();
    
    print('\n📅 TODAY\'S APPOINTMENTS (${today.toString().substring(0, 10)})');
    print('─────────────────────────────────────────────────────────────');
    
    if (todayAppointments.isEmpty) {
      print('No appointments scheduled for today.');
      return;
    }
    
    todayAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    for (final appointment in todayAppointments) {
      _displayAppointmentDetails(appointment);
      
      // Show urgency for upcoming appointments
      final timeUntil = appointment.dateTime.difference(DateTime.now());
      if (timeUntil.inMinutes > 0 && timeUntil.inHours < 2) {
        if (timeUntil.inMinutes <= 15) {
          print('🚨 URGENT: Appointment in ${timeUntil.inMinutes} minutes!');
        } else if (timeUntil.inMinutes <= 60) {
          print('⚠️  SOON: Appointment in ${timeUntil.inMinutes} minutes');
        }
      }
      print('');
    }
  }

  /// Shows appointment history
  void _showAppointmentHistory() {
    final allAppointments = _appointmentManager.getAppointmentsByDoctor(_currentDoctor.id);
    final pastAppointments = allAppointments.where((a) => 
        a.dateTime.isBefore(DateTime.now()) && 
        (a.appointmentStatus == AppointmentStatus.completed || 
         a.appointmentStatus == AppointmentStatus.cancelled ||
         a.appointmentStatus == AppointmentStatus.noShow)).toList();
    
    print('\n📋 APPOINTMENT HISTORY');
    print('────────────────────');
    
    if (pastAppointments.isEmpty) {
      print('No appointment history found.');
      return;
    }
    
    pastAppointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    
    print('Total Past Appointments: ${pastAppointments.length}');
    print('');
    
    for (final appointment in pastAppointments.take(15)) {
      _displayAppointmentSummary(appointment);
    }
    
    if (pastAppointments.length > 15) {
      print('... and ${pastAppointments.length - 15} more appointments');
    }
  }

  /// Manages doctor availability
  void _manageAvailability() {
    while (true) {
      print('\n⏰ MANAGE AVAILABILITY');
      print('────────────────────');
      print('Current Status: ${_currentDoctor.isAvailable ? '✅ Available' : '❌ Unavailable'}');
      print('');
      print('1. Toggle Availability Status');
      print('2. View Available Time Slots');
      print('3. Add New Time Slots');
      print('4. Remove Time Slots');
      print('5. Generate Weekly Slots');
      print('0. Back to Main Menu');
      print('────────────────────');

      final choice = _getInput('Enter your choice: ');
      
      switch (choice) {
        case '1':
          _toggleAvailability();
          break;
        case '2':
          _viewAvailableSlots();
          break;
        case '3':
          _addTimeSlots();
          break;
        case '4':
          _removeTimeSlots();
          break;
        case '5':
          _generateWeeklySlots();
          break;
        case '0':
          return;
        default:
          print('❌ Invalid choice. Please try again.');
      }
    }
  }

  /// Toggles doctor availability
  void _toggleAvailability() {
    _currentDoctor.isAvailable = !_currentDoctor.isAvailable;
    final status = _currentDoctor.isAvailable ? 'Available' : 'Unavailable';
    print('✅ Availability updated to: $status');
  }

  /// Views available time slots
  void _viewAvailableSlots() {
    final dateStr = _getInput('Enter date to view slots (YYYY-MM-DD) or press Enter for next 7 days: ');
    
    if (dateStr.isEmpty) {
      // Show next 7 days
      final now = DateTime.now();
      for (int i = 0; i < 7; i++) {
        final date = now.add(Duration(days: i));
        final slots = _currentDoctor.getAvailableSlotsForDate(date);
        
        if (slots.isNotEmpty) {
          print('\n📅 ${date.toString().substring(0, 10)} (${_getDayName(date.weekday)}):');
          for (final slot in slots) {
            print('  ${slot.toString().substring(11, 16)}');
          }
        }
      }
    } else {
      try {
        final date = DateTime.parse(dateStr);
        final slots = _currentDoctor.getAvailableSlotsForDate(date);
        
        print('\n📅 Available slots for ${date.toString().substring(0, 10)}:');
        if (slots.isEmpty) {
          print('No available slots for this date.');
        } else {
          for (final slot in slots) {
            print('  ${slot.toString().substring(11, 16)}');
          }
        }
      } catch (e) {
        print('❌ Invalid date format. Please use YYYY-MM-DD.');
      }
    }
  }

  /// Adds new time slots
  void _addTimeSlots() {
    final dateStr = _getInput('Enter date (YYYY-MM-DD): ');
    final timeStr = _getInput('Enter time (HH:MM): ');
    
    try {
      final date = DateTime.parse('$dateStr $timeStr:00');
      
      if (date.isBefore(DateTime.now())) {
        print('❌ Cannot add slots in the past.');
        return;
      }
      
      _currentDoctor.addAvailableSlot(date);
      print('✅ Time slot added successfully!');
      print('Added: ${date.toString().substring(0, 16)}');
    } catch (e) {
      print('❌ Invalid date or time format.');
    }
  }

  /// Removes time slots
  void _removeTimeSlots() {
    final dateStr = _getInput('Enter date (YYYY-MM-DD): ');
    
    try {
      final date = DateTime.parse(dateStr);
      final slots = _currentDoctor.getAvailableSlotsForDate(date);
      
      if (slots.isEmpty) {
        print('No available slots for this date.');
        return;
      }
      
      print('Available slots:');
      for (int i = 0; i < slots.length; i++) {
        print('${i + 1}. ${slots[i].toString().substring(11, 16)}');
      }
      
      final choice = _getInput('Select slot to remove (1-${slots.length}): ');
      final index = int.tryParse(choice);
      
      if (index == null || index < 1 || index > slots.length) {
        print('❌ Invalid selection.');
        return;
      }
      
      final slotToRemove = slots[index - 1];
      _currentDoctor.removeAvailableSlot(slotToRemove);
      print('✅ Time slot removed successfully!');
    } catch (e) {
      print('❌ Invalid date format. Please use YYYY-MM-DD.');
    }
  }

  /// Generates weekly slots
  void _generateWeeklySlots() {
    final weeksStr = _getInput('Generate slots for how many weeks ahead? ');
    final weeks = int.tryParse(weeksStr) ?? 4;
    
    print('Working days (1=Monday, 7=Sunday):');
    final workingDaysStr = _getInput('Enter working days (e.g., 1,2,3,4,5): ');
    final workingDays = workingDaysStr.split(',').map((s) => int.tryParse(s.trim())).where((d) => d != null).cast<int>().toList();
    
    if (workingDays.isEmpty) {
      print('❌ Invalid working days format.');
      return;
    }
    
    print('Time slots (e.g., 09:00,10:00,11:00,14:00,15:00,16:00):');
    final timeSlotsStr = _getInput('Enter time slots: ');
    final timeSlots = timeSlotsStr.split(',').map((s) => s.trim()).toList();
    
    if (timeSlots.isEmpty) {
      print('❌ Invalid time slots format.');
      return;
    }
    
    _currentDoctor.generateWeeklySlots(
      workingDays: workingDays,
      timeSlots: timeSlots,
      weeksAhead: weeks,
    );
    
    print('✅ Generated weekly slots for $weeks weeks!');
    print('Working days: ${workingDays.join(', ')}');
    print('Time slots: ${timeSlots.join(', ')}');
  }

  /// Shows doctor statistics
  void _showMyStatistics() {
    final allAppointments = _appointmentManager.getAppointmentsByDoctor(_currentDoctor.id);
    final completedAppointments = allAppointments.where((a) => a.appointmentStatus == AppointmentStatus.completed).length;
    final cancelledAppointments = allAppointments.where((a) => a.appointmentStatus == AppointmentStatus.cancelled).length;
    final noShowAppointments = allAppointments.where((a) => a.appointmentStatus == AppointmentStatus.noShow).length;
    final upcomingAppointments = allAppointments.where((a) => a.isUpcoming).length;
    
    final totalRevenue = allAppointments
        .where((a) => a.appointmentStatus == AppointmentStatus.completed)
        .fold(0.0, (sum, a) => sum + (a.consultationFee ?? 0.0));
    
    final patientIds = allAppointments.map((a) => a.patient.id).toSet();
    final uniquePatients = patientIds.length;
    
    print('\n📊 MY STATISTICS');
    print('───────────────');
    print('Total Appointments: ${allAppointments.length}');
    print('Completed: $completedAppointments');
    print('Cancelled: $cancelledAppointments');
    print('No-Shows: $noShowAppointments');
    print('Upcoming: $upcomingAppointments');
    print('');
    print('Unique Patients Treated: $uniquePatients');
    print('Total Revenue: \$${totalRevenue.toStringAsFixed(2)}');
    print('Average Revenue per Appointment: \$${completedAppointments > 0 ? (totalRevenue / completedAppointments).toStringAsFixed(2) : '0.00'}');
    print('');
    print('Current Consultation Fee: \$${_currentDoctor.consultationFee}');
    print('Available Time Slots: ${_currentDoctor.availableSlots.where((s) => s.isAfter(DateTime.now())).length}');
    print('Availability Status: ${_currentDoctor.isAvailable ? 'Available' : 'Unavailable'}');
  }

  /// Shows doctor profile
  void _showMyProfile() {
    print('\n👤 MY PROFILE');
    print('────────────');
    print('Name: ${_currentDoctor.name}');
    print('ID: ${_currentDoctor.id}');
    print('Email: ${_currentDoctor.email}');
    print('Phone: ${_currentDoctor.phoneNumber}');
    print('Date of Birth: ${_currentDoctor.dateOfBirth.toString().substring(0, 10)}');
    print('Age: ${_currentDoctor.age} years');
    print('Address: ${_currentDoctor.address}');
    print('');
    print('Professional Information:');
    print('Specialty: ${_currentDoctor.specialty.displayName}');
    print('License Number: ${_currentDoctor.licenseNumber}');
    print('Years of Experience: ${_currentDoctor.yearsOfExperience}');
    print('Consultation Fee: \$${_currentDoctor.consultationFee}');
    print('Account Status: ${_currentDoctor.isActive ? 'Active' : 'Inactive'}');
    print('Availability: ${_currentDoctor.isAvailable ? 'Available' : 'Unavailable'}');
    
    if (_currentDoctor.qualifications.isNotEmpty) {
      print('\nQualifications:');
      for (final qualification in _currentDoctor.qualifications) {
        print('  • $qualification');
      }
    }
  }

  /// Shows settings menu
  void _showSettings() {
    while (true) {
      print('\n⚙️  SETTINGS');
      print('───────────');
      print('1. Change Password');
      print('2. Update Consultation Fee');
      print('3. Notification Preferences');
      print('4. Help & Support');
      print('0. Back to Main Menu');
      print('───────────');

      final choice = _getInput('Enter your choice: ');
      
      switch (choice) {
        case '1':
          _changePassword();
          break;
        case '2':
          _updateConsultationFee();
          break;
        case '3':
          _notificationPreferences();
          break;
        case '4':
          _helpSupport();
          break;
        case '0':
          return;
        default:
          print('❌ Invalid choice. Please try again.');
      }
    }
  }

  /// Changes doctor password
  void _changePassword() {
    print('\n🔒 CHANGE PASSWORD');
    print('─────────────────');
    
    final currentPassword = _getInput('Enter current password: ');
    if (currentPassword != _currentDoctor.password) {
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

  /// Updates consultation fee
  void _updateConsultationFee() {
    print('\n💰 UPDATE CONSULTATION FEE');
    print('─────────────────────────');
    print('Current fee: \$${_currentDoctor.consultationFee}');
    
    final newFeeStr = _getInput('Enter new consultation fee: \$');
    final newFee = double.tryParse(newFeeStr);
    
    if (newFee == null || newFee < 0) {
      print('❌ Invalid fee amount.');
      return;
    }
    
    _currentDoctor.consultationFee = newFee;
    print('✅ Consultation fee updated to \$${newFee.toStringAsFixed(2)}');
  }

  /// Shows notification preferences
  void _notificationPreferences() {
    print('\n🔔 NOTIFICATION PREFERENCES');
    print('──────────────────────────');
    print('1. Appointment confirmations: Enabled');
    print('2. Schedule changes: Enabled');
    print('3. Patient messages: Enabled');
    print('4. System updates: Enabled');
    print('');
    print('Note: Notification preferences can be updated through the admin portal.');
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
    print('Doctor Support:');
    print('📞 Doctor Helpline: +1-555-0125');
    print('📧 Doctor Support: doctors@hospital.com');
    print('');
    print('Emergency: Call 911');
    print('');
    print('Frequently Asked Questions:');
    print('• How to update appointment status? Use option 1 → 5 from main menu');
    print('• How to add medical notes? Use option 1 → 6 from main menu');
    print('• How to manage availability? Use option 5 from main menu');
    print('• Technical issues? Contact IT support at +1-555-0126');
  }

  // Helper Methods

  /// Displays appointment summary
  void _displayAppointmentSummary(Appointment appointment) {
    final time = appointment.dateTime.toString().substring(11, 16);
    final date = appointment.dateTime.toString().substring(0, 10);
    final status = appointment.appointmentStatus.displayName;
    
    print('$time | ${appointment.patient.name} | $status');
    print('  Reason: ${appointment.reason}');
  }

  /// Displays detailed appointment information
  void _displayAppointmentDetails(Appointment appointment) {
    final date = appointment.dateTime.toString().substring(0, 16);
    final status = appointment.appointmentStatus.displayName;
    
    print('ID: ${appointment.appointmentId}');
    print('Date: $date | Status: $status');
    print('Patient: ${appointment.patient.name} (Age: ${appointment.patient.age})');
    print('Reason: ${appointment.reason}');
    print('Duration: ${appointment.durationMinutes} min | Fee: \$${appointment.consultationFee}');
    if (appointment.notes.isNotEmpty) {
      print('Notes: ${appointment.notes}');
    }
    print('─────────────────────────────────────────────────────────────');
  }

  /// Gets user input
  String _getInput(String prompt) {
    stdout.write(prompt);
    return stdin.readLineSync() ?? '';
  }

  /// Gets day name from weekday number
  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }
}