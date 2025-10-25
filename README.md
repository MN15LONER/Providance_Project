# Muni-Report Pro

A civic engagement mobile application that bridges communication between South African citizens and government officials.

## 🌟 Features

### For Citizens
- **Report Issues**: Report municipal issues (potholes, water leaks, electricity outages, etc.) with GPS-tagged photos
- **Community Verification**: Verify other citizens' reports to increase priority
- **Propose Ideas**: Submit community improvement ideas and vote on others' proposals
- **Interactive Map**: View all issues and ideas on an interactive map
- **Gamification**: Earn points, badges, and compete on leaderboards
- **Real-time Updates**: Receive push notifications on issue status changes

### For Officials
- **Manage Reports**: View, assign, and update status of citizen reports
- **Respond to Ideas**: Review and respond to community proposals
- **Post Announcements**: Broadcast important information to citizens
- **Analytics Dashboard**: Track performance metrics and community engagement
- **Department Management**: Assign issues to specific departments

## 🏗️ Architecture

The app follows **Clean Architecture** principles with a feature-based folder structure:

```
lib/
├── core/                    # Core functionality
│   ├── config/             # App configuration
│   ├── constants/          # Constants and enums
│   ├── theme/              # App theme and styling
│   ├── utils/              # Utility functions
│   ├── services/           # Core services (notifications, location)
│   └── errors/             # Error handling
│
├── features/               # Feature modules
│   ├── auth/              # Authentication
│   ├── issues/            # Issue reporting and management
│   ├── ideas/             # Community ideas and voting
│   ├── map/               # Interactive map view
│   ├── announcements/     # Announcements and notifications
│   ├── gamification/      # Points, badges, leaderboards
│   └── admin/             # Admin dashboard
│
└── main.dart              # App entry point
```

Each feature follows the structure:
```
feature/
├── data/
│   ├── models/            # Data models
│   └── repositories/      # Data repositories
├── domain/
│   ├── entities/          # Business entities
│   └── usecases/          # Business logic
└── presentation/
    ├── pages/             # UI pages
    ├── widgets/           # Reusable widgets
    └── providers/         # State management
```

## 🛠️ Tech Stack

### Frontend
- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Navigation**: go_router
- **UI**: Material Design 3

### Backend
- **Platform**: Firebase
- **Authentication**: Firebase Authentication
- **Database**: Cloud Firestore
- **Storage**: Firebase Storage
- **Push Notifications**: Firebase Cloud Messaging
- **Analytics**: Firebase Analytics
- **Crash Reporting**: Firebase Crashlytics

### APIs & Services
- **Maps**: Google Maps Flutter Plugin
- **Geocoding**: Geocoding API
- **Location**: Geolocator

## 📋 Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Firebase account
- Google Maps API key
- Android Studio / VS Code
- Git

## 🚀 Getting Started

### 1. Clone the repository
```bash
git clone https://github.com/yourusername/muni-report-pro.git
cd muni-report-pro
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Firebase Setup

#### a. Create a Firebase project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable the following services:
   - Authentication (Email/Password, Google Sign-In)
   - Cloud Firestore
   - Firebase Storage
   - Cloud Messaging
   - Analytics
   - Crashlytics

#### b. Configure Firebase for Android
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

#### c. Set up Firestore Security Rules
Copy the security rules from the blueprint document to your Firestore console.

#### d. Create Firestore Indexes
Create the following composite indexes in Firestore:
- `users`: role (ASC), points (DESC)
- `issues`: status (ASC), createdAt (DESC)
- `issues`: ward (ASC), status (ASC), createdAt (DESC)
- `ideas`: status (ASC), voteCount (DESC)
- `votes`: userId (ASC), ideaId (ASC) [unique]

### 4. Google Maps Setup

#### a. Get API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Enable Maps SDK for Android/iOS
3. Create API key

#### b. Configure Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

#### c. Configure iOS
Add to `ios/Runner/AppDelegate.swift`:
```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

### 5. Environment Configuration

Update `lib/core/config/env.dart` with your credentials:
```dart
static const String firebaseApiKey = 'YOUR_FIREBASE_API_KEY';
static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
// ... other configurations
```

### 6. Run the app
```bash
# Run on Android
flutter run

# Run on iOS
flutter run -d ios

# Run in release mode
flutter run --release
```

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test

# Run with coverage
flutter test --coverage
```

## 📦 Building

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🔧 Configuration

### Points System
Configure point values in Firestore `/app_settings`:
- `points_per_verified_report`: 10
- `points_per_verification`: 5
- `points_per_vote`: 2
- `min_verifications_for_priority`: 3

### Municipalities and Wards
Update the lists in `profile_setup_page.dart` or fetch from Firestore.

## 📱 Features Implementation Status

- [x] Project Setup & Configuration
- [x] Authentication (Email/Password)
- [x] User Profile Management
- [ ] Issue Reporting
- [ ] Issue Tracking & Management
- [ ] Community Verification
- [ ] Ideas & Voting
- [ ] Interactive Map
- [ ] Announcements
- [ ] Push Notifications
- [ ] Gamification System
- [ ] Admin Dashboard
- [ ] Analytics

## 🔐 Security

- Firebase Security Rules enforce role-based access
- User data is validated on both client and server
- Sensitive operations require authentication
- API keys should be stored securely (use environment variables in production)

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 Support

For support, email support@munireportpro.co.za or open an issue on GitHub.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend infrastructure
- South African municipalities for inspiration

---

**Built with ❤️ for South African communities**
