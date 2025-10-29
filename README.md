# Hospital Management System

A comprehensive hospital management system built with Dart, featuring both SQLite and MySQL database support, console-based interfaces for managers and patients, and complete CRUD operations for managing hospital data.

## 🏥 Features

### Core Functionality
- **Patient Management**: Registration, profile management, medical history tracking
- **Doctor Management**: Doctor profiles, specialties, availability scheduling
- **Appointment System**: Booking, rescheduling, cancellation, status tracking
- **Medical Records**: Diagnosis tracking, treatment history, medication management
- **Reporting**: System statistics, daily/monthly reports, analytics

### User Interfaces
- **Manager Console**: Complete administrative interface for hospital staff
- **Patient Console**: Patient-focused interface for appointment management
- **Database Management**: Comprehensive data persistence and retrieval

### Database Support
- **SQLite**: Local database for development and standalone deployments
- **MySQL**: Production-ready database with full schema support
- **Schema Synchronization**: Consistent data structure across both databases

## 📁 Project Structure

```
hostpital-managment/
├── lib/
│   ├── data/
│   │   ├── local_storage.dart          # SQLite database operations
│   │   ├── mysql_storage.dart          # MySQL database operations
│   │   ├── database_interface.dart     # Database abstraction layer
│   │   └── schema.sql                  # MySQL database schema
│   ├── domain/
│   │   ├── models/
│   │   │   ├── user.dart              # Base user model
│   │   │   ├── patient.dart           # Patient model with medical data
│   │   │   ├── doctor.dart            # Doctor model with specialties
│   │   │   └── appointment.dart       # Appointment model
│   │   └── services/
│   │       └── appointmentManager.dart # Business logic service
│   └── ui/
│       └── screens/
│           ├── manager_console.dart    # Administrative interface
│           └── user_console.dart       # Patient interface
├── .env                               # Environment configuration
├── schema.sql                         # Database schema (root level)
├── test_implementation.dart           # Test and demo file
└── pubspec.yaml                       # Dependencies
```

## 🚀 Quick Start

### Prerequisites
- Dart SDK 3.0.0 or higher
- SQLite (included with most systems)
- MySQL Server (optional, for production use)

### Installation

1. **Clone and setup the project:**
   ```bash
   cd hostpital-managment
   dart pub get
   ```

2. **Configure environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your database configuration
   ```

3. **For MySQL setup (optional):**
   ```bash
   # Create database
   mysql -u root -p
   CREATE DATABASE hospital_management;
   
   # Import schema
   mysql -u root -p hospital_management < schema.sql
   ```

4. **Run the application:**
   ```bash
   # For testing
   dart run test_implementation.dart
   
   # For manager interface
   dart run lib/main.dart --mode=manager
   
   # For patient interface  
   dart run lib/main.dart --mode=patient
   ```

## 🗄️ Database Configuration

### SQLite Configuration (Default)
```dart
// Automatically configured for local development
final localStorage = LocalStorageService();
await localStorage.initialize();
```

### MySQL Configuration
```env
# Update .env file
DB_TYPE=mysql
DB_HOST=localhost
DB_PORT=3306
DB_NAME=hospital_management
DB_USERNAME=your_username
DB_PASSWORD=your_password
```

## 📊 Database Schema

### Core Tables
- **users**: Base user information (patients, doctors, admins)
- **patients**: Patient-specific medical data
- **doctors**: Doctor profiles and specialties
- **appointments**: Appointment scheduling and tracking
- **medical_records**: Patient medical history
- **emergency_contacts**: Patient emergency contact information

### Relationship Tables
- **patient_allergies**: Patient allergy tracking
- **patient_chronic_conditions**: Chronic condition management
- **doctor_qualifications**: Doctor credentials
- **doctor_available_slots**: Doctor scheduling
- **medical_record_medications**: Medication tracking

### System Tables
- **system_settings**: Application configuration

## 🖥️ User Interfaces

### Manager Console (`manager_console.dart`)
Complete administrative interface with:
- **Patient Management**: Add, view, update, remove patients
- **Doctor Management**: Manage doctor profiles and schedules
- **Appointment Management**: Schedule, modify, cancel appointments
- **Reports & Statistics**: System analytics and reporting
- **Search & Filters**: Advanced data filtering
- **System Settings**: Configuration and maintenance

### Patient Console (`user_console.dart`)
Patient-focused interface with:
- **My Appointments**: View and manage personal appointments
- **Book Appointments**: Find doctors and schedule visits
- **Find Doctors**: Search by specialty or name
- **My Profile**: View personal and medical information
- **Medical History**: Access past medical records
- **Settings**: Account management and preferences

## 💾 Data Storage

### LocalStorageService (SQLite)
```dart
final localStorage = LocalStorageService();

// Initialize database
await localStorage.initialize();

// Insert patient
await localStorage.insertPatient(patient);

// Get appointments
final appointments = await localStorage.getAppointmentsByPatient(patientId);
```

### MySQLStorageService (MySQL)
```dart
final mysqlStorage = MySQLStorageService();

// Initialize with environment config
await mysqlStorage.initialize();

// All operations use same interface as SQLite
await mysqlStorage.insertPatient(patient);
```

### Database Interface
```dart
// Use abstraction layer for database-agnostic code
final DatabaseInterface db = DatabaseFactory.create(config);
await db.initialize();
await db.insertPatient(patient);
```

## 🔧 Key Components

### Models
- **User**: Base class for all user types
- **Patient**: Extends User with medical information
- **Doctor**: Extends User with professional details
- **Appointment**: Manages appointment scheduling
- **MedicalRecord**: Tracks patient medical history
- **EmergencyContact**: Patient emergency contact info

### Services
- **AppointmentManager**: Core business logic service
- **LocalStorageService**: SQLite database operations
- **MySQLStorageService**: MySQL database operations

### Enums
- **AppointmentStatus**: pending, confirmed, completed, cancelled, noShow, rescheduled
- **AppointmentType**: consultation, followUp, checkup, surgery, emergency, vaccination
- **Specialty**: Medical specialties (cardiology, pediatrics, etc.)
- **Gender**: male, female, other
- **BloodType**: A+, A-, B+, B-, AB+, AB-, O+, O-

## 📈 Usage Examples

### Creating a Patient
```dart
final patient = Patient(
  username: 'john_doe',
  password: 'secure_password',
  name: 'John Doe',
  email: 'john@email.com',
  phoneNumber: '+1-555-0123',
  dateOfBirth: DateTime(1990, 5, 15),
  address: '123 Main St',
  gender: Gender.male,
  bloodType: BloodType.oPositive,
  height: 175.0,
  weight: 70.0,
  emergencyContact: EmergencyContact(
    name: 'Jane Doe',
    phoneNumber: '+1-555-0124',
    relationship: 'Spouse',
    email: 'jane@email.com',
  ),
  insuranceNumber: 'INS123456',
  insuranceProvider: 'Health Insurance Co.',
);

await localStorage.insertPatient(patient);
```

### Scheduling an Appointment
```dart
final appointment = appointmentManager.createAppointment(
  patientId: patient.id,
  doctorId: doctor.id,
  dateTime: DateTime.now().add(Duration(days: 1)),
  reason: 'Regular checkup',
  appointmentType: AppointmentType.consultation,
  durationMinutes: 30,
);
```

### Running Console Interfaces
```dart
// Manager interface
final managerConsole = HospitalConsole(appointmentManager);
managerConsole.start();

// Patient interface
final patientConsole = PatientConsole(appointmentManager, patient);
patientConsole.start();
```

## 🔒 Security Features

- Password-based authentication
- User role management (patient, doctor, admin)
- Data validation and sanitization
- Foreign key constraints for data integrity
- Secure database connections

## 📊 Reporting & Analytics

### System Statistics
- Total patients, doctors, appointments
- Appointment status distribution
- Daily and monthly reports
- Revenue tracking
- Performance metrics

### Available Reports
- **Daily Report**: Appointments and revenue for specific date
- **Monthly Report**: Comprehensive monthly statistics
- **Patient Statistics**: Demographics and health data
- **Doctor Statistics**: Specialty distribution and performance
- **System Overview**: Complete system health check

## 🛠️ Development

### Testing
```bash
# Run test implementation
dart run test_implementation.dart

# Run unit tests
dart test
```

### Database Management
```bash
# Reset SQLite database
rm hospital_management.db

# Reset MySQL database
mysql -u root -p -e "DROP DATABASE hospital_management; CREATE DATABASE hospital_management;"
mysql -u root -p hospital_management < schema.sql
```

## 📝 Configuration

### Environment Variables (.env)
```env
# Database Configuration
DB_TYPE=sqlite                    # or mysql
DB_HOST=localhost
DB_PORT=3306
DB_NAME=hospital_management
DB_USERNAME=root
DB_PASSWORD=your_password

# Application Settings
HOSPITAL_NAME=General Hospital
DEFAULT_APPOINTMENT_DURATION=30
WORKING_HOURS_START=08:00
WORKING_HOURS_END=18:00
```

### System Settings (Database)
- Hospital information
- Working hours
- Appointment defaults
- Notification preferences
- System limits and thresholds

## 🚨 Error Handling

The system includes comprehensive error handling:
- **AppointmentException**: Appointment-related errors
- **DatabaseException**: Database operation errors
- **Validation errors**: Input validation and constraints
- **Connection errors**: Database connectivity issues

## 🔄 Data Synchronization

The system maintains data consistency through:
- Foreign key constraints
- Transaction support
- Automatic timestamp updates
- Data validation
- Conflict detection

## 📚 API Reference

### Core Classes
- [`LocalStorageService`](hostpital-managment/lib/data/local_storage.dart): SQLite operations
- [`MySQLStorageService`](hostpital-managment/lib/data/mysql_storage.dart): MySQL operations
- [`DatabaseInterface`](hostpital-managment/lib/data/database_interface.dart): Abstraction layer
- [`AppointmentManager`](hostpital-managment/lib/domain/services/appointmentManager.dart): Business logic
- [`HospitalConsole`](hostpital-managment/lib/ui/screens/manager_console.dart): Manager interface
- [`PatientConsole`](hostpital-managment/lib/ui/screens/user_console.dart): Patient interface

### Models
- [`User`](hostpital-managment/lib/domain/models/user.dart): Base user class
- [`Patient`](hostpital-managment/lib/domain/models/patient.dart): Patient with medical data
- [`Doctor`](hostpital-managment/lib/domain/models/doctor.dart): Doctor with specialties
- [`Appointment`](hostpital-managment/lib/domain/models/appointment.dart): Appointment management

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Check the documentation
- Review the test implementation
- Contact the development team

---

**Hospital Management System** - Efficient healthcare management through technology.