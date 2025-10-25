/// Point history entity
class PointHistory {
  final String id;
  final String userId;
  final int points;
  final String action;
  final String? referenceId;
  final String? referenceType;
  final DateTime timestamp;

  const PointHistory({
    required this.id,
    required this.userId,
    required this.points,
    required this.action,
    this.referenceId,
    this.referenceType,
    required this.timestamp,
  });

  PointHistory copyWith({
    String? id,
    String? userId,
    int? points,
    String? action,
    String? referenceId,
    String? referenceType,
    DateTime? timestamp,
  }) {
    return PointHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      points: points ?? this.points,
      action: action ?? this.action,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PointHistory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PointHistory(id: $id, action: $action, points: $points)';
  }
}
