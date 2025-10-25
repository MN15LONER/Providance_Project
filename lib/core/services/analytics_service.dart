import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Analytics service for tracking user behavior
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  /// Get analytics observer for navigation
  FirebaseAnalyticsObserver getAnalyticsObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }
  
  // ==================== Screen Tracking ====================
  
  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      debugPrint('Analytics: Screen view - $screenName');
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }
  
  // ==================== Authentication Events ====================
  
  /// Log sign up
  Future<void> logSignUp({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
    debugPrint('Analytics: Sign up - $method');
  }
  
  /// Log login
  Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
    debugPrint('Analytics: Login - $method');
  }
  
  /// Log logout
  Future<void> logLogout() async {
    await _analytics.logEvent(name: 'logout');
    debugPrint('Analytics: Logout');
  }
  
  // ==================== Issue Events ====================
  
  /// Log issue reported
  Future<void> logIssueReported({
    required String category,
    required String severity,
    bool hasPhotos = false,
    bool hasLocation = false,
  }) async {
    await _analytics.logEvent(
      name: 'issue_reported',
      parameters: {
        'category': category,
        'severity': severity,
        'has_photos': hasPhotos,
        'has_location': hasLocation,
      },
    );
    debugPrint('Analytics: Issue reported - $category');
  }
  
  /// Log issue verified
  Future<void> logIssueVerified({
    required String issueId,
    required String category,
  }) async {
    await _analytics.logEvent(
      name: 'issue_verified',
      parameters: {
        'issue_id': issueId,
        'category': category,
      },
    );
    debugPrint('Analytics: Issue verified - $issueId');
  }
  
  /// Log issue status changed
  Future<void> logIssueStatusChanged({
    required String issueId,
    required String oldStatus,
    required String newStatus,
  }) async {
    await _analytics.logEvent(
      name: 'issue_status_changed',
      parameters: {
        'issue_id': issueId,
        'old_status': oldStatus,
        'new_status': newStatus,
      },
    );
    debugPrint('Analytics: Issue status changed - $oldStatus to $newStatus');
  }
  
  // ==================== Idea Events ====================
  
  /// Log idea proposed
  Future<void> logIdeaProposed({
    required String category,
    required String budget,
    bool hasPhotos = false,
    bool hasLocation = false,
  }) async {
    await _analytics.logEvent(
      name: 'idea_proposed',
      parameters: {
        'category': category,
        'budget': budget,
        'has_photos': hasPhotos,
        'has_location': hasLocation,
      },
    );
    debugPrint('Analytics: Idea proposed - $category');
  }
  
  /// Log vote on idea
  Future<void> logIdeaVoted({
    required String ideaId,
    required String category,
  }) async {
    await _analytics.logEvent(
      name: 'idea_voted',
      parameters: {
        'idea_id': ideaId,
        'category': category,
      },
    );
    debugPrint('Analytics: Idea voted - $ideaId');
  }
  
  /// Log comment on idea
  Future<void> logIdeaCommented({
    required String ideaId,
    required String category,
  }) async {
    await _analytics.logEvent(
      name: 'idea_commented',
      parameters: {
        'idea_id': ideaId,
        'category': category,
      },
    );
    debugPrint('Analytics: Idea commented - $ideaId');
  }
  
  // ==================== Gamification Events ====================
  
  /// Log points earned
  Future<void> logPointsEarned({
    required int points,
    required String action,
    String? referenceType,
  }) async {
    await _analytics.logEvent(
      name: 'points_earned',
      parameters: {
        'points': points,
        'action': action,
        'reference_type': referenceType ?? 'none',
      },
    );
    debugPrint('Analytics: Points earned - $points for $action');
  }
  
  /// Log leaderboard viewed
  Future<void> logLeaderboardViewed({String? ward}) async {
    await _analytics.logEvent(
      name: 'leaderboard_viewed',
      parameters: {
        'ward': ward ?? 'global',
      },
    );
    debugPrint('Analytics: Leaderboard viewed');
  }
  
  // ==================== Notification Events ====================
  
  /// Log notification received
  Future<void> logNotificationReceived({
    required String type,
    required String source,
  }) async {
    await _analytics.logEvent(
      name: 'notification_received',
      parameters: {
        'type': type,
        'source': source,
      },
    );
    debugPrint('Analytics: Notification received - $type');
  }
  
  /// Log notification opened
  Future<void> logNotificationOpened({
    required String type,
    String? relatedType,
  }) async {
    await _analytics.logEvent(
      name: 'notification_opened',
      parameters: {
        'type': type,
        'related_type': relatedType ?? 'none',
      },
    );
    debugPrint('Analytics: Notification opened - $type');
  }
  
  // ==================== Search Events ====================
  
  /// Log search performed
  Future<void> logSearch({
    required String searchTerm,
    required String searchType,
    int? resultCount,
  }) async {
    await _analytics.logSearch(
      searchTerm: searchTerm,
      parameters: {
        'search_type': searchType,
        'result_count': resultCount ?? 0,
      },
    );
    debugPrint('Analytics: Search - $searchTerm');
  }
  
  // ==================== Share Events ====================
  
  /// Log content shared
  Future<void> logShare({
    required String contentType,
    required String contentId,
    required String method,
  }) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: contentId,
      method: method,
    );
    debugPrint('Analytics: Share - $contentType via $method');
  }
  
  // ==================== User Properties ====================
  
  /// Set user role
  Future<void> setUserRole(String role) async {
    await _analytics.setUserProperty(name: 'user_role', value: role);
    debugPrint('Analytics: User role set - $role');
  }
  
  /// Set user ward
  Future<void> setUserWard(String ward) async {
    await _analytics.setUserProperty(name: 'user_ward', value: ward);
    debugPrint('Analytics: User ward set - $ward');
  }
  
  /// Set user municipality
  Future<void> setUserMunicipality(String municipality) async {
    await _analytics.setUserProperty(name: 'user_municipality', value: municipality);
    debugPrint('Analytics: User municipality set - $municipality');
  }
  
  // ==================== Custom Events ====================
  
  /// Log custom event
  Future<void> logCustomEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
    debugPrint('Analytics: Custom event - $name');
  }
  
  // ==================== Error Tracking ====================
  
  /// Log error
  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
  }) async {
    await _analytics.logEvent(
      name: 'error_occurred',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
        'has_stack_trace': stackTrace != null,
      },
    );
    debugPrint('Analytics: Error - $errorType');
  }
}
