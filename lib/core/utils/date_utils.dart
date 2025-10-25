import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../constants/app_constants.dart';

/// Date and time utility functions
class AppDateUtils {
  // Format date
  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.dateFormat).format(date);
  }
  
  // Format date and time
  static String formatDateTime(DateTime dateTime) {
    return DateFormat(AppConstants.dateTimeFormat).format(dateTime);
  }
  
  // Format time
  static String formatTime(DateTime time) {
    return DateFormat(AppConstants.timeFormat).format(time);
  }
  
  // Get relative time (e.g., "2 hours ago")
  static String getRelativeTime(DateTime dateTime) {
    return timeago.format(dateTime, locale: 'en_short');
  }
  
  // Get full relative time (e.g., "2 hours ago")
  static String getFullRelativeTime(DateTime dateTime) {
    return timeago.format(dateTime);
  }
  
  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
  
  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }
  
  // Get smart date format (Today, Yesterday, or date)
  static String getSmartDate(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else {
      return formatDate(date);
    }
  }
  
  // Get smart date time format
  static String getSmartDateTime(DateTime dateTime) {
    if (isToday(dateTime)) {
      return 'Today at ${formatTime(dateTime)}';
    } else if (isYesterday(dateTime)) {
      return 'Yesterday at ${formatTime(dateTime)}';
    } else {
      return formatDateTime(dateTime);
    }
  }
  
  // Calculate duration between two dates
  static Duration getDuration(DateTime start, DateTime end) {
    return end.difference(start);
  }
  
  // Format duration (e.g., "2h 30m")
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }
  
  // Get days ago
  static int getDaysAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    return difference.inDays;
  }
  
  // Get hours ago
  static int getHoursAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    return difference.inHours;
  }
  
  // Parse ISO 8601 string to DateTime
  static DateTime? parseIso8601(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  // Convert DateTime to ISO 8601 string
  static String toIso8601(DateTime dateTime) {
    return dateTime.toIso8601String();
  }
  
  // Get start of day
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  
  // Get end of day
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
  
  // Get start of month
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
  
  // Get end of month
  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }
  
  // Check if date is within range
  static bool isWithinRange(DateTime date, DateTime start, DateTime end) {
    return date.isAfter(start) && date.isBefore(end);
  }
  
  // Get age from date of birth
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
