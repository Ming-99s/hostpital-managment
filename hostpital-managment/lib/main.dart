import 'dart:io';

import 'domain/services/appointmentManager.dart';
import 'domain/models/doctor.dart';
import 'domain/models/patient.dart';
import 'domain/models/appointment.dart';
import 'ui/screens/auth_console.dart';

/// Hospital Management System - Main Entry Point
///
/// This is the main entry point for the Hospital Management System.
/// It initializes the system with sample data and starts the authentication console.
void main() {
  print('🏥 Welcome to Hospital Management System');
  print('========================================');
  
  try {
    // Initialize the appointment manager
    final appointmentManager = AppointmentManager();
    
    // Initialize system with sample data
    _initializeSampleData(appointmentManager);
    
    print('✅ System initialized successfully!');
    print('📊 System Statistics:');
    final stats = appointmentManager.getSystemStatistics();
    print('   - Total Patients: ${stats['totalPatients']}');
    print('   - Total Doctors: ${stats['totalDoctors']}');
    print('   - Total Appointments: ${stats['totalAppointments']}');
    print('');
    
    // Start the authentication console
    final authConsole = AuthConsole(appointmentManager);
    authConsole.start();
    
  } catch (e) {
    print('❌ Error initializing system: $e');
    print('Please check your configuration and try again.');
    exit(1);
  }
}

/// Initializes the system with sample data for demonstration purposes
void _initializeSampleData(AppointmentManager manager) {
  print('🔄 Initializing sample data...');
  
  try {
    // Create sample patients
    final patients = [
      Patient(
        username: 'john_doe',
        password: 'password123',
        name: 'John Doe',
        email: 'john.doe@email.com',
        phoneNumber: '+1-555-0101',
        dateOfBirth: DateTime(1985, 3, 15),
        address: '123 Main St, City, State 12345',
        gender: Gender.male,
        bloodType: BloodType.oPositive,
        height: 175.0,
        weight: 70.0,
        allergies: ['Penicillin'],
        chronicConditions: [],
        emergencyContact: EmergencyContact(
          name: 'Jane Doe',
          phoneNumber: '+1-555-0102',
          relationship: 'Spouse',
          email: 'jane.doe@email.com',
        ),
        insuranceNumber: 'INS001',
        insuranceProvider: 'HealthCare Plus',
      ),
      Patient(
        username: 'mary_smith',
        password: 'password456',
        name: 'Mary Smith',
        email: 'mary.smith@email.com',
        phoneNumber: '+1-555-0201',
        dateOfBirth: DateTime(1990, 7, 22),
        address: '456 Oak Ave, City, State 12345',
        gender: Gender.female,
        bloodType: BloodType.aNegative,
        height: 165.0,
        weight: 60.0,
        allergies: ['Shellfish', 'Pollen'],
        chronicConditions: ['Asthma'],
        emergencyContact: EmergencyContact(
          name: 'Robert Smith',
          phoneNumber: '+1-555-0202',
          relationship: 'Father',
          email: 'robert.smith@email.com',
        ),
        insuranceNumber: 'INS002',
        insuranceProvider: 'MediCare Pro',
      ),
      Patient(
        username: 'david_wilson',
        password: 'password789',
        name: 'David Wilson',
        email: 'david.wilson@email.com',
        phoneNumber: '+1-555-0301',
        dateOfBirth: DateTime(1978, 11, 8),
        address: '789 Pine Rd, City, State 12345',
        gender: Gender.male,
        bloodType: BloodType.bPositive,
        height: 180.0,
        weight: 85.0,
        allergies: [],
        chronicConditions: ['Diabetes Type 2', 'Hypertension'],
        emergencyContact: EmergencyContact(
          name: 'Sarah Wilson',
          phoneNumber: '+1-555-0302',
          relationship: 'Wife',
          email: 'sarah.wilson@email.com',
        ),
        insuranceNumber: 'INS003',
        insuranceProvider: 'Universal Health',
      ),
    ];

    // Create sample doctors
    final doctors = [
      Doctor(
        username: 'dr_johnson',
        password: 'doctor123',
        name: 'Dr. Emily Johnson',
        email: 'emily.johnson@hospital.com',
        phoneNumber: '+1-555-1001',
        dateOfBirth: DateTime(1975, 5, 12),
        address: '100 Medical Center Dr, City, State 12345',
        specialty: Specialty.cardiology,
        licenseNumber: 'MD12345',
        yearsOfExperience: 15,
        consultationFee: 200.0,
        qualifications: ['MD - Harvard Medical School', 'Cardiology Fellowship - Mayo Clinic'],
      ),
      Doctor(
        username: 'dr_brown',
        password: 'doctor456',
        name: 'Dr. Michael Brown',
        email: 'michael.brown@hospital.com',
        phoneNumber: '+1-555-1002',
        dateOfBirth: DateTime(1980, 9, 25),
        address: '200 Medical Center Dr, City, State 12345',
        specialty: Specialty.pediatrics,
        licenseNumber: 'MD23456',
        yearsOfExperience: 10,
        consultationFee: 150.0,
        qualifications: ['MD - Johns Hopkins', 'Pediatrics Residency - Children\'s Hospital'],
      ),
      Doctor(
        username: 'dr_davis',
        password: 'doctor789',
        name: 'Dr. Sarah Davis',
        email: 'sarah.davis@hospital.com',
        phoneNumber: '+1-555-1003',
        dateOfBirth: DateTime(1982, 2, 18),
        address: '300 Medical Center Dr, City, State 12345',
        specialty: Specialty.orthopedics,
        licenseNumber: 'MD34567',
        yearsOfExperience: 8,
        consultationFee: 180.0,
        qualifications: ['MD - Stanford Medical', 'Orthopedic Surgery Fellowship - UCLA'],
      ),
    ];

    // Add patients and doctors to the system
    for (final patient in patients) {
      manager.addPatient(patient);
    }
    
    for (final doctor in doctors) {
      // Generate available slots for the next 4 weeks
      doctor.generateWeeklySlots(
        workingDays: [1, 2, 3, 4, 5], // Monday to Friday
        timeSlots: ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00'],
        weeksAhead: 4,
      );
      manager.addDoctor(doctor);
    }

    // Create sample appointments
    final now = DateTime.now();
    final appointments = [
      // Upcoming appointment
      {
        'patientId': patients[0].id,
        'doctorId': doctors[0].id,
        'dateTime': now.add(const Duration(days: 2, hours: 10)),
        'reason': 'Regular cardiac checkup',
        'type': AppointmentType.consultation,
      },
      // Today's appointment
      {
        'patientId': patients[1].id,
        'doctorId': doctors[1].id,
        'dateTime': DateTime(now.year, now.month, now.day, 14, 30),
        'reason': 'Child vaccination',
        'type': AppointmentType.vaccination,
      },
      // Past appointment (completed)
      {
        'patientId': patients[2].id,
        'doctorId': doctors[2].id,
        'dateTime': now.subtract(const Duration(days: 5, hours: 2)),
        'reason': 'Knee pain consultation',
        'type': AppointmentType.consultation,
      },
    ];

    for (final appointmentData in appointments) {
      try {
        final appointment = manager.createAppointment(
          patientId: appointmentData['patientId'] as String,
          doctorId: appointmentData['doctorId'] as String,
          dateTime: appointmentData['dateTime'] as DateTime,
          reason: appointmentData['reason'] as String,
          appointmentType: appointmentData['type'] as AppointmentType,
        );
        
        // Set different statuses for demonstration
        final appointmentDateTime = appointmentData['dateTime'] as DateTime;
        if (appointmentDateTime.isBefore(now)) {
          manager.completeAppointment(appointment.appointmentId);
        } else if (appointmentData['patientId'] == patients[1].id) {
          manager.confirmAppointment(appointment.appointmentId);
        }
      } catch (e) {
        print('⚠️  Warning: Could not create sample appointment: $e');
      }
    }

    print('✅ Sample data initialized successfully!');
    
  } catch (e) {
    print('⚠️  Warning: Error initializing sample data: $e');
    print('   System will continue with empty data.');
  }
}