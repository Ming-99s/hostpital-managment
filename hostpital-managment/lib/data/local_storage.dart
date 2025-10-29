import 'dart:async';
import 'package:mysql_client/mysql_client.dart';
import 'package:dotenv/dotenv.dart';
import '../domain/models/user.dart';
import '../domain/models/patient.dart';
import '../domain/models/doctor.dart';
import '../domain/models/appointment.dart';

/// Local storage service for managing MySQL database operations
/// Handles all CRUD operations for the hospital management system
class LocalStorageService {
  static MySQLConnection? _connection;
  static DotEnv? _env;

  /// Singleton instance
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  /// Get database connection
  Future<MySQLConnection> get connection async {
    if (_connection == null) {
      await _initConnection();
    }
    return _connection!;
  }

  /// Initialize the database connection
  Future<void> _initConnection() async {
    // Load environment variables
    _env ??= DotEnv(includePlatformEnvironment: true)..load();
    
    _connection = await MySQLConnection.createConnection(
      host: _env!['DB_HOST'] ?? 'localhost',
      port: int.parse(_env!['DB_PORT'] ?? '3306'),
      userName: _env!['DB_USERNAME'] ?? 'root',
      password: _env!['DB_PASSWORD'] ?? '',
      databaseName: _env!['DB_NAME'] ?? 'hospital_management',
    );

    await _connection!.connect();
    await _createTables();
    await _insertDefaultSettings();
  }

  /// Create all database tables
  Future<void> _createTables() async {
    final conn = await connection;
    
    // Users table
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id VARCHAR(255) PRIMARY KEY,
        username VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        phone_number VARCHAR(255) NOT NULL,
        register_date DATETIME NOT NULL,
        date_of_birth DATETIME NOT NULL,
        address TEXT NOT NULL,
        is_active BOOLEAN DEFAULT TRUE,
        user_type ENUM('patient', 'doctor', 'admin') NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      )
    ''');

    // Patients table
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS patients (
        id VARCHAR(255) PRIMARY KEY,
        user_id VARCHAR(255) NOT NULL,
        gender ENUM('male', 'female', 'other') NOT NULL,
        blood_type ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-') NOT NULL,
        height DECIMAL(5,2) NOT NULL,
        weight DECIMAL(5,2) NOT NULL,
        insurance_number VARCHAR(255) NOT NULL,
        insurance_provider VARCHAR(255) NOT NULL,
        last_visit DATETIME,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Emergency contacts table
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS emergency_contacts (
        id INT AUTO_INCREMENT PRIMARY KEY,
        patient_id VARCHAR(255) NOT NULL,
        name VARCHAR(255) NOT NULL,
        phone_number VARCHAR(255) NOT NULL,
        relationship VARCHAR(255) NOT NULL,
        email VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE
      )
    ''');

    // Patient allergies table
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS patient_allergies (
        id INT AUTO_INCREMENT PRIMARY KEY,
        patient_id VARCHAR(255) NOT NULL,
        allergy VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
        UNIQUE(patient_id, allergy)
      )
    ''');

    // Patient chronic conditions table
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS patient_chronic_conditions (
        id INT AUTO_INCREMENT PRIMARY KEY,
        patient_id VARCHAR(255) NOT NULL,
        condition_name VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
        UNIQUE(patient_id, condition_name)
      )
    ''');

    // Doctors table
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS doctors (
        id VARCHAR(255) PRIMARY KEY,
        user_id VARCHAR(255) NOT NULL,
        specialty VARCHAR(255) NOT NULL,
        license_number VARCHAR(255) UNIQUE NOT NULL,
        years_of_experience INT NOT NULL,
        consultation_fee DECIMAL(10,2) NOT NULL,
        is_available BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Doctor qualifications table
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS doctor_qualifications (
        id INT AUTO_INCREMENT PRIMARY KEY,
        doctor_id VARCHAR(255) NOT NULL,
        qualification VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
      )
    ''');

    // Doctor available slots table
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS doctor_available_slots (
        id INT AUTO_INCREMENT PRIMARY KEY,
        doctor_id VARCHAR(255) NOT NULL,
        slot_datetime DATETIME NOT NULL,
        is_booked BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE,
        UNIQUE(doctor_id, slot_datetime)
      )
    ''');

    // Appointments table
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS appointments (
        id VARCHAR(255) PRIMARY KEY,
        patient_id VARCHAR(255) NOT NULL,
        doctor_id VARCHAR(255) NOT NULL,
        appointment_datetime DATETIME NOT NULL,
        appointment_status VARCHAR(50) NOT NULL,
        appointment_type VARCHAR(50) NOT NULL,
        duration_minutes INT DEFAULT 30,
        reason TEXT NOT NULL,
        notes TEXT DEFAULT '',
        consultation_fee DECIMAL(10,2),
        cancellation_reason TEXT,
        completed_at DATETIME,
        created_at DATETIME NOT NULL,
        updated_at DATETIME,
        FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
        FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
      )
    ''');

    // Medical records table
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS medical_records (
        id VARCHAR(255) PRIMARY KEY,
        patient_id VARCHAR(255) NOT NULL,
        doctor_id VARCHAR(255) NOT NULL,
        appointment_id VARCHAR(255),
        record_date DATETIME NOT NULL,
        diagnosis TEXT NOT NULL,
        treatment TEXT NOT NULL,
        notes TEXT DEFAULT '',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
        FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE,
        FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE SET NULL
      )
    ''');

    // Medical record medications table
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS medical_record_medications (
        id INT AUTO_INCREMENT PRIMARY KEY,
        medical_record_id VARCHAR(255) NOT NULL,
        medication VARCHAR(255) NOT NULL,
        dosage VARCHAR(255),
        frequency VARCHAR(255),
        duration VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (medical_record_id) REFERENCES medical_records(id) ON DELETE CASCADE
      )
    ''');

    // System settings table
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS system_settings (
        id INT AUTO_INCREMENT PRIMARY KEY,
        setting_key VARCHAR(255) UNIQUE NOT NULL,
        setting_value TEXT NOT NULL,
        description TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      )
    ''');

    // Create indexes
    await _createIndexes();
    await _createTriggers();
  }

  /// Create database indexes for better performance
  Future<void> _createIndexes() async {
    final conn = await connection;
    await conn.execute('CREATE INDEX IF NOT EXISTS idx_users_username ON users(username)');
    await conn.execute('CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)');
    await conn.execute('CREATE INDEX IF NOT EXISTS idx_users_user_type ON users(user_type)');
    await conn.execute('CREATE INDEX IF NOT EXISTS idx_patients_user_id ON patients(user_id)');
    await conn.execute('CREATE INDEX IF NOT EXISTS idx_doctors_user_id ON doctors(user_id)');
    await conn.execute('CREATE INDEX IF NOT EXISTS idx_doctors_specialty ON doctors(specialty)');
    await conn.execute('CREATE INDEX IF NOT EXISTS idx_appointments_patient_id ON appointments(patient_id)');
    await conn.execute('CREATE INDEX IF NOT EXISTS idx_appointments_doctor_id ON appointments(doctor_id)');
    await conn.execute('CREATE INDEX IF NOT EXISTS idx_appointments_datetime ON appointments(appointment_datetime)');
    await conn.execute('CREATE INDEX IF NOT EXISTS idx_appointments_status ON appointments(appointment_status)');
    await conn.execute('CREATE INDEX IF NOT EXISTS idx_medical_records_patient_id ON medical_records(patient_id)');
    await conn.execute('CREATE INDEX IF NOT EXISTS idx_medical_records_doctor_id ON medical_records(doctor_id)');
    await conn.execute('CREATE INDEX IF NOT EXISTS idx_doctor_slots_doctor_id ON doctor_available_slots(doctor_id)');
    await conn.execute('CREATE INDEX IF NOT EXISTS idx_doctor_slots_datetime ON doctor_available_slots(slot_datetime)');
  }

  /// Create database triggers (MySQL uses ON UPDATE CURRENT_TIMESTAMP in table definition)
  Future<void> _createTriggers() async {
    // MySQL handles timestamp updates automatically with ON UPDATE CURRENT_TIMESTAMP
    // No additional triggers needed
  }

  /// Insert default system settings
  Future<void> _insertDefaultSettings() async {
    final conn = await connection;
    
    // Check if settings already exist
    final result = await conn.execute('SELECT COUNT(*) as count FROM system_settings');
    final count = result.rows.first.colAt(0);
    
    if (count == 0) {
      await conn.execute('''
        INSERT INTO system_settings (setting_key, setting_value, description) VALUES
        ('hospital_name', 'General Hospital', 'Name of the hospital'),
        ('hospital_address', '123 Medical Center Drive', 'Hospital address'),
        ('hospital_phone', '+1-555-0123', 'Hospital main phone number'),
        ('appointment_duration_default', '30', 'Default appointment duration in minutes'),
        ('working_hours_start', '08:00', 'Hospital working hours start time'),
        ('working_hours_end', '18:00', 'Hospital working hours end time'),
        ('max_appointments_per_day', '50', 'Maximum appointments per day'),
        ('appointment_reminder_hours', '24', 'Hours before appointment to send reminder')
      ''');
    }
  }

  // ==================== USER OPERATIONS ====================

  /// Insert a new user
  Future<void> insertUser(User user, String userType) async {
    final conn = await connection;
    await conn.execute('''
      INSERT INTO users (id, username, password, name, email, phone_number,
                        register_date, date_of_birth, address, is_active, user_type)
      VALUES (:id, :username, :password, :name, :email, :phone_number,
              :register_date, :date_of_birth, :address, :is_active, :user_type)
    ''', {
      'id': user.id,
      'username': user.username,
      'password': user.password,
      'name': user.name,
      'email': user.email,
      'phone_number': user.phoneNumber,
      'register_date': user.registerDate.toIso8601String(),
      'date_of_birth': user.dateOfBirth.toIso8601String(),
      'address': user.address,
      'is_active': user.isActive,
      'user_type': userType,
    });
  }

  /// Get user by username and password
  Future<Map<String, dynamic>?> getUserByCredentials(String username, String password) async {
    final conn = await connection;
    final results = await conn.execute('''
      SELECT * FROM users
      WHERE username = :username AND password = :password AND is_active = TRUE
    ''', {
      'username': username,
      'password': password,
    });
    return results.rows.isNotEmpty ? results.rows.first.assoc() : null;
  }

  /// Get user by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final conn = await connection;
    final results = await conn.execute('''
      SELECT * FROM users WHERE id = :id
    ''', {'id': userId});
    return results.rows.isNotEmpty ? results.rows.first.assoc() : null;
  }

  /// Update user
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    final conn = await connection;
    final setClause = updates.keys.map((key) => '$key = :$key').join(', ');
    final params = Map<String, dynamic>.from(updates);
    params['id'] = userId;
    
    await conn.execute('''
      UPDATE users SET $setClause WHERE id = :id
    ''', params);
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    final conn = await connection;
    await conn.execute('DELETE FROM users WHERE id = :id', {'id': userId});
  }

  // ==================== PATIENT OPERATIONS ====================

  /// Insert a new patient
  Future<void> insertPatient(Patient patient) async {
    final conn = await connection;
    
    // Insert user first
    await insertUser(patient, 'patient');
    
    // Insert patient-specific data
    await conn.execute('''
      INSERT INTO patients (id, user_id, gender, blood_type, height, weight,
                           insurance_number, insurance_provider, last_visit)
      VALUES (:id, :user_id, :gender, :blood_type, :height, :weight,
              :insurance_number, :insurance_provider, :last_visit)
    ''', {
      'id': patient.id,
      'user_id': patient.id,
      'gender': patient.gender.name,
      'blood_type': patient.bloodType.displayName,
      'height': patient.height,
      'weight': patient.weight,
      'insurance_number': patient.insuranceNumber,
      'insurance_provider': patient.insuranceProvider,
      'last_visit': patient.lastVisit?.toIso8601String(),
    });

    // Insert emergency contact
    await conn.execute('''
      INSERT INTO emergency_contacts (patient_id, name, phone_number, relationship, email)
      VALUES (:patient_id, :name, :phone_number, :relationship, :email)
    ''', {
      'patient_id': patient.id,
      'name': patient.emergencyContact.name,
      'phone_number': patient.emergencyContact.phoneNumber,
      'relationship': patient.emergencyContact.relationship,
      'email': patient.emergencyContact.email,
    });

    // Insert allergies
    for (final allergy in patient.allergies) {
      await conn.execute('''
        INSERT INTO patient_allergies (patient_id, allergy)
        VALUES (:patient_id, :allergy)
      ''', {
        'patient_id': patient.id,
        'allergy': allergy,
      });
    }

    // Insert chronic conditions
    for (final condition in patient.chronicConditions) {
      await conn.execute('''
        INSERT INTO patient_chronic_conditions (patient_id, condition_name)
        VALUES (:patient_id, :condition_name)
      ''', {
        'patient_id': patient.id,
        'condition_name': condition,
      });
    }
  }

  /// Get patient by ID with full details
  Future<Map<String, dynamic>?> getPatientById(String patientId) async {
    final conn = await connection;
    
    // Get patient with user data
    final results = await conn.execute('''
      SELECT u.*, p.gender, p.blood_type, p.height, p.weight,
             p.insurance_number, p.insurance_provider, p.last_visit
      FROM users u
      JOIN patients p ON u.id = p.user_id
      WHERE u.id = :id AND u.user_type = 'patient'
    ''', {'id': patientId});
    
    if (results.rows.isEmpty) return null;
    
    final patientData = Map<String, dynamic>.from(results.rows.first.assoc());
    
    // Get emergency contact
    final emergencyContact = await conn.execute('''
      SELECT * FROM emergency_contacts WHERE patient_id = :patient_id
    ''', {'patient_id': patientId});
    
    if (emergencyContact.rows.isNotEmpty) {
      patientData['emergency_contact'] = emergencyContact.rows.first.assoc();
    }
    
    // Get allergies
    final allergies = await conn.execute('''
      SELECT allergy FROM patient_allergies WHERE patient_id = :patient_id
    ''', {'patient_id': patientId});
    patientData['allergies'] = allergies.rows.map((row) => row.colAt(0)).toList();
    
    // Get chronic conditions
    final conditions = await conn.execute('''
      SELECT condition_name FROM patient_chronic_conditions WHERE patient_id = :patient_id
    ''', {'patient_id': patientId});
    patientData['chronic_conditions'] = conditions.rows.map((row) => row.colAt(0)).toList();
    
    return patientData;
  }

  /// Get all patients
  Future<List<Map<String, dynamic>>> getAllPatients() async {
    final conn = await connection;
    final results = await conn.execute('''
      SELECT u.*, p.gender, p.blood_type, p.height, p.weight,
             p.insurance_number, p.insurance_provider, p.last_visit
      FROM users u
      JOIN patients p ON u.id = p.user_id
      WHERE u.user_type = 'patient' AND u.is_active = TRUE
      ORDER BY u.name
    ''');
    return results.rows.map((row) => row.assoc()).toList();
  }

  /// Search patients by name or email
  Future<List<Map<String, dynamic>>> searchPatients(String query) async {
    final conn = await connection;
    final results = await conn.execute('''
      SELECT u.*, p.gender, p.blood_type, p.height, p.weight,
             p.insurance_number, p.insurance_provider, p.last_visit
      FROM users u
      JOIN patients p ON u.id = p.user_id
      WHERE u.user_type = 'patient' AND u.is_active = TRUE
        AND (u.name LIKE :query OR u.email LIKE :query OR u.id LIKE :query)
      ORDER BY u.name
    ''', {'query': '%$query%'});
    return results.rows.map((row) => row.assoc()).toList();
  }

  // ==================== DOCTOR OPERATIONS ====================

  /// Insert a new doctor
  Future<void> insertDoctor(Doctor doctor) async {
    final conn = await connection;
    
    // Insert user first
    await insertUser(doctor, 'doctor');
    
    // Insert doctor-specific data
    await conn.execute('''
      INSERT INTO doctors (id, user_id, specialty, license_number, years_of_experience,
                          consultation_fee, is_available)
      VALUES (:id, :user_id, :specialty, :license_number, :years_of_experience,
              :consultation_fee, :is_available)
    ''', {
      'id': doctor.id,
      'user_id': doctor.id,
      'specialty': doctor.specialty.name,
      'license_number': doctor.licenseNumber,
      'years_of_experience': doctor.yearsOfExperience,
      'consultation_fee': doctor.consultationFee,
      'is_available': doctor.isAvailable,
    });

    // Insert qualifications
    for (final qualification in doctor.qualifications) {
      await conn.execute('''
        INSERT INTO doctor_qualifications (doctor_id, qualification)
        VALUES (:doctor_id, :qualification)
      ''', {
        'doctor_id': doctor.id,
        'qualification': qualification,
      });
    }

    // Insert available slots
    for (final slot in doctor.availableSlots) {
      await conn.execute('''
        INSERT INTO doctor_available_slots (doctor_id, slot_datetime, is_booked)
        VALUES (:doctor_id, :slot_datetime, :is_booked)
      ''', {
        'doctor_id': doctor.id,
        'slot_datetime': slot.toIso8601String(),
        'is_booked': false,
      });
    }
  }

  /// Get doctor by ID with full details
  Future<Map<String, dynamic>?> getDoctorById(String doctorId) async {
    final conn = await connection;
    
    // Get doctor with user data
    final results = await conn.execute('''
      SELECT u.*, d.specialty, d.license_number, d.years_of_experience,
             d.consultation_fee, d.is_available
      FROM users u
      JOIN doctors d ON u.id = d.user_id
      WHERE u.id = :id AND u.user_type = 'doctor'
    ''', {'id': doctorId});
    
    if (results.rows.isEmpty) return null;
    
    final doctorData = Map<String, dynamic>.from(results.rows.first.assoc());
    
    // Get qualifications
    final qualifications = await conn.execute('''
      SELECT qualification FROM doctor_qualifications WHERE doctor_id = :doctor_id
    ''', {'doctor_id': doctorId});
    doctorData['qualifications'] = qualifications.rows.map((row) => row.colAt(0)).toList();
    
    // Get available slots
    final slots = await conn.execute('''
      SELECT slot_datetime FROM doctor_available_slots
      WHERE doctor_id = :doctor_id AND is_booked = FALSE
      ORDER BY slot_datetime
    ''', {'doctor_id': doctorId});
    doctorData['available_slots'] = slots.rows.map((row) => row.colAt(0)).toList();
    
    return doctorData;
  }

  /// Get all doctors
  Future<List<Map<String, dynamic>>> getAllDoctors() async {
    final conn = await connection;
    final results = await conn.execute('''
      SELECT u.*, d.specialty, d.license_number, d.years_of_experience,
             d.consultation_fee, d.is_available
      FROM users u
      JOIN doctors d ON u.id = d.user_id
      WHERE u.user_type = 'doctor' AND u.is_active = TRUE
      ORDER BY u.name
    ''');
    return results.rows.map((row) => row.assoc()).toList();
  }

  /// Get doctors by specialty
  Future<List<Map<String, dynamic>>> getDoctorsBySpecialty(String specialty) async {
    final conn = await connection;
    final results = await conn.execute('''
      SELECT u.*, d.specialty, d.license_number, d.years_of_experience,
             d.consultation_fee, d.is_available
      FROM users u
      JOIN doctors d ON u.id = d.user_id
      WHERE u.user_type = 'doctor' AND u.is_active = TRUE
        AND d.specialty = :specialty AND d.is_available = TRUE
      ORDER BY u.name
    ''', {'specialty': specialty});
    return results.rows.map((row) => row.assoc()).toList();
  }

  /// Update doctor availability
  Future<void> updateDoctorAvailability(String doctorId, bool isAvailable) async {
    final conn = await connection;
    await conn.execute('''
      UPDATE doctors SET is_available = :is_available WHERE id = :id
    ''', {
      'is_available': isAvailable,
      'id': doctorId,
    });
  }

  /// Add doctor available slot
  Future<void> addDoctorSlot(String doctorId, DateTime slot) async {
    final conn = await connection;
    await conn.execute('''
      INSERT INTO doctor_available_slots (doctor_id, slot_datetime, is_booked)
      VALUES (:doctor_id, :slot_datetime, :is_booked)
    ''', {
      'doctor_id': doctorId,
      'slot_datetime': slot.toIso8601String(),
      'is_booked': false,
    });
  }

  /// Remove doctor available slot
  Future<void> removeDoctorSlot(String doctorId, DateTime slot) async {
    final conn = await connection;
    await conn.execute('''
      DELETE FROM doctor_available_slots
      WHERE doctor_id = :doctor_id AND slot_datetime = :slot_datetime
    ''', {
      'doctor_id': doctorId,
      'slot_datetime': slot.toIso8601String(),
    });
  }

  /// Book doctor slot
  Future<void> bookDoctorSlot(String doctorId, DateTime slot) async {
    final conn = await connection;
    await conn.execute('''
      UPDATE doctor_available_slots
      SET is_booked = TRUE
      WHERE doctor_id = :doctor_id AND slot_datetime = :slot_datetime
    ''', {
      'doctor_id': doctorId,
      'slot_datetime': slot.toIso8601String(),
    });
  }

  // ==================== APPOINTMENT OPERATIONS ====================

  /// Insert a new appointment
  Future<void> insertAppointment(Appointment appointment) async {
    final conn = await connection;
    
    // Book the doctor slot
    await bookDoctorSlot(appointment.doctor.id, appointment.dateTime);
    
    await conn.execute('''
      INSERT INTO appointments (id, patient_id, doctor_id, appointment_datetime,
                               appointment_status, appointment_type, duration_minutes,
                               reason, notes, consultation_fee, created_at, updated_at)
      VALUES (:id, :patient_id, :doctor_id, :appointment_datetime,
              :appointment_status, :appointment_type, :duration_minutes,
              :reason, :notes, :consultation_fee, :created_at, :updated_at)
    ''', {
      'id': appointment.appointmentId,
      'patient_id': appointment.patient.id,
      'doctor_id': appointment.doctor.id,
      'appointment_datetime': appointment.dateTime.toIso8601String(),
      'appointment_status': appointment.appointmentStatus.name,
      'appointment_type': appointment.appointmentType.name,
      'duration_minutes': appointment.durationMinutes,
      'reason': appointment.reason,
      'notes': appointment.notes,
      'consultation_fee': appointment.consultationFee,
      'created_at': appointment.createdAt.toIso8601String(),
      'updated_at': appointment.updatedAt?.toIso8601String(),
    });
  }

  /// Get appointment by ID
  Future<Map<String, dynamic>?> getAppointmentById(String appointmentId) async {
    final conn = await connection;
    final results = await conn.execute('''
      SELECT a.*,
             p_user.name as patient_name, p_user.email as patient_email,
             d_user.name as doctor_name, d_user.email as doctor_email,
             d.specialty as doctor_specialty
      FROM appointments a
      JOIN patients p ON a.patient_id = p.id
      JOIN users p_user ON p.user_id = p_user.id
      JOIN doctors d ON a.doctor_id = d.id
      JOIN users d_user ON d.user_id = d_user.id
      WHERE a.id = :id
    ''', {'id': appointmentId});
    
    return results.rows.isNotEmpty ? results.rows.first.assoc() : null;
  }

  /// Get all appointments
  Future<List<Map<String, dynamic>>> getAllAppointments() async {
    final conn = await connection;
    final results = await conn.execute('''
      SELECT a.*,
             p_user.name as patient_name, p_user.email as patient_email,
             d_user.name as doctor_name, d_user.email as doctor_email,
             d.specialty as doctor_specialty
      FROM appointments a
      JOIN patients p ON a.patient_id = p.id
      JOIN users p_user ON p.user_id = p_user.id
      JOIN doctors d ON a.doctor_id = d.id
      JOIN users d_user ON d.user_id = d_user.id
      ORDER BY a.appointment_datetime DESC
    ''');
    return results.rows.map((row) => row.assoc()).toList();
  }

  /// Get appointments by patient ID
  Future<List<Map<String, dynamic>>> getAppointmentsByPatient(String patientId) async {
    final conn = await connection;
    final results = await conn.execute('''
      SELECT a.*,
             p_user.name as patient_name, p_user.email as patient_email,
             d_user.name as doctor_name, d_user.email as doctor_email,
             d.specialty as doctor_specialty
      FROM appointments a
      JOIN patients p ON a.patient_id = p.id
      JOIN users p_user ON p.user_id = p_user.id
      JOIN doctors d ON a.doctor_id = d.id
      JOIN users d_user ON d.user_id = d_user.id
      WHERE a.patient_id = :patient_id
      ORDER BY a.appointment_datetime DESC
    ''', {'patient_id': patientId});
    return results.rows.map((row) => row.assoc()).toList();
  }

  /// Get appointments by doctor ID
  Future<List<Map<String, dynamic>>> getAppointmentsByDoctor(String doctorId) async {
    final conn = await connection;
    final results = await conn.execute('''
      SELECT a.*,
             p_user.name as patient_name, p_user.email as patient_email,
             d_user.name as doctor_name, d_user.email as doctor_email,
             d.specialty as doctor_specialty
      FROM appointments a
      JOIN patients p ON a.patient_id = p.id
      JOIN users p_user ON p.user_id = p_user.id
      JOIN doctors d ON a.doctor_id = d.id
      JOIN users d_user ON d.user_id = d_user.id
      WHERE a.doctor_id = :doctor_id
      ORDER BY a.appointment_datetime DESC
    ''', {'doctor_id': doctorId});
    return results.rows.map((row) => row.assoc()).toList();
  }

  /// Get appointments by status
  Future<List<Map<String, dynamic>>> getAppointmentsByStatus(String status) async {
    final conn = await connection;
    final results = await conn.execute('''
      SELECT a.*,
             p_user.name as patient_name, p_user.email as patient_email,
             d_user.name as doctor_name, d_user.email as doctor_email,
             d.specialty as doctor_specialty
      FROM appointments a
      JOIN patients p ON a.patient_id = p.id
      JOIN users p_user ON p.user_id = p_user.id
      JOIN doctors d ON a.doctor_id = d.id
      JOIN users d_user ON d.user_id = d_user.id
      WHERE a.appointment_status = :status
      ORDER BY a.appointment_datetime DESC
    ''', {'status': status});
    return results.rows.map((row) => row.assoc()).toList();
  }

  /// Get appointments by date
  Future<List<Map<String, dynamic>>> getAppointmentsByDate(DateTime date) async {
    final conn = await connection;
    final startDate = DateTime(date.year, date.month, date.day).toIso8601String();
    final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();
    
    final results = await conn.execute('''
      SELECT a.*,
             p_user.name as patient_name, p_user.email as patient_email,
             d_user.name as doctor_name, d_user.email as doctor_email,
             d.specialty as doctor_specialty
      FROM appointments a
      JOIN patients p ON a.patient_id = p.id
      JOIN users p_user ON p.user_id = p_user.id
      JOIN doctors d ON a.doctor_id = d.id
      JOIN users d_user ON d.user_id = d_user.id
      WHERE a.appointment_datetime >= :start_date AND a.appointment_datetime <= :end_date
      ORDER BY a.appointment_datetime
    ''', {
      'start_date': startDate,
      'end_date': endDate,
    });
    return results.rows.map((row) => row.assoc()).toList();
  }

  /// Update appointment
  Future<void> updateAppointment(String appointmentId, Map<String, dynamic> updates) async {
    final conn = await connection;
    updates['updated_at'] = DateTime.now().toIso8601String();
    
    final setClause = updates.keys.map((key) => '$key = :$key').join(', ');
    final params = Map<String, dynamic>.from(updates);
    params['id'] = appointmentId;
    
    await conn.execute('''
      UPDATE appointments SET $setClause WHERE id = :id
    ''', params);
  }

  /// Cancel appointment
  Future<void> cancelAppointment(String appointmentId, String reason) async {
    final conn = await connection;
    
    // Get appointment details to free up the slot
    final appointment = await getAppointmentById(appointmentId);
    if (appointment != null) {
      // Free up the doctor slot
      await conn.execute('''
        UPDATE doctor_available_slots
        SET is_booked = FALSE
        WHERE doctor_id = :doctor_id AND slot_datetime = :slot_datetime
      ''', {
        'doctor_id': appointment['doctor_id'],
        'slot_datetime': appointment['appointment_datetime'],
      });
    }
    
    await conn.execute('''
      UPDATE appointments
      SET appointment_status = 'cancelled',
          cancellation_reason = :reason,
          updated_at = :updated_at
      WHERE id = :id
    ''', {
      'reason': reason,
      'updated_at': DateTime.now().toIso8601String(),
      'id': appointmentId,
    });
  }

  /// Search appointments
  Future<List<Map<String, dynamic>>> searchAppointments(String query) async {
    final conn = await connection;
    final results = await conn.execute('''
      SELECT a.*,
             p_user.name as patient_name, p_user.email as patient_email,
             d_user.name as doctor_name, d_user.email as doctor_email,
             d.specialty as doctor_specialty
      FROM appointments a
      JOIN patients p ON a.patient_id = p.id
      JOIN users p_user ON p.user_id = p_user.id
      JOIN doctors d ON a.doctor_id = d.id
      JOIN users d_user ON d.user_id = d_user.id
      WHERE p_user.name LIKE :query OR d_user.name LIKE :query OR a.reason LIKE :query
      ORDER BY a.appointment_datetime DESC
    ''', {'query': '%$query%'});
    return results.rows.map((row) => row.assoc()).toList();
  }

  // ==================== SYSTEM OPERATIONS ====================

  /// Get system statistics
  Future<Map<String, dynamic>> getSystemStatistics() async {
    final conn = await connection;
    
    final totalPatients = await conn.execute('SELECT COUNT(*) as count FROM patients');
    final totalDoctors = await conn.execute('SELECT COUNT(*) as count FROM doctors');
    final totalAppointments = await conn.execute('SELECT COUNT(*) as count FROM appointments');
    
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day).toIso8601String();
    final todayEnd = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();
    
    final todayAppointments = await conn.execute('''
      SELECT COUNT(*) as count FROM appointments
      WHERE appointment_datetime >= :start AND appointment_datetime <= :end
    ''', {'start': todayStart, 'end': todayEnd});
    
    final pendingAppointments = await conn.execute('''
      SELECT COUNT(*) as count FROM appointments WHERE appointment_status = 'pending'
    ''');
    
    final confirmedAppointments = await conn.execute('''
      SELECT COUNT(*) as count FROM appointments WHERE appointment_status = 'confirmed'
    ''');
    
    final completedAppointments = await conn.execute('''
      SELECT COUNT(*) as count FROM appointments WHERE appointment_status = 'completed'
    ''');
    
    final cancelledAppointments = await conn.execute('''
      SELECT COUNT(*) as count FROM appointments WHERE appointment_status = 'cancelled'
    ''');
    
    return {
      'totalPatients': totalPatients.rows.first.colAt(0),
      'totalDoctors': totalDoctors.rows.first.colAt(0),
      'totalAppointments': totalAppointments.rows.first.colAt(0),
      'todayAppointments': todayAppointments.rows.first.colAt(0),
      'pendingAppointments': pendingAppointments.rows.first.colAt(0),
      'confirmedAppointments': confirmedAppointments.rows.first.colAt(0),
      'completedAppointments': completedAppointments.rows.first.colAt(0),
      'cancelledAppointments': cancelledAppointments.rows.first.colAt(0),
    };
  }

  /// Clear all data
  Future<void> clearAllData() async {
    final conn = await connection;
    
    // Delete in order to respect foreign key constraints
    await conn.execute('DELETE FROM medical_record_medications');
    await conn.execute('DELETE FROM medical_records');
    await conn.execute('DELETE FROM appointments');
    await conn.execute('DELETE FROM doctor_available_slots');
    await conn.execute('DELETE FROM doctor_qualifications');
    await conn.execute('DELETE FROM patient_chronic_conditions');
    await conn.execute('DELETE FROM patient_allergies');
    await conn.execute('DELETE FROM emergency_contacts');
    await conn.execute('DELETE FROM doctors');
    await conn.execute('DELETE FROM patients');
    await conn.execute('DELETE FROM users');
  }

  /// Close database connection
  Future<void> close() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
  }

  /// Get database connection info (for debugging)
  String getDatabaseInfo() {
    return 'MySQL Connection: ${_env?['DB_HOST']}:${_env?['DB_PORT']}/${_env?['DB_NAME']}';
  }
}