import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/point_history.dart';

/// Point history model for Firestore serialization
class PointHistoryModel extends PointHistory {
  const PointHistoryModel({
    required super.id,
    required super.userId,
    required super.points,
    required super.action,
    super.referenceId,
    super.referenceType,
    required super.timestamp,
  });

  /// Create from Firestore document
  factory PointHistoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PointHistoryModel.fromJson(data, doc.id);
  }

  /// Create from JSON
  factory PointHistoryModel.fromJson(Map<String, dynamic> json, [String? id]) {
    return PointHistoryModel(
      id: id ?? json['id'] as String,
      userId: json['userId'] as String,
      points: json['points'] as int,
      action: json['action'] as String,
      referenceId: json['referenceId'] as String?,
      referenceType: json['referenceType'] as String?,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'points': points,
      'action': action,
      'referenceId': referenceId,
      'referenceType': referenceType,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// Convert to JSON for creation (uses server timestamp)
  Map<String, dynamic> toJsonForCreate() {
    return {
      'userId': userId,
      'points': points,
      'action': action,
      'referenceId': referenceId,
      'referenceType': referenceType,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  /// Convert entity to model
  factory PointHistoryModel.fromEntity(PointHistory pointHistory) {
    return PointHistoryModel(
      id: pointHistory.id,
      userId: pointHistory.userId,
      points: pointHistory.points,
      action: pointHistory.action,
      referenceId: pointHistory.referenceId,
      referenceType: pointHistory.referenceType,
      timestamp: pointHistory.timestamp,
    );
  }

  /// Convert to entity
  PointHistory toEntity() {
    return PointHistory(
      id: id,
      userId: userId,
      points: points,
      action: action,
      referenceId: referenceId,
      referenceType: referenceType,
      timestamp: timestamp,
    );
  }
}
