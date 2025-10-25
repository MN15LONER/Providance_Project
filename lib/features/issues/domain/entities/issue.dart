import 'package:cloud_firestore/cloud_firestore.dart';

/// Issue entity representing a reported municipal issue
class Issue {
  final String id;
  final String reportedBy;
  final String reporterName;
  final String? reporterPhoto;
  final String title;
  final String description;
  final String category;
  final String severity;
  final String status;
  final GeoPoint location;
  final String locationName;
  final String? ward;
  final List<String> photos;
  final List<String> verifications;
  final int verificationCount;
  final String? assignedTo;
  final String? assignedToName;
  final DateTime? assignedAt;
  final String? officialResponse;
  final DateTime? respondedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Issue({
    required this.id,
    required this.reportedBy,
    required this.reporterName,
    this.reporterPhoto,
    required this.title,
    required this.description,
    required this.category,
    required this.severity,
    required this.status,
    required this.location,
    required this.locationName,
    this.ward,
    required this.photos,
    required this.verifications,
    required this.verificationCount,
    this.assignedTo,
    this.assignedToName,
    this.assignedAt,
    this.officialResponse,
    this.respondedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy with updated fields
  Issue copyWith({
    String? id,
    String? reportedBy,
    String? reporterName,
    String? reporterPhoto,
    String? title,
    String? description,
    String? category,
    String? severity,
    String? status,
    GeoPoint? location,
    String? locationName,
    String? ward,
    List<String>? photos,
    List<String>? verifications,
    int? verificationCount,
    String? assignedTo,
    String? assignedToName,
    DateTime? assignedAt,
    String? officialResponse,
    DateTime? respondedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Issue(
      id: id ?? this.id,
      reportedBy: reportedBy ?? this.reportedBy,
      reporterName: reporterName ?? this.reporterName,
      reporterPhoto: reporterPhoto ?? this.reporterPhoto,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      location: location ?? this.location,
      locationName: locationName ?? this.locationName,
      ward: ward ?? this.ward,
      photos: photos ?? this.photos,
      verifications: verifications ?? this.verifications,
      verificationCount: verificationCount ?? this.verificationCount,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      assignedAt: assignedAt ?? this.assignedAt,
      officialResponse: officialResponse ?? this.officialResponse,
      respondedAt: respondedAt ?? this.respondedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Issue && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Issue(id: $id, title: $title, status: $status, category: $category)';
  }
}
