# Muni-Report Pro - Quick Start Guide

Get up and running with Muni-Report Pro in 10 minutes!

## Prerequisites Checklist

- [ ] Flutter SDK installed (3.0.0+)
- [ ] Firebase account created
- [ ] Google Maps API key obtained
- [ ] IDE installed (VS Code or Android Studio)

## Quick Setup Steps

### 1. Clone and Install (2 minutes)

```bash
# Clone the repository
git clone https://github.com/yourusername/muni-report-pro.git
cd muni-report-pro

# Install dependencies
flutter pub get
```

### 2. Firebase Setup (3 minutes)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (follow prompts)
flutterfire configure
```

**What this does:**
- Creates Firebase project connection
- Generates `firebase_options.dart`
- Configures Android and iOS apps

### 3. Configure API Keys (2 minutes)

#### Update Environment Variables
Edit `lib/core/config/env.dart`:

```dart
static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
```

#### Add to Android
Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

### 4. Enable Firebase Services (2 minutes)

In Firebase Console:

1. **Authentication** → Enable Email/Password
2. **Firestore** → Create database (production mode)
3. **Storage** → Get started
4. **Cloud Messaging** → Enabled by default

### 5. Run the App (1 minute)

```bash
# Check everything is ready
flutter doctor

# Run on connected device
flutter run
```

## First Time User Flow

### As a Citizen:

1. **Sign Up**
   - Tap "Sign Up"
   - Enter name, email, password
   - Select "Citizen" role
   - Choose municipality and ward
   - Complete!

2. **Report an Issue**
   - Tap "Report Issue" on home
   - Select category
   - Take photos
   - Add description
   - Submit

3. **Earn Points**
   - Verify other issues
   - Vote on ideas
   - Climb the leaderboard

### As an Official:

1. **Sign Up**
   - Same as citizen
   - Select "Government Official" role
   - Choose your ward

2. **Manage Issues**
   - View all ward issues
   - Update status
   - Assign to departments
   - Respond to citizens

3. **Post Announcements**
   - Create announcements
   - Target specific wards
   - Set priority levels

## Testing Credentials

For development/testing, create test accounts:

```
Citizen Account:
Email: citizen@test.com
Password: Test1234

Official Account:
Email: official@test.com
Password: Test1234
```

## Common Commands

```bash
# Hot reload (while app is running)
r

# Hot restart
R

# Clear cache and rebuild
flutter clean && flutter pub get && flutter run

# Build release APK
flutter build apk --release

# Run tests
flutter test

# Check for issues
flutter analyze
```

## Troubleshooting Quick Fixes

### App won't build?
```bash
flutter clean
flutter pub get
flutter run
```

### Firebase errors?
```bash
flutterfire configure
```

### Map not showing?
- Check API key in AndroidManifest.xml
- Verify Maps SDK is enabled in Google Cloud Console

### Hot reload not working?
- Press `R` for full restart
- Stop and run again

## Project Structure Overview

```
lib/
├── core/                   # Core functionality
│   ├── config/            # Configuration
│   ├── constants/         # Constants
│   ├── theme/             # Styling
│   └── services/          # Services
│
├── features/              # Features
│   ├── auth/             # Login/Signup
│   ├── issues/           # Issue reporting
│   ├── ideas/            # Community ideas
│   └── ...               # Other features
│
└── main.dart             # Entry point
```

## Key Files to Know

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point |
| `lib/app.dart` | App configuration |
| `lib/core/config/router.dart` | Navigation routes |
| `lib/core/theme/app_theme.dart` | App styling |
| `lib/features/auth/` | Authentication |
| `pubspec.yaml` | Dependencies |

## Next Steps

1. ✅ App is running
2. 📖 Read [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed setup
3. 🗺️ Check [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md) for features
4. 🔧 Start implementing features from Phase 2
5. 📝 Update documentation as you go

## Getting Help

- 📚 Check [README.md](README.md) for full documentation
- 🐛 Found a bug? Open an issue on GitHub
- 💬 Questions? Contact support@munireportpro.co.za
- 📖 Read Flutter docs: https://flutter.dev/docs

## Development Tips

### Hot Reload Best Practices
- Save files to trigger hot reload
- Use `r` for quick UI changes
- Use `R` for state changes

### Debugging
- Use `print()` statements
- Check Flutter DevTools
- Use breakpoints in IDE
- Check Firebase console logs

### Performance
- Use `const` constructors
- Implement lazy loading
- Optimize images
- Cache network requests

## What's Implemented?

✅ **Ready to Use:**
- Authentication (Login/Signup)
- User profiles
- Navigation system
- Theme and styling
- Firebase integration
- Location services
- Notification setup

🚧 **Coming Soon:**
- Issue reporting
- Ideas and voting
- Map view
- Gamification
- Admin dashboard

## Quick Reference

### Run Commands
```bash
flutter run              # Debug mode
flutter run --release    # Release mode
flutter run -d chrome    # Web
flutter run -d ios       # iOS
```

### Build Commands
```bash
flutter build apk        # Android APK
flutter build appbundle  # Android Bundle
flutter build ios        # iOS
```

### Test Commands
```bash
flutter test             # Unit tests
flutter test --coverage  # With coverage
flutter analyze          # Static analysis
```

---

**Ready to build? Let's go! 🚀**

For detailed information, see:
- [README.md](README.md) - Full documentation
- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Detailed setup
- [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md) - Feature roadmap
