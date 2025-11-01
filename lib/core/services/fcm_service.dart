import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/route_constants.dart';

/// FCM Service Provider
final fcmServiceProvider = Provider<FCMService>((ref) {
  return FCMService();
});

/// Service for handling Firebase Cloud Messaging
class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  static final navigatorKey = GlobalKey<NavigatorState>();
  
  /// Android notification channel
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  /// Initialize FCM service
  Future<void> initialize() async {
    try {
      // Request permission
      await _requestPermission();
      
      // Set up local notifications
      await _setupLocalNotifications();
      
      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      
      // Handle notification tap when app was terminated
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
    } catch (e) {
      print('Error initializing FCM: $e');
    }
  }

  /// Request notification permission
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional notification permission');
    } else {
      print('User declined notification permission');
    }
  }

  /// Set up local notifications
  Future<void> _setupLocalNotifications() async {
    // Create Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Initialize settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handleLocalNotificationTap(response.payload);
      },
    );
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final androidNotification = message.notification?.android;
    
    if (notification != null && androidNotification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: androidNotification.smallIcon,
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    _handleNotificationNavigation(message.data);
  }

  /// Handle local notification tap
  void _handleLocalNotificationTap(String? payload) {
    if (payload != null) {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      _handleNotificationNavigation(data);
    }
  }

  /// Handle notification navigation
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final id = data['id'] as String?;
    
    if (type != null && id != null) {
      switch (type) {
        case 'issue':
          GoRouter.of(navigatorKey.currentContext!).push('${Routes.issueDetail}/$id');
          break;
        case 'idea':
          GoRouter.of(navigatorKey.currentContext!).push('${Routes.ideaDetail}/$id');
          break;
        case 'announcement':
          GoRouter.of(navigatorKey.currentContext!).push(Routes.announcements);
          break;
        case 'comment':
          // Determine parent type (issue or idea) and navigate accordingly
          final parentType = data['parentType'] as String?;
          final parentId = data['parentId'] as String?;
          if (parentType != null && parentId != null) {
            switch (parentType) {
              case 'issue':
                GoRouter.of(navigatorKey.currentContext!).push('${Routes.issueDetail}/$parentId');
                break;
              case 'idea':
                GoRouter.of(navigatorKey.currentContext!).push('${Routes.ideaDetail}/$parentId');
                break;
            }
          }
          break;
      }
    }
  }
}

/// Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  // No need to show local notification here as the system will show it automatically
}