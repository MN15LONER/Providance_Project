# 🗺️ Google Maps API Key Setup Guide

## Overview
Your app needs a Google Maps API key for location services, geocoding, and map display features.

---

## ✅ What You Need to Do

### **You need to add your Google Maps API key in 3 places:**

---

## 📍 Location 1: Flutter Code (env.dart)

**File**: `lib/core/config/env.dart`

**Line 47**: Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual key

```dart
// Google Maps API Key
// TODO: Replace with your actual Google Maps API key
static const String googleMapsApiKey = String.fromEnvironment(
  'GOOGLE_MAPS_API_KEY',
  defaultValue: 'YOUR_GOOGLE_MAPS_API_KEY', // <-- PUT YOUR KEY HERE
);
```

**Example**:
```dart
defaultValue: 'AIzaSyBXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
```

---

## 📍 Location 2: Android Manifest

**File**: `android/app/src/main/AndroidManifest.xml`

**Line 52**: Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual key

```xml
<!-- Google Maps API Key -->
<!-- TODO: Replace with your actual Google Maps API key -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

**Example**:
```xml
android:value="AIzaSyBXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"/>
```

---

## 📍 Location 3: iOS Info.plist

**File**: `ios/Runner/Info.plist`

**Line 74**: Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual key

```xml
<!-- Google Maps API Key -->
<!-- TODO: Replace with your actual Google Maps API key -->
<key>GMSApiKey</key>
<string>YOUR_GOOGLE_MAPS_API_KEY</string>
```

**Example**:
```xml
<string>AIzaSyBXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX</string>
```

---

## 🔑 How to Get a Google Maps API Key

If you don't have a key yet:

### 1. Go to Google Cloud Console
https://console.cloud.google.com/

### 2. Create/Select Project
- Create a new project or select "muni-report-pro"

### 3. Enable APIs
Enable these APIs:
- ✅ **Maps SDK for Android**
- ✅ **Maps SDK for iOS**
- ✅ **Geocoding API** (for address lookup)
- ✅ **Geolocation API** (optional)

### 4. Create API Key
1. Go to **APIs & Services > Credentials**
2. Click **Create Credentials > API Key**
3. Copy the generated key

### 5. Restrict the API Key (Recommended)

#### For Android:
- Application restrictions: **Android apps**
- Add package name: `za.co.munireport.muni_report_pro`
- Add SHA-1 fingerprint (get with: `keytool -list -v -keystore ~/.android/debug.keystore`)

#### For iOS:
- Application restrictions: **iOS apps**
- Add bundle ID: `za.co.munireport.muniReportPro`

#### API restrictions:
- Restrict key to:
  - Maps SDK for Android
  - Maps SDK for iOS
  - Geocoding API

---

## 🧪 Test After Adding Key

### Test Geocoding:
```bash
flutter run
# Then in app:
1. Go to "Report Issue"
2. Tap "Get Current Location"
3. Should show your address ✅
```

### Test Map View (when implemented):
- Map should load with markers
- No "For development purposes only" watermark

---

## ⚠️ Important Notes

### Security:
- ✅ **Safe to commit**: The keys in code are restricted by package name/bundle ID
- ✅ **Restrict your key**: Always add application restrictions in Google Cloud Console
- ❌ **Don't share**: Don't share unrestricted keys publicly

### Billing:
- Google Maps has a **free tier**: $200 credit per month
- Geocoding: First 40,000 requests/month are free
- Your app usage should stay within free tier

### Current Usage:
Your app uses Google Maps for:
1. ✅ **Geocoding** - Converting GPS coordinates to addresses (in Report Issue)
2. 🚧 **Map Display** - Showing issues on map (Phase 6 - not yet implemented)
3. 🚧 **Reverse Geocoding** - Address search (future feature)

---

## 🔍 Troubleshooting

### Error: "API key not found"
- ✅ Check all 3 files have the same key
- ✅ Rebuild app: `flutter clean && flutter run`

### Error: "This API key is not authorized"
- ✅ Enable required APIs in Google Cloud Console
- ✅ Check package name matches: `za.co.munireport.muni_report_pro`
- ✅ Check bundle ID matches: `za.co.munireport.muniReportPro`

### Geocoding not working:
- ✅ Enable "Geocoding API" in Google Cloud Console
- ✅ Check internet permission in AndroidManifest
- ✅ Check location permissions granted

### Map shows "For development purposes only":
- ✅ Add billing account to Google Cloud project
- ✅ Enable Maps SDK for Android/iOS

---

## ✅ Quick Checklist

Before running the app:
- [ ] Added API key to `lib/core/config/env.dart`
- [ ] Added API key to `android/app/src/main/AndroidManifest.xml`
- [ ] Added API key to `ios/Runner/Info.plist`
- [ ] Enabled required APIs in Google Cloud Console
- [ ] (Optional) Restricted API key for security
- [ ] Run `flutter clean && flutter pub get`

---

## 📊 Current Status

### What Works Now (with API key):
- ✅ GPS location capture
- ✅ Geocoding (coordinates → address)
- ✅ Location display in Report Issue page

### What Needs API Key (Future):
- 🚧 Map view with markers (Phase 6)
- 🚧 Interactive map navigation
- 🚧 Address search/autocomplete

---

**After adding your key, the location features in Report Issue will work perfectly!** 🎉
