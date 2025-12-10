# 🏥 Hospital Management System

A command-line based Hospital Management System built with Dart that manages appointments, users, and hospital operations efficiently.

## 📋 Overview

This Hospital Management System is a comprehensive application that allows patients, doctors, and administrators to manage medical appointments through an intuitive command-line interface. The system handles user authentication, appointment scheduling, and various administrative tasks.

## ✨ Features

### User Management
- **Multi-role Authentication**: Support for three user types (Patient, Doctor, Admin)
- **User Registration**: Patients and doctors can register themselves
- **Secure Login**: Authentication system with username and password
- **User Profile Management**: Manage user information

### Appointment Management
- **Schedule Appointments**: Patients can book appointments with doctors
- **Appointment Status Tracking**: Track appointments with statuses (pending, approved, rejected, canceled)
- **Appointment Approval**: Doctors can approve or reject appointment requests
- **Appointment History**: View past and upcoming appointments
- **Cancel Appointments**: Patients can cancel their appointments

### Role-Based Dashboards
- **Patient Dashboard**: Book appointments, view appointment history, manage profile
- **Doctor Dashboard**: View appointments, approve/reject requests, manage availability
- **Admin Dashboard**: Manage all users, view system statistics, oversee operations

## 🛠️ Technologies Used

- **Language**: Dart (SDK >=3.0.0 <4.0.0)
- **UUID Generation**: uuid package (^4.4.2)
- **Testing Framework**: test package (^1.25.0)
- **Data Storage**: JSON file-based storage

## 📁 Project Structure

```
hostpital-managment/
├── lib/
│   ├── data/
│   │   ├── Repository/
│   │   │   ├── User_file.dart          # User data repository
│   │   │   └── appointments_file.dart  # Appointments data repository
│   │   ├── users.json                  # User data storage
│   │   └── appointments.json           # Appointments data storage
│   ├── domain/
│   │   ├── Service/
│   │   │   ├── authService.dart        # Authentication service
│   │   │   ├── userManager.dart        # User management service
│   │   │   ├── appointmentManager.dart # Appointment management service
│   │   │   └── doctorService.dart      # Doctor-specific service
│   │   ├── user.dart                   # Base User class
│   │   ├── patient.dart                # Patient class
│   │   ├── doctor.dart                 # Doctor class
│   │   ├── admin.dart                  # Admin class
│   │   └── appointment.dart            # Appointment class
│   ├── ui/
│   │   ├── authUI.dart                 # Authentication UI
│   │   ├── patientDashboard.dart       # Patient dashboard UI
│   │   ├── doctorDashboard.dart        # Doctor dashboard UI
│   │   └── adminDashboard.dart         # Admin dashboard UI
│   └── main.dart                       # Application entry point
├── test/
│   ├── service/                        # Service tests
│   ├── repository/                     # Repository tests
│   └── domain/                         # Domain tests
├── pubspec.yaml                        # Project configuration
└── README.md                           # This file
```

## 🚀 Installation

### Prerequisites

- Dart SDK (version 3.0.0 or higher)
- Git

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/Ming-99s/hostpital-managment.git
   cd hostpital-managment
   ```

2. **Install dependencies**
   ```bash
   dart pub get
   ```

3. **Verify installation**
   ```bash
   dart --version
   ```

## 💻 Usage

### Running the Application

From the project root directory, run:

```bash
dart hostpital-managment/lib/main.dart
```

### Main Menu Options

When you start the application, you'll see:

```
====================================
   🏥 HOSPITAL MANAGEMENT SYSTEM
====================================
1. 🔐 Login
2. 📝 Register as Patient
3. 👨‍⚕️ Register as Doctor
4. 🚪 Exit
```

### User Workflows

#### For Patients:
1. Register as a patient (option 2)
2. Login with your credentials
3. Access patient dashboard to:
   - Book new appointments with available doctors
   - View your appointment history
   - Cancel appointments
   - Manage your profile

#### For Doctors:
1. Register as a doctor (option 3)
2. Login with your credentials
3. Access doctor dashboard to:
   - View pending appointment requests
   - Approve or reject appointments
   - View your schedule
   - Manage your profile

#### For Administrators:
1. Login with admin credentials
2. Access admin dashboard to:
   - Manage all users (patients and doctors)
   - View system-wide statistics
   - Oversee all appointments
   - Manage system settings

## 🧪 Testing

The project includes comprehensive unit tests for services, repositories, and domain logic.

### Run all tests:
```bash
dart test
```

### Run specific test files:
```bash
dart test test/service/authService_test.dart
dart test test/service/userManager_test.dart
dart test test/service/appointmetnManager_test.dart
dart test test/service/doctorService_test.dart
```

### Test Coverage

Tests are organized into:
- **Service Tests**: Testing business logic and service operations
- **Repository Tests**: Testing data access layer
- **Domain Tests**: Testing domain models

## 📊 Data Storage

The system uses JSON files for data persistence:
- `lib/data/users.json` - Stores user information
- `lib/data/appointments.json` - Stores appointment data

## 🔐 Security Considerations

- Passwords are stored in the JSON files (Note: This is for development/educational purposes only)
- For production use, implement proper password hashing and secure storage
- Consider implementing session management and token-based authentication

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -m 'Add some feature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a Pull Request

## 📝 License

This project is available for educational and personal use.

## 👥 Authors

- Ming-99s

## 🐛 Known Issues

- Data persistence relies on JSON files (not suitable for production)
- No encryption for sensitive user data
- Limited concurrent user support

## 🔮 Future Enhancements

- [ ] Add database support (PostgreSQL/MySQL)
- [ ] Implement password hashing
- [ ] Add email notifications for appointments
- [ ] Create a web-based UI
- [ ] Add appointment reminders
- [ ] Implement doctor availability scheduling
- [ ] Add patient medical records management
- [ ] Generate appointment receipts/reports

## 📧 Contact

For questions or feedback, please open an issue on the GitHub repository.

---

Made with ❤️ using Dart
