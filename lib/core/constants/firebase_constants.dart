/// Firestore collection names
class FirebaseCollections {
  static const String users = 'users';
  static const String issues = 'issues';
  static const String issueUpdates = 'updates';
  static const String ideas = 'ideas';
  static const String ideaComments = 'comments';
  static const String announcements = 'announcements';
  static const String votes = 'votes';
  static const String verifications = 'verifications';
  static const String pointsHistory = 'points_history';
  static const String notifications = 'notifications';
  static const String appSettings = 'app_settings';
  static const String analytics = 'analytics';
  static const String conversations = 'conversations';
  static const String messages = 'messages';
}

/// Firestore field names
class FirebaseFields {
  // Common fields
  static const String id = 'id';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String userId = 'userId';
  
  // User fields
  static const String uid = 'uid';
  static const String email = 'email';
  static const String displayName = 'displayName';
  static const String phoneNumber = 'phoneNumber';
  static const String role = 'role';
  static const String ward = 'ward';
  static const String municipality = 'municipality';
  static const String photoURL = 'photoURL';
  static const String points = 'points';
  static const String isActive = 'isActive';
  static const String notificationTokens = 'notificationTokens';
  static const String achievements = 'achievements';
  static const String lastLoginAt = 'lastLoginAt';
  
  // Issue fields
  static const String reportedBy = 'reportedBy';
  static const String reporterName = 'reporterName';
  static const String reporterPhoto = 'reporterPhoto';
  static const String title = 'title';
  static const String description = 'description';
  static const String category = 'category';
  static const String severity = 'severity';
  static const String status = 'status';
  static const String location = 'location';
  static const String locationName = 'locationName';
  static const String photos = 'photos';
  static const String verifications = 'verifications';
  static const String verificationCount = 'verificationCount';
  static const String assignedTo = 'assignedTo';
  static const String assignedDepartment = 'assignedDepartment';
  static const String resolvedAt = 'resolvedAt';
  
  // Issue update fields
  static const String createdBy = 'createdBy';
  static const String creatorName = 'creatorName';
  static const String creatorRole = 'creatorRole';
  static const String message = 'message';
  static const String previousStatus = 'previousStatus';
  static const String newStatus = 'newStatus';
  static const String timestamp = 'timestamp';
  static const String isPublic = 'isPublic';
  
  // Idea fields
  static const String creatorPhoto = 'creatorPhoto';
  static const String budget = 'budget';
  static const String voteCount = 'voteCount';
  static const String voters = 'voters';
  static const String commentCount = 'commentCount';
  static const String implementationTimeline = 'implementationTimeline';
  static const String officialResponse = 'officialResponse';
  static const String respondedBy = 'respondedBy';
  static const String respondedAt = 'respondedAt';
  
  // Comment fields
  static const String userName = 'userName';
  static const String userPhoto = 'userPhoto';
  static const String comment = 'comment';
  static const String likes = 'likes';
  static const String likedBy = 'likedBy';
  
  // Announcement fields
  static const String type = 'type';
  static const String targetAudience = 'targetAudience';
  static const String priority = 'priority';
  static const String expiresAt = 'expiresAt';
  static const String readBy = 'readBy';
  static const String reachCount = 'reachCount';
  
  // Vote fields
  static const String ideaId = 'ideaId';
  
  // Verification fields
  static const String issueId = 'issueId';
  
  // Points history fields
  static const String action = 'action';
  static const String relatedId = 'relatedId';
  
  // Notification fields
  static const String relatedType = 'relatedType';
  static const String isRead = 'isRead';
  
  // App settings fields
  static const String key = 'key';
  static const String value = 'value';
}

/// Firebase Storage paths
class FirebaseStoragePaths {
  static const String issues = 'issues';
  static const String ideas = 'ideas';
  static const String profiles = 'profiles';
  static const String announcements = 'announcements';
  
  static String issuePhoto(String issueId, String fileName) =>
      '$issues/$issueId/$fileName';
  
  static String ideaPhoto(String ideaId, String fileName) =>
      '$ideas/$ideaId/$fileName';
  
  static String profilePhoto(String userId, String fileName) =>
      '$profiles/$userId/$fileName';
  
  static String announcementPhoto(String announcementId, String fileName) =>
      '$announcements/$announcementId/$fileName';
}

/// Point action types
class PointActions {
  static const String reportVerified = 'report_verified';
  static const String verifiedIssue = 'verified_issue';
  static const String ideaCreated = 'idea_created';
  static const String voteCast = 'vote_cast';
  static const String ideaMilestone25 = 'idea_milestone_25';
  static const String ideaMilestone50 = 'idea_milestone_50';
  static const String ideaMilestone100 = 'idea_milestone_100';
  static const String ideaApproved = 'idea_approved';
}

/// Notification types
class NotificationTypes {
  static const String statusUpdate = 'status_update';
  static const String verification = 'verification';
  static const String ideaResponse = 'idea_response';
  static const String announcement = 'announcement';
  static const String comment = 'comment';
  static const String achievement = 'achievement';
  static const String message = 'message';
}
