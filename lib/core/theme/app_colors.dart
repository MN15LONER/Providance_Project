import 'package:flutter/material.dart';

/// Application color palette
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF1E88E5); // Blue
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF42A5F5);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF26A69A); // Teal
  static const Color secondaryDark = Color(0xFF00897B);
  static const Color secondaryLight = Color(0xFF4DB6AC);
  
  // Accent Colors
  static const Color accent = Color(0xFFFF9800); // Orange
  static const Color accentDark = Color(0xFFF57C00);
  static const Color accentLight = Color(0xFFFFB74D);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFFC107); // Amber
  static const Color error = Color(0xFFF44336); // Red
  static const Color info = Color(0xFF2196F3); // Blue
  
  // Severity Colors
  static const Color severityLow = Color(0xFF4CAF50); // Green
  static const Color severityMedium = Color(0xFFFF9800); // Orange
  static const Color severityHigh = Color(0xFFF44336); // Red
  static const Color severityCritical = Color(0xFFD32F2F); // Dark Red
  
  // Issue Status Colors
  static const Color statusPending = Color(0xFF9E9E9E); // Grey
  static const Color statusVerified = Color(0xFF2196F3); // Blue
  static const Color statusInProgress = Color(0xFFFF9800); // Orange
  static const Color statusResolved = Color(0xFF4CAF50); // Green
  static const Color statusRejected = Color(0xFFF44336); // Red
  
  // Idea Status Colors
  static const Color ideaOpen = Color(0xFF2196F3); // Blue
  static const Color ideaUnderReview = Color(0xFFFF9800); // Orange
  static const Color ideaApproved = Color(0xFF4CAF50); // Green
  static const Color ideaDeclined = Color(0xFFF44336); // Red
  static const Color ideaImplemented = Color(0xFF9C27B0); // Purple
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
  
  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  
  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);
  
  // Shadow Colors
  static const Color shadow = Color(0x1F000000);
  static const Color shadowDark = Color(0x3F000000);
  
  // Overlay Colors
  static const Color overlay = Color(0x0F000000);
  static const Color overlayDark = Color(0x1FFFFFFF);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Map Marker Colors
  static const Color markerIssue = Color(0xFFF44336); // Red
  static const Color markerIdea = Color(0xFF2196F3); // Blue
  static const Color markerResolved = Color(0xFF4CAF50); // Green
  
  // Achievement Badge Colors
  static const Color badgeBronze = Color(0xFFCD7F32);
  static const Color badgeSilver = Color(0xFFC0C0C0);
  static const Color badgeGold = Color(0xFFFFD700);
  static const Color badgePlatinum = Color(0xFFE5E4E2);
  
  // Helper methods
  static Color getSeverityColor(String severity) {
    switch (severity) {
      case 'low':
        return severityLow;
      case 'medium':
        return severityMedium;
      case 'high':
        return severityHigh;
      default:
        return grey500;
    }
  }
  
  static Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return statusPending;
      case 'verified':
        return statusVerified;
      case 'in_progress':
        return statusInProgress;
      case 'resolved':
        return statusResolved;
      case 'rejected':
        return statusRejected;
      default:
        return grey500;
    }
  }
  
  static Color getIdeaStatusColor(String status) {
    switch (status) {
      case 'open':
        return ideaOpen;
      case 'under_review':
        return ideaUnderReview;
      case 'approved':
        return ideaApproved;
      case 'declined':
        return ideaDeclined;
      case 'implemented':
        return ideaImplemented;
      default:
        return grey500;
    }
  }
}
