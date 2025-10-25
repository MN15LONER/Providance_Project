/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Muni-Report Pro';
  static const String appTagline = 'Building Better Communities Together';
  
  // Validation
  static const int minPasswordLength = 8;
  static const int minDescriptionLength = 20;
  static const int maxDescriptionLength = 500;
  static const int maxTitleLength = 100;
  static const int maxPhotos = 5;
  static const int maxImageSizeMB = 1;
  
  // Pagination
  static const int itemsPerPage = 20;
  static const int messagesPerPage = 50;
  
  // Location
  static const double verificationRadiusKm = 10.0;
  static const double mapBufferRadius = 2.0; // km
  static const int locationUpdateIntervalSeconds = 30;
  
  // Points System
  static const int pointsReportVerified = 10;
  static const int pointsVerifyIssue = 5;
  static const int pointsVoteOnIdea = 2;
  static const int pointsIdeaCreated = 5;
  static const int pointsIdeaMilestone25 = 25;
  static const int pointsIdeaMilestone50 = 50;
  static const int pointsIdeaMilestone100 = 100;
  static const int pointsIdeaApproved = 50;
  
  // Verification
  static const int minVerificationsForPriority = 3;
  static const int verificationExpiryDays = 30;
  
  // Rate Limits
  static const int maxMessagesPerMinute = 10;
  static const int maxReportsPerDay = 10;
  static const int maxPointsPerDayPerAction = 100;
  
  // Cache Duration
  static const int cacheExpiryHours = 1;
  static const int analyticsRefreshMinutes = 60;
  
  // Timeouts
  static const int apiTimeoutSeconds = 30;
  static const int uploadTimeoutSeconds = 60;
  
  // Notification Channels
  static const String notificationChannelId = 'muni_report_pro_notifications';
  static const String notificationChannelName = 'Muni-Report Pro';
  static const String notificationChannelDescription = 'Notifications for issue updates and announcements';
  
  // Storage Paths
  static const String issuePhotosPath = 'issues';
  static const String ideaPhotosPath = 'ideas';
  static const String profilePhotosPath = 'profiles';
  
  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy, HH:mm';
  static const String timeFormat = 'HH:mm';
  
  // Support
  static const String supportEmail = 'support@munireportpro.co.za';
  static const String supportPhone = '+27 11 123 4567';
  static const String websiteUrl = 'https://munireportpro.co.za';
  static const String privacyPolicyUrl = 'https://munireportpro.co.za/privacy';
  static const String termsOfServiceUrl = 'https://munireportpro.co.za/terms';
  
  // Quick access lists
  static const List<String> issueCategories = IssueCategories.all;
  static const List<String> severityLevels = IssueSeverity.all;
  static const List<String> ideaCategories = IdeaCategories.all;
}

/// Issue categories
class IssueCategories {
  static const String potholes = 'potholes';
  static const String water = 'water';
  static const String electricity = 'electricity';
  static const String waste = 'waste';
  static const String safety = 'safety';
  static const String infrastructure = 'infrastructure';
  
  static const List<String> all = [
    potholes,
    water,
    electricity,
    waste,
    safety,
    infrastructure,
  ];
  
  static String getDisplayName(String category) {
    switch (category) {
      case potholes:
        return 'Potholes & Roads';
      case water:
        return 'Water & Sanitation';
      case electricity:
        return 'Electricity';
      case waste:
        return 'Waste Management';
      case safety:
        return 'Public Safety';
      case infrastructure:
        return 'Infrastructure';
      default:
        return category;
    }
  }
  
  static String getIcon(String category) {
    switch (category) {
      case potholes:
        return '🚧';
      case water:
        return '💧';
      case electricity:
        return '⚡';
      case waste:
        return '🗑️';
      case safety:
        return '🚨';
      case infrastructure:
        return '🏗️';
      default:
        return '📋';
    }
  }
}

/// Issue severity levels
class IssueSeverity {
  static const String low = 'low';
  static const String medium = 'medium';
  static const String high = 'high';
  
  static const List<String> all = [low, medium, high];
  
  static String getDisplayName(String severity) {
    switch (severity) {
      case low:
        return 'Low Priority';
      case medium:
        return 'Medium Priority';
      case high:
        return 'High Priority';
      default:
        return severity;
    }
  }
}

/// Issue status
class IssueStatus {
  static const String pending = 'pending';
  static const String verified = 'verified';
  static const String inProgress = 'in_progress';
  static const String resolved = 'resolved';
  static const String rejected = 'rejected';
  
  static const List<String> all = [
    pending,
    verified,
    inProgress,
    resolved,
    rejected,
  ];
  
  static String getDisplayName(String status) {
    switch (status) {
      case pending:
        return 'Pending';
      case verified:
        return 'Verified';
      case inProgress:
        return 'In Progress';
      case resolved:
        return 'Resolved';
      case rejected:
        return 'Rejected';
      default:
        return status;
    }
  }
}

/// Idea categories
class IdeaCategories {
  static const String safety = 'safety';
  static const String infrastructure = 'infrastructure';
  static const String parksRecreation = 'parks_recreation';
  static const String utilities = 'utilities';
  static const String education = 'education';
  static const String health = 'health';
  
  static const List<String> all = [
    safety,
    infrastructure,
    parksRecreation,
    utilities,
    education,
    health,
  ];
  
  static String getDisplayName(String category) {
    switch (category) {
      case safety:
        return 'Public Safety';
      case infrastructure:
        return 'Infrastructure';
      case parksRecreation:
        return 'Parks & Recreation';
      case utilities:
        return 'Utilities';
      case education:
        return 'Education';
      case health:
        return 'Health';
      default:
        return category;
    }
  }
}

/// Idea budget ranges
class IdeaBudget {
  static const String under50k = '<50k';
  static const String between50k200k = '50k-200k';
  static const String over200k = '>200k';
  
  static const List<String> all = [
    under50k,
    between50k200k,
    over200k,
  ];
  
  static String getDisplayName(String budget) {
    switch (budget) {
      case under50k:
        return 'Under R50,000';
      case between50k200k:
        return 'R50,000 - R200,000';
      case over200k:
        return 'Over R200,000';
      default:
        return budget;
    }
  }
}

/// Idea status
class IdeaStatus {
  static const String open = 'open';
  static const String underReview = 'under_review';
  static const String approved = 'approved';
  static const String declined = 'declined';
  static const String implemented = 'implemented';
  
  static const List<String> all = [
    open,
    underReview,
    approved,
    declined,
    implemented,
  ];
  
  static String getDisplayName(String status) {
    switch (status) {
      case open:
        return 'Open for Voting';
      case underReview:
        return 'Under Review';
      case approved:
        return 'Approved';
      case declined:
        return 'Declined';
      case implemented:
        return 'Implemented';
      default:
        return status;
    }
  }
}

/// User roles
class UserRole {
  static const String citizen = 'citizen';
  static const String official = 'official';
  
  static const List<String> all = [citizen, official];
}

/// Announcement types
class AnnouncementType {
  static const String announcement = 'announcement';
  static const String alert = 'alert';
  static const String event = 'event';
  static const String maintenance = 'maintenance';
  
  static const List<String> all = [
    announcement,
    alert,
    event,
    maintenance,
  ];
}

/// Announcement priority
class AnnouncementPriority {
  static const String normal = 'normal';
  static const String high = 'high';
  static const String urgent = 'urgent';
  
  static const List<String> all = [normal, high, urgent];
}
