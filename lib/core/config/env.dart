/// Environment configuration for the application
class Env {
  // Firebase Configuration
  // Android API Key
  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyC-XetP_mI7-tTetQVNQw4UKt1nk_3pbWM',
  );
  
  // iOS API Key
  static const String firebaseApiKeyIOS = String.fromEnvironment(
    'FIREBASE_API_KEY_IOS',
    defaultValue: 'AIzaSyB4j3vqk5xKYNVPwnp14Ytd8oLm8i1kor0',
  );
  
  // Android App ID
  static const String firebaseAppId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '1:484619171421:android:28c176a4bce78830783fb4',
  );
  
  // iOS App ID
  static const String firebaseAppIdIOS = String.fromEnvironment(
    'FIREBASE_APP_ID_IOS',
    defaultValue: '1:484619171421:ios:a67cd3fa92253ebc783fb4',
  );
  
  static const String firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '484619171421',
  );
  
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'muni-report-pro',
  );
  
  static const String firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'muni-report-pro.firebasestorage.app',
  );
  
  // Google Maps API Key
  // TODO: Replace with your actual Google Maps API key
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'AIzaSyCBhYA1g0dEdw6VfjsVKsDUbrhop84MpfY', // <-- PUT YOUR KEY HERE
  );
  
  // App Configuration
  static const String appName = 'Muni-Report Pro';
  static const String appVersion = '1.0.0';
  
  // Feature Flags
  static const bool enableMessaging = false; // For MVP
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  
  // API Endpoints (if needed)
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.munireportpro.co.za',
  );
  
  // Validation
  static bool get isProduction => 
      firebaseApiKey != 'AIzaSyC-XetP_mI7-tTetQVNQw4UKt1nk_3pbWM';
}
