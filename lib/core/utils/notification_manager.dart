import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/notifications/data/repositories/notification_repository.dart';
import '../../features/notifications/presentation/providers/notification_provider.dart';

/// Notification manager provider
final notificationManagerProvider = Provider<NotificationManager>((ref) {
  return NotificationManager(
    notificationRepository: ref.read(notificationRepositoryProvider),
  );
});

/// Manages sending notifications
class NotificationManager {
  final NotificationRepository _notificationRepository;

  NotificationManager({
    required NotificationRepository notificationRepository,
  }) : _notificationRepository = notificationRepository;

  /// Send issue status update notification
  Future<void> sendIssueStatusNotification({
    required String userId,
    required String issueId,
    required String issueTitle,
    required String newStatus,
  }) async {
    await _notificationRepository.sendIssueStatusNotification(
      userId: userId,
      issueId: issueId,
      issueTitle: issueTitle,
      newStatus: newStatus,
    );
  }

  /// Send idea status update notification
  Future<void> sendIdeaStatusNotification({
    required String userId,
    required String ideaId,
    required String ideaTitle,
    required String newStatus,
  }) async {
    await _notificationRepository.sendIdeaStatusNotification(
      userId: userId,
      ideaId: ideaId,
      ideaTitle: ideaTitle,
      newStatus: newStatus,
    );
  }

  /// Send comment notification
  Future<void> sendCommentNotification({
    required String userId,
    required String parentId,
    required String parentTitle,
    required String parentType,
    required String commenterName,
  }) async {
    await _notificationRepository.sendCommentNotification(
      userId: userId,
      parentId: parentId,
      parentTitle: parentTitle,
      parentType: parentType,
      commenterName: commenterName,
    );
  }

  /// Send announcement notification
  Future<void> sendAnnouncementNotification({
    required List<String> userIds,
    required String title,
    required String message,
  }) async {
    await _notificationRepository.sendAnnouncementNotification(
      userIds: userIds,
      title: title,
      message: message,
    );
  }
}