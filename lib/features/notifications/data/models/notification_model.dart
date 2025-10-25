import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification.dart';

/// Notification model for Firestore serialization
class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final String? relatedType;
  final String? relatedId;
  final bool isRead;
  final DateTime timestamp;

  const NotificationModel({
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

  /// Create from Firestore document
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel.fromJson(data, doc.id);
  }

  /// Create from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json, String id) {
    return NotificationModel(
      id: id,
      userId: json['userId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      relatedType: json['relatedType'] as String?,
      relatedId: json['relatedId'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'relatedType': relatedType,
      'relatedId': relatedId,
      'isRead': isRead,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// Convert to entity
  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      userId: userId,
      type: type,
      title: title,
      message: message,
      relatedType: relatedType,
      relatedId: relatedId,
      isRead: isRead,
      timestamp: timestamp,
    );
  }

  /// Create from entity
  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      userId: entity.userId,
      type: entity.type,
      title: entity.title,
      message: entity.message,
      relatedType: entity.relatedType,
      relatedId: entity.relatedId,
      isRead: entity.isRead,
      timestamp: entity.timestamp,
    );
  }
}
