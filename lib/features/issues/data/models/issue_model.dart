import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/issue.dart';

/// Issue model for Firestore serialization
class IssueModel extends Issue {
  const IssueModel({
    required super.id,
    required super.reportedBy,
    required super.reporterName,
    super.reporterPhoto,
    required super.title,
    required super.description,
    required super.category,
    required super.severity,
    required super.status,
    required super.location,
    required super.locationName,
    super.ward,
    required super.photos,
    required super.verifications,
    required super.verificationCount,
    super.assignedTo,
    super.assignedToName,
    super.assignedAt,
    super.officialResponse,
    super.respondedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create from Firestore document
  factory IssueModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IssueModel.fromJson(data, doc.id);
  }

  /// Create from JSON
  factory IssueModel.fromJson(Map<String, dynamic> json, [String? id]) {
    return IssueModel(
      id: id ?? json['id'] as String,
      reportedBy: json['reportedBy'] as String,
      reporterName: json['reporterName'] as String,
      reporterPhoto: json['reporterPhoto'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      severity: json['severity'] as String,
      status: json['status'] as String,
      location: json['location'] as GeoPoint,
      locationName: json['locationName'] as String,
      ward: json['ward'] as String?,
      photos: List<String>.from(json['photos'] as List),
      verifications: List<String>.from(json['verifications'] as List? ?? []),
      verificationCount: json['verificationCount'] as int? ?? 0,
      assignedTo: json['assignedTo'] as String?,
      assignedToName: json['assignedToName'] as String?,
      assignedAt: json['assignedAt'] != null
          ? (json['assignedAt'] as Timestamp).toDate()
          : null,
      officialResponse: json['officialResponse'] as String?,
      respondedAt: json['respondedAt'] != null
          ? (json['respondedAt'] as Timestamp).toDate()
          : null,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'reportedBy': reportedBy,
      'reporterName': reporterName,
      'reporterPhoto': reporterPhoto,
      'title': title,
      'description': description,
      'category': category,
      'severity': severity,
      'status': status,
      'location': location,
      'locationName': locationName,
      'ward': ward,
      'photos': photos,
      'verifications': verifications,
      'verificationCount': verificationCount,
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'assignedAt': assignedAt != null ? Timestamp.fromDate(assignedAt!) : null,
      'officialResponse': officialResponse,
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Convert to JSON for creation (uses server timestamp)
  Map<String, dynamic> toJsonForCreate() {
    return {
      'reportedBy': reportedBy,
      'reporterName': reporterName,
      'reporterPhoto': reporterPhoto,
      'title': title,
      'description': description,
      'category': category,
      'severity': severity,
      'status': status,
      'location': location,
      'locationName': locationName,
      'ward': ward,
      'photos': photos,
      'verifications': [],
      'verificationCount': 0,
      'assignedTo': null,
      'assignedToName': null,
      'assignedAt': null,
      'officialResponse': null,
      'respondedAt': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Convert entity to model
  factory IssueModel.fromEntity(Issue issue) {
    return IssueModel(
      id: issue.id,
      reportedBy: issue.reportedBy,
      reporterName: issue.reporterName,
      reporterPhoto: issue.reporterPhoto,
      title: issue.title,
      description: issue.description,
      category: issue.category,
      severity: issue.severity,
      status: issue.status,
      location: issue.location,
      locationName: issue.locationName,
      ward: issue.ward,
      photos: issue.photos,
      verifications: issue.verifications,
      verificationCount: issue.verificationCount,
      assignedTo: issue.assignedTo,
      assignedToName: issue.assignedToName,
      assignedAt: issue.assignedAt,
      officialResponse: issue.officialResponse,
      respondedAt: issue.respondedAt,
      createdAt: issue.createdAt,
      updatedAt: issue.updatedAt,
    );
  }

  /// Convert to entity
  Issue toEntity() {
    return Issue(
      id: id,
      reportedBy: reportedBy,
      reporterName: reporterName,
      reporterPhoto: reporterPhoto,
      title: title,
      description: description,
      category: category,
      severity: severity,
      status: status,
      location: location,
      locationName: locationName,
      ward: ward,
      photos: photos,
      verifications: verifications,
      verificationCount: verificationCount,
      assignedTo: assignedTo,
      assignedToName: assignedToName,
      assignedAt: assignedAt,
      officialResponse: officialResponse,
      respondedAt: respondedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
