import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';

/// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Service for handling push notifications
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  String? _fcmToken;
  String? get fcmToken => _fcmToken;
  
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  /// Initialize notification service
  Future<void> initialize() async {
    try {
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted notification permission');
        
        // Get FCM token
        _fcmToken = await _messaging.getToken();
        debugPrint('FCM Token: $_fcmToken');
        
        // Save token to Firestore
        if (_fcmToken != null) {
          await _saveTokenToFirestore(_fcmToken!);
        }
        
        // Listen for token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          debugPrint('FCM Token refreshed: $newToken');
          _saveTokenToFirestore(newToken);
        });
        
        // Configure foreground notification presentation
        await _messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
        
        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        
        // Handle background messages
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
        
        // Handle notification tap when app is terminated
        final initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          _handleNotificationTap(initialMessage);
        }
      } else {
        debugPrint('User declined notification permission');
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }
  
  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }
  
  /// Save FCM token to Firestore
  Future<void> _saveTokenToFirestore(String token) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'notificationTokens': FieldValue.arrayUnion([token]),
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
        debugPrint('FCM token saved to Firestore');
      }
    } catch (e) {
      debugPrint('Error saving token to Firestore: $e');
    }
  }
  
  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message received: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');
    
    // Show local notification
    await _showLocalNotification(message);
    
    // Save to Firestore notifications collection
    await _saveNotificationToFirestore(message);
  }
  
  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'muni_report_channel',
      'Muni Report Notifications',
      channelDescription: 'Notifications for Muni Report Pro',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Muni Report Pro',
      message.notification?.body ?? '',
      notificationDetails,
      payload: message.data.toString(),
    );
  }
  
  /// Save notification to Firestore
  Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId,
        'type': message.data['type'] ?? 'general',
        'title': message.notification?.title ?? '',
        'message': message.notification?.body ?? '',
        'relatedType': message.data['relatedType'],
        'relatedId': message.data['relatedId'],
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving notification to Firestore: $e');
    }
  }
  
  /// Handle notification tap from local notification
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');
    // Navigation will be handled by the payload data
  }
  
  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    debugPrint('Data: ${message.data}');
    
    // Navigate to relevant screen based on notification type
    final type = message.data['type'];
    final relatedId = message.data['relatedId'];
    final relatedType = message.data['relatedType'];
    
    // Use a delay to ensure the app is fully initialized
    Future.delayed(const Duration(milliseconds: 500), () {
      final context = navigatorKey.currentContext;
      if (context == null) return;
      
      switch (type) {
        case 'status_update':
        case 'verification_milestone':
          if (relatedId != null) {
            // Navigate to issue detail
            context.push('/issue/$relatedId');
          }
          break;
        case 'idea_milestone':
        case 'idea_response':
          if (relatedId != null) {
            // Navigate to idea detail
            context.push('/idea/$relatedId');
          }
          break;
        case 'announcement':
          // Navigate to announcements
          context.push('/announcements');
          break;
        case 'comment':
          if (relatedType == 'issue' && relatedId != null) {
            context.push('/issue/$relatedId');
          } else if (relatedType == 'idea' && relatedId != null) {
            context.push('/idea/$relatedId');
          }
          break;
        default:
          // Navigate to notifications center
          context.push('/notifications');
          break;
      }
    });
  }
  
  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }
  
  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }
  
  /// Subscribe to ward notifications
  Future<void> subscribeToWard(String ward) async {
    await subscribeToTopic('ward_$ward');
  }
  
  /// Unsubscribe from ward notifications
  Future<void> unsubscribeFromWard(String ward) async {
    await unsubscribeFromTopic('ward_$ward');
  }
  
  /// Subscribe to municipality notifications
  Future<void> subscribeToMunicipality(String municipality) async {
    await subscribeToTopic('municipality_${municipality.toLowerCase().replaceAll(' ', '_')}');
  }
  
  /// Unsubscribe from municipality notifications
  Future<void> unsubscribeFromMunicipality(String municipality) async {
    await unsubscribeFromTopic('municipality_${municipality.toLowerCase().replaceAll(' ', '_')}');
  }
  
  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _fcmToken = null;
      debugPrint('FCM token deleted');
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');
  // Handle background message
}
