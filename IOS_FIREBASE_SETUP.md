# Firebase iOS Setup - Complete ✅

## What Has Been Configured

### ✅ 1. iOS AppDelegate Updated
- ✅ Added `import FirebaseCore`
- ✅ Added `FirebaseApp.configure()` in `didFinishLaunchingWithOptions`

### ✅ 2. Info.plist Updated
Added required permissions:
- ✅ Location (When In Use & Always)
- ✅ Camera
- ✅ Photo Library (Read & Write)
- ✅ Background Modes (Remote Notifications)

### ✅ 3. Environment Configuration
Updated `lib/core/config/env.dart` with iOS values:
- ✅ iOS API Key: `AIzaSyB4j3vqk5xKYNVPwnp14Ytd8oLm8i1kor0`
- ✅ iOS App ID: `1:484619171421:ios:a67cd3fa92253ebc783fb4`
- ✅ Bundle ID: `za.co.munireport.muniReportPro`

### ✅ 4. Firebase Config Updated
- ✅ Updated `firebase_config.dart` to use iOS-specific values

---

## 🚨 CRITICAL: Manual Steps Required

### Step 1: Place GoogleService-Info.plist File

**Location**: `ios/Runner/GoogleService-Info.plist`

**Action Required**:
1. Copy your `GoogleService-Info.plist` file
2. Paste it into: `ios/Runner/` directory
3. Full path: `c:\Users\mfune\Desktop\Muni-Report-Pro\ios\Runner\GoogleService-Info.plist`

**Your GoogleService-Info.plist content**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CLIENT_ID</key>
    <string>484619171421-d39tj8q65o1q3tarc8d67m8ecfmpi1m9.apps.googleusercontent.com</string>
    <key>REVERSED_CLIENT_ID</key>
    <string>com.googleusercontent.apps.484619171421-d39tj8q65o1q3tarc8d67m8ecfmpi1m9</string>
    <key>API_KEY</key>
    <string>AIzaSyB4j3vqk5xKYNVPwnp14Ytd8oLm8i1kor0</string>
    <key>GCM_SENDER_ID</key>
    <string>484619171421</string>
    <key>PLIST_VERSION</key>
    <string>1</string>
    <key>BUNDLE_ID</key>
    <string>za.co.munireport.muniReportPro</string>
    <key>PROJECT_ID</key>
    <string>muni-report-pro</string>
    <key>STORAGE_BUCKET</key>
    <string>muni-report-pro.firebasestorage.app</string>
    <key>IS_ADS_ENABLED</key>
    <false></false>
    <key>IS_ANALYTICS_ENABLED</key>
    <false></false>
    <key>IS_APPINVITE_ENABLED</key>
    <true></true>
    <key>IS_GCM_ENABLED</key>
    <true></true>
    <key>IS_SIGNIN_ENABLED</key>
    <true></true>
    <key>GOOGLE_APP_ID</key>
    <string>1:484619171421:ios:a67cd3fa92253ebc783fb4</string>
</dict>
</plist>
```

### Step 2: Add Firebase SDK via Xcode

**Important**: You need to add Firebase packages in Xcode:

1. **Open Xcode**:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Add Firebase SDK**:
   - In Xcode, go to: **File > Add Packages**
   - Enter URL: `https://github.com/firebase/firebase-ios-sdk`
   - Select version: **Latest** (recommended)

3. **Select Firebase Products**:
   Select these packages:
   - ✅ FirebaseAnalytics
   - ✅ FirebaseAuth
   - ✅ FirebaseFirestore
   - ✅ FirebaseStorage
   - ✅ FirebaseMessaging
   - ✅ FirebaseCrashlytics

4. **Click Finish** and wait for Xcode to download dependencies

---

## 📋 Quick Setup Steps

### 1. Place GoogleService-Info.plist
```bash
# Copy the plist file to: ios/Runner/GoogleService-Info.plist
```

### 2. Open in Xcode and Add Firebase Packages
```bash
# Open the workspace (NOT the .xcodeproj)
open ios/Runner.xcworkspace
```

### 3. Clean and Run
```bash
flutter clean
flutter pub get
flutter run
```

---

## 🔍 Verification Checklist

Before running on iOS:

- [ ] `GoogleService-Info.plist` is in `ios/Runner/` directory
- [ ] Bundle ID in plist matches: `za.co.munireport.muniReportPro`
- [ ] Firebase packages added via Xcode Swift Package Manager
- [ ] AppDelegate has `FirebaseApp.configure()`
- [ ] Info.plist has required permissions
- [ ] Opened `Runner.xcworkspace` (not `Runner.xcodeproj`)

---

## 🐛 Troubleshooting

### Error: "GoogleService-Info.plist not found"
**Solution**: Place the file in `ios/Runner/GoogleService-Info.plist`

### Error: "No such module 'FirebaseCore'"
**Solution**: 
1. Open `ios/Runner.xcworkspace` in Xcode
2. Add Firebase packages via Swift Package Manager
3. Clean build folder: Product > Clean Build Folder
4. Run again

### Error: "Bundle identifier mismatch"
**Solution**: Verify bundle ID is `za.co.munireport.muniReportPro` in:
- `GoogleService-Info.plist`
- Xcode project settings

### Error: "CocoaPods related errors"
**Solution**: 
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

---

## 📱 Permissions Explained

### Location Permission
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Muni-Report Pro needs your location to tag issues...</string>
```
**Used for**: GPS tagging of issues and ideas

### Camera Permission
```xml
<key>NSCameraUsageDescription</key>
<string>Muni-Report Pro needs access to your camera...</string>
```
**Used for**: Taking photos of municipal issues

### Photo Library Permission
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Muni-Report Pro needs access to your photo library...</string>
```
**Used for**: Selecting existing photos for issue reports

### Background Notifications
```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```
**Used for**: Receiving push notifications when app is in background

---

## 🔐 Security Notes

### Bundle ID
- iOS Bundle ID: `za.co.munireport.muniReportPro`
- Android Package: `za.co.munireport.muni_report_pro`
- Note: iOS uses camelCase, Android uses snake_case

### API Keys
- iOS and Android have **different API keys**
- Both are configured in `env.dart`
- Both are safe to commit (protected by Firebase Security Rules)

### Sensitive Files (DO NOT COMMIT)
- ❌ `GoogleService-Info.plist` - Contains project configuration
- ❌ `google-services.json` - Android equivalent

---

## 📊 Configuration Summary

| Component | Status | Location |
|-----------|--------|----------|
| AppDelegate | ✅ Updated | ios/Runner/AppDelegate.swift |
| Info.plist | ✅ Updated | ios/Runner/Info.plist |
| Environment Config | ✅ Updated | lib/core/config/env.dart |
| Firebase Config | ✅ Updated | lib/core/config/firebase_config.dart |
| GoogleService-Info.plist | ⚠️ Manual | ios/Runner/ |
| Firebase SDK Packages | ⚠️ Manual | Add via Xcode |

---

## 🎯 Next Steps

1. **Place GoogleService-Info.plist** in `ios/Runner/`
2. **Open Xcode**: `open ios/Runner.xcworkspace`
3. **Add Firebase packages** via Swift Package Manager
4. **Run**: `flutter run`

---

## 📚 Additional Resources

- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)
- [FlutterFire iOS Setup](https://firebase.flutter.dev/docs/installation/ios)
- [Swift Package Manager](https://firebase.google.com/docs/ios/swift-package-manager)

---

## ✅ Android Setup Status

Your Android setup is also complete:
- ✅ `google-services.json` placed (filename corrected)
- ✅ Build files configured
- ✅ Permissions added
- ✅ Package name correct

---

**Status**: Ready for iOS after placing plist file and adding Firebase packages! 🚀

**Last Updated**: October 24, 2025
