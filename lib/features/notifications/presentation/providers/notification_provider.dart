import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/notification_repository.dart';
import '../../domain/entities/notification.dart';

/// Notification repository provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

/// Notifications stream provider
final notificationsProvider = StreamProvider<List<NotificationEntity>>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getNotifications();
});

/// Unread count stream provider
final unreadCountProvider = StreamProvider<int>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getUnreadCount();
});

/// Notification controller state
class NotificationControllerState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const NotificationControllerState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  NotificationControllerState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return NotificationControllerState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

/// Notification controller provider
final notificationControllerProvider =
    StateNotifierProvider<NotificationController, NotificationControllerState>((ref) {
  return NotificationController(
    repository: ref.watch(notificationRepositoryProvider),
  );
});

/// Notification controller
class NotificationController extends StateNotifier<NotificationControllerState> {
  final NotificationRepository _repository;

  NotificationController({
    required NotificationRepository repository,
  })  : _repository = repository,
        super(const NotificationControllerState());

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.markAllAsRead();

      state = state.copyWith(
        isLoading: false,
        successMessage: 'All notifications marked as read',
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _repository.deleteNotification(notificationId);
      state = state.copyWith(successMessage: 'Notification deleted');
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Delete all notifications
  Future<bool> deleteAllNotifications() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.deleteAllNotifications();

      state = state.copyWith(
        isLoading: false,
        successMessage: 'All notifications deleted',
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Clear messages
  void clearMessages() {
    state = state.copyWith(
      error: null,
      successMessage: null,
    );
  }
}
