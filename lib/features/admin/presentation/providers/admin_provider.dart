import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/admin_repository.dart';
import '../../domain/entities/announcement.dart';

/// Admin repository provider
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

/// Admin statistics provider
final adminStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  return await repository.getAdminStatistics();
});

/// Announcements stream provider
final announcementsStreamProvider = StreamProvider.family<List<Announcement>, AnnouncementFilter>(
  (ref, filter) {
    final repository = ref.watch(adminRepositoryProvider);
    return repository.getAnnouncements(
      ward: filter.ward,
      municipality: filter.municipality,
      activeOnly: filter.activeOnly,
    );
  },
);

/// Announcement filter class
class AnnouncementFilter {
  final String? ward;
  final String? municipality;
  final bool activeOnly;

  const AnnouncementFilter({
    this.ward,
    this.municipality,
    this.activeOnly = true,
  });
}

/// Admin controller state
class AdminControllerState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const AdminControllerState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  AdminControllerState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return AdminControllerState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

/// Admin controller provider
final adminControllerProvider =
    StateNotifierProvider<AdminController, AdminControllerState>((ref) {
  return AdminController(ref.watch(adminRepositoryProvider));
});

/// Admin controller
class AdminController extends StateNotifier<AdminControllerState> {
  final AdminRepository _repository;

  AdminController(this._repository) : super(const AdminControllerState());

  /// Create announcement
  Future<bool> createAnnouncement({
    required String title,
    required String message,
    required String type,
    DateTime? scheduledFor,
    String? ward,
    String? municipality,
  }) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      await _repository.createAnnouncement(
        title: title,
        message: message,
        type: type,
        scheduledFor: scheduledFor,
        ward: ward,
        municipality: municipality,
      );

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Announcement created successfully',
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

  /// Update idea status
  Future<bool> updateIdeaStatus({
    required String ideaId,
    required String status,
    String? adminResponse,
    double? budget,
    DateTime? timeline,
  }) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      await _repository.updateIdeaStatus(
        ideaId: ideaId,
        status: status,
        adminResponse: adminResponse,
        budget: budget,
        timeline: timeline,
      );

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Idea status updated successfully',
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

  /// Update issue status
  Future<bool> updateIssueStatus({
    required String issueId,
    required String status,
    String? assignedTo,
    String? assignedToName,
    String? officialResponse,
  }) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      await _repository.updateIssueStatus(
        issueId: issueId,
        status: status,
        assignedTo: assignedTo,
        assignedToName: assignedToName,
        officialResponse: officialResponse,
      );

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Issue status updated successfully',
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

  /// Delete announcement
  Future<bool> deleteAnnouncement(String id) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      await _repository.deleteAnnouncement(id);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Announcement deleted successfully',
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
}
