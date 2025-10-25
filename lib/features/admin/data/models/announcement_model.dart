import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/announcement.dart';

class AnnouncementModel extends Announcement {
  const AnnouncementModel({
    required super.id,
    required super.title,
    required super.message,
    required super.type,
    required super.createdBy,
    required super.creatorName,
    super.creatorPhoto,
    required super.createdAt,
    super.scheduledFor,
    super.ward,
    super.municipality,
    super.isActive,
    super.viewCount,
  });

  factory AnnouncementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnnouncementModel(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? 'general',
      createdBy: data['createdBy'] ?? '',
      creatorName: data['creatorName'] ?? '',
      creatorPhoto: data['creatorPhoto'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      scheduledFor: (data['scheduledFor'] as Timestamp?)?.toDate(),
      ward: data['ward'],
      municipality: data['municipality'],
      isActive: data['isActive'] ?? true,
      viewCount: data['viewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'createdBy': createdBy,
      'creatorName': creatorName,
      'creatorPhoto': creatorPhoto,
      'createdAt': Timestamp.fromDate(createdAt),
      'scheduledFor': scheduledFor != null ? Timestamp.fromDate(scheduledFor!) : null,
      'ward': ward,
      'municipality': municipality,
      'isActive': isActive,
      'viewCount': viewCount,
    };
  }
}
