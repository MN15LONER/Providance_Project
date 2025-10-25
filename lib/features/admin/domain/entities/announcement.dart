/// Announcement entity for admin posts
class Announcement {
  final String id;
  final String title;
  final String message;
  final String type; // 'general', 'maintenance', 'emergency', 'meeting'
  final String createdBy;
  final String creatorName;
  final String? creatorPhoto;
  final DateTime createdAt;
  final DateTime? scheduledFor; // For scheduled maintenance
  final String? ward; // Specific ward or null for municipality-wide
  final String? municipality;
  final bool isActive;
  final int viewCount;

  const Announcement({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdBy,
    required this.creatorName,
    this.creatorPhoto,
    required this.createdAt,
    this.scheduledFor,
    this.ward,
    this.municipality,
    this.isActive = true,
    this.viewCount = 0,
  });

  Announcement copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? createdBy,
    String? creatorName,
    String? creatorPhoto,
    DateTime? createdAt,
    DateTime? scheduledFor,
    String? ward,
    String? municipality,
    bool? isActive,
    int? viewCount,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdBy: createdBy ?? this.createdBy,
      creatorName: creatorName ?? this.creatorName,
      creatorPhoto: creatorPhoto ?? this.creatorPhoto,
      createdAt: createdAt ?? this.createdAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      ward: ward ?? this.ward,
      municipality: municipality ?? this.municipality,
      isActive: isActive ?? this.isActive,
      viewCount: viewCount ?? this.viewCount,
    );
  }
}
