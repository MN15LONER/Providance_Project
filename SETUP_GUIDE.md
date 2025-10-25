# Muni-Report Pro - Complete Setup Guide

This guide will walk you through setting up the Muni-Report Pro application from scratch.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Flutter Setup](#flutter-setup)
3. [Firebase Configuration](#firebase-configuration)
4. [Google Maps Setup](#google-maps-setup)
5. [Project Configuration](#project-configuration)
6. [Running the App](#running-the-app)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software
- **Flutter SDK** (3.0.0 or higher)
- **Dart SDK** (3.0.0 or higher)
- **Android Studio** or **VS Code**
- **Git**
- **Node.js** (for Firebase Cloud Functions - optional for MVP)

### Required Accounts
- Google/Firebase account
- Google Cloud Platform account (for Maps API)

### System Requirements
- **Windows**: Windows 10 or later
- **macOS**: macOS 10.14 or later
- **Linux**: 64-bit distribution

---

## Flutter Setup

### 1. Install Flutter

#### Windows
```bash
# Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
# Extract to C:\src\flutter
# Add to PATH: C:\src\flutter\bin

# Verify installation
flutter doctor
```

#### macOS/Linux
```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH (add to ~/.bashrc or ~/.zshrc)
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

### 2. Install Dependencies

```bash
# Accept Android licenses
flutter doctor --android-licenses

# Install required tools
flutter doctor
```

### 3. Setup IDE

#### VS Code
```bash
# Install Flutter extension
code --install-extension Dart-Code.flutter
```

#### Android Studio
- Install Flutter plugin from Settings > Plugins

---

## Firebase Configuration

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `muni-report-pro`
4. Enable Google Analytics (recommended)
5. Click "Create project"

### 2. Enable Firebase Services

#### Authentication
1. Go to **Authentication** > **Sign-in method**
2. Enable **Email/Password**
3. Enable **Google** (optional)

#### Cloud Firestore
1. Go to **Firestore Database**
2. Click **Create database**
3. Start in **production mode**
4. Choose location: `us-central` or closest to South Africa

#### Storage
1. Go to **Storage**
2. Click **Get started**
3. Use default security rules (we'll update later)

#### Cloud Messaging
1. Go to **Cloud Messaging**
2. Note down the **Server key** (for backend)

### 3. Add Firebase to Flutter App

#### Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

#### Configure Firebase
```bash
# Navigate to project directory
cd muni-report-pro

# Run FlutterFire configure
flutterfire configure

# Select your Firebase project
# Select platforms: Android, iOS
```

This will generate `firebase_options.dart` automatically.

### 4. Setup Firestore Security Rules

Go to **Firestore Database** > **Rules** and paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    function isOfficial() {
      return isAuthenticated() && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'official';
    }
    
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isOwner(userId);
      allow update: if isOwner(userId) || isOfficial();
      allow delete: if false;
    }
    
    match /issues/{issueId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isOfficial() || 
        (isAuthenticated() && resource.data.reportedBy == request.auth.uid);
      allow delete: if isOfficial();
      
      match /updates/{updateId} {
        allow read: if isAuthenticated();
        allow create: if isAuthenticated();
        allow update, delete: if false;
      }
    }
    
    match /ideas/{ideaId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isOfficial() || 
        (isAuthenticated() && resource.data.createdBy == request.auth.uid);
      allow delete: if isOfficial();
      
      match /comments/{commentId} {
        allow read: if isAuthenticated();
        allow create: if isAuthenticated();
        allow update: if isAuthenticated() && resource.data.userId == request.auth.uid;
        allow delete: if isOfficial() || 
          (isAuthenticated() && resource.data.userId == request.auth.uid);
      }
    }
    
    match /announcements/{announcementId} {
      allow read: if isAuthenticated();
      allow create, update, delete: if isOfficial();
    }
    
    match /votes/{voteId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
      allow update, delete: if false;
    }
    
    match /verifications/{verificationId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
      allow update, delete: if false;
    }
    
    match /notifications/{notificationId} {
      allow read: if isAuthenticated() && resource.data.userId == request.auth.uid;
      allow update: if isAuthenticated() && resource.data.userId == request.auth.uid;
      allow create, delete: if false;
    }
  }
}
```

### 5. Create Firestore Indexes

Go to **Firestore Database** > **Indexes** and create:

1. **users** collection
   - Fields: `role` (Ascending), `points` (Descending)

2. **issues** collection
   - Fields: `status` (Ascending), `createdAt` (Descending)
   - Fields: `ward` (Ascending), `status` (Ascending), `createdAt` (Descending)
   - Fields: `category` (Ascending), `status` (Ascending)

3. **ideas** collection
   - Fields: `status` (Ascending), `voteCount` (Descending)
   - Fields: `ward` (Ascending), `voteCount` (Descending)

4. **votes** collection
   - Fields: `userId` (Ascending), `ideaId` (Ascending)
   - Make this a **unique** index

### 6. Setup Firebase Storage Rules

Go to **Storage** > **Rules** and paste:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /issues/{issueId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.resource.size < 5 * 1024 * 1024;
    }
    
    match /ideas/{ideaId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.resource.size < 5 * 1024 * 1024;
    }
    
    match /profiles/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId 
        && request.resource.size < 2 * 1024 * 1024;
    }
  }
}
```

---

## Google Maps Setup

### 1. Enable Google Maps API

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project
3. Go to **APIs & Services** > **Library**
4. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Geocoding API
   - Places API (optional)

### 2. Create API Key

1. Go to **APIs & Services** > **Credentials**
2. Click **Create Credentials** > **API Key**
3. Copy the API key
4. Click **Restrict Key**
5. Add restrictions:
   - Application restrictions: Android apps / iOS apps
   - API restrictions: Select enabled APIs

### 3. Configure Android

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
    <application ...>
        <!-- Add before </application> -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
    </application>
</manifest>
```

### 4. Configure iOS

Edit `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

---

## Project Configuration

### 1. Update Environment Variables

Edit `lib/core/config/env.dart`:

```dart
class Env {
  static const String firebaseApiKey = 'YOUR_FIREBASE_API_KEY';
  static const String firebaseAppId = 'YOUR_FIREBASE_APP_ID';
  static const String firebaseMessagingSenderId = 'YOUR_SENDER_ID';
  static const String firebaseProjectId = 'muni-report-pro';
  static const String firebaseStorageBucket = 'muni-report-pro.appspot.com';
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
}
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Code (if using code generation)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Running the App

### 1. Check Setup

```bash
flutter doctor -v
```

### 2. Run on Android

```bash
# List devices
flutter devices

# Run on connected device
flutter run

# Run in release mode
flutter run --release
```

### 3. Run on iOS

```bash
# Open iOS simulator
open -a Simulator

# Run app
flutter run -d ios
```

### 4. Hot Reload

While app is running:
- Press `r` for hot reload
- Press `R` for hot restart
- Press `q` to quit

---

## Troubleshooting

### Common Issues

#### 1. Firebase Configuration Error
```
Error: Firebase configuration not found
```
**Solution**: Run `flutterfire configure` again

#### 2. Google Maps Not Showing
```
Error: API key not found
```
**Solution**: 
- Check API key in AndroidManifest.xml / AppDelegate.swift
- Verify API is enabled in Google Cloud Console
- Check API key restrictions

#### 3. Build Errors
```
Error: Gradle build failed
```
**Solution**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

#### 4. iOS Pod Install Issues
```
Error: CocoaPods not installed
```
**Solution**:
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
flutter run
```

### Getting Help

- Check [Flutter Documentation](https://flutter.dev/docs)
- Check [Firebase Documentation](https://firebase.google.com/docs)
- Open an issue on GitHub
- Contact support@munireportpro.co.za

---

## Next Steps

After successful setup:

1. Create test user accounts (citizen and official)
2. Test authentication flow
3. Configure municipalities and wards data
4. Set up Cloud Functions (for production)
5. Configure push notifications
6. Test on physical devices
7. Prepare for deployment

---

**Setup Complete! 🎉**

You're now ready to start developing Muni-Report Pro!
