import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessibility helper utilities
class AccessibilityHelper {
  /// Minimum touch target size (44x44 as per WCAG)
  static const double minTouchTargetSize = 44.0;
  
  /// Check if touch target meets minimum size
  static bool meetsMinimumTouchTarget(double width, double height) {
    return width >= minTouchTargetSize && height >= minTouchTargetSize;
  }
  
  /// Wrap widget with minimum touch target size
  static Widget ensureMinimumTouchTarget({
    required Widget child,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: minTouchTargetSize,
      height: minTouchTargetSize,
      child: Center(
        child: onTap != null
            ? InkWell(onTap: onTap, child: child)
            : child,
      ),
    );
  }
  
  /// Announce message to screen reader
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }
  
  /// Create semantic label for button
  static String buttonLabel({
    required String action,
    String? target,
    String? state,
  }) {
    final parts = <String>[action];
    if (target != null) parts.add(target);
    if (state != null) parts.add(state);
    return parts.join(', ');
  }
  
  /// Create semantic label for status
  static String statusLabel(String status) {
    return 'Status: $status';
  }
  
  /// Create semantic label for count
  static String countLabel(int count, String singular, String plural) {
    return '$count ${count == 1 ? singular : plural}';
  }
  
  /// Create semantic label for date
  static String dateLabel(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  
  /// Create semantic label for vote button
  static String voteButtonLabel({
    required int voteCount,
    required bool hasVoted,
  }) {
    if (hasVoted) {
      return 'Voted, $voteCount ${voteCount == 1 ? "vote" : "votes"}';
    }
    return 'Vote button, $voteCount ${voteCount == 1 ? "vote" : "votes"}';
  }
  
  /// Create semantic label for verify button
  static String verifyButtonLabel({
    required int verificationCount,
    required bool hasVerified,
    required bool isOwnReport,
  }) {
    if (isOwnReport) {
      return 'Cannot verify your own report, $verificationCount ${verificationCount == 1 ? "verification" : "verifications"}';
    }
    if (hasVerified) {
      return 'Verified, $verificationCount ${verificationCount == 1 ? "verification" : "verifications"}';
    }
    return 'Verify button, $verificationCount ${verificationCount == 1 ? "verification" : "verifications"}';
  }
  
  /// Create semantic label for card
  static String cardLabel({
    required String title,
    required String type,
    String? status,
    String? category,
    String? date,
  }) {
    final parts = <String>[type, title];
    if (status != null) parts.add('Status: $status');
    if (category != null) parts.add('Category: $category');
    if (date != null) parts.add(date);
    return parts.join(', ');
  }
  
  /// Create semantic label for list item
  static String listItemLabel({
    required String title,
    required int position,
    required int total,
  }) {
    return '$title, item $position of $total';
  }
  
  /// Create semantic label for notification
  static String notificationLabel({
    required String title,
    required String message,
    required bool isRead,
    required String time,
  }) {
    final readStatus = isRead ? 'Read' : 'Unread';
    return '$readStatus notification, $title, $message, $time';
  }
  
  /// Create semantic label for leaderboard entry
  static String leaderboardEntryLabel({
    required String name,
    required int rank,
    required int points,
    bool isCurrentUser = false,
  }) {
    final userIndicator = isCurrentUser ? 'You, ' : '';
    return '${userIndicator}Rank $rank, $name, $points ${points == 1 ? "point" : "points"}';
  }
  
  /// Check color contrast ratio (simplified)
  static bool hasGoodContrast(Color foreground, Color background) {
    // Simplified contrast check
    // Full WCAG calculation would be more complex
    final fgLuminance = foreground.computeLuminance();
    final bgLuminance = background.computeLuminance();
    
    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;
    
    final contrastRatio = (lighter + 0.05) / (darker + 0.05);
    
    // WCAG AA requires 4.5:1 for normal text, 3:1 for large text
    return contrastRatio >= 4.5;
  }
  
  /// Create excludeSemantics widget
  static Widget excludeFromSemantics(Widget child) {
    return ExcludeSemantics(child: child);
  }
  
  /// Create merge semantics widget
  static Widget mergeSemantics({
    required Widget child,
    String? label,
    String? hint,
    String? value,
    bool? button,
    bool? header,
    VoidCallback? onTap,
  }) {
    return MergeSemantics(
      child: Semantics(
        label: label,
        hint: hint,
        value: value,
        button: button,
        header: header,
        onTap: onTap,
        child: child,
      ),
    );
  }
}

/// Semantic button wrapper
class SemanticButton extends StatelessWidget {
  final Widget child;
  final String label;
  final String? hint;
  final VoidCallback? onPressed;
  final bool enabled;
  
  const SemanticButton({
    super.key,
    required this.child,
    required this.label,
    this.hint,
    this.onPressed,
    this.enabled = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      hint: hint,
      onTap: enabled ? onPressed : null,
      child: child,
    );
  }
}

/// Semantic card wrapper
class SemanticCard extends StatelessWidget {
  final Widget child;
  final String label;
  final String? hint;
  final VoidCallback? onTap;
  
  const SemanticCard({
    super.key,
    required this.child,
    required this.label,
    this.hint,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      onTap: onTap,
      child: child,
    );
  }
}

/// Semantic header wrapper
class SemanticHeader extends StatelessWidget {
  final Widget child;
  final String label;
  final int level;
  
  const SemanticHeader({
    super.key,
    required this.child,
    required this.label,
    this.level = 1,
  });
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: label,
      child: child,
    );
  }
}

/// Semantic image wrapper
class SemanticImage extends StatelessWidget {
  final Widget child;
  final String label;
  
  const SemanticImage({
    super.key,
    required this.child,
    required this.label,
  });
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: label,
      child: child,
    );
  }
}
