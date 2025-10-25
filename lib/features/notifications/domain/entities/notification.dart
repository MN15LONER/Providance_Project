/// Notification entity
class NotificationEntity {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final String? relatedType;
  final String? relatedId;
  final bool isRead;
  final DateTime timestamp;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.relatedType,
    this.relatedId,
    required this.isRead,
    required this.timestamp,
  });

  NotificationEntity copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? message,
    String? relatedType,
    String? relatedId,
    bool? isRead,
    DateTime? timestamp,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      relatedType: relatedType ?? this.relatedType,
      relatedId: relatedId ?? this.relatedId,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
