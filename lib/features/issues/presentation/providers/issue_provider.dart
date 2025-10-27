import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/location_service.dart';
import '../../data/repositories/issue_repository.dart';
import '../../domain/entities/issue.dart';
import '../../data/models/issue_model.dart';

/// Issue repository provider
final issueRepositoryProvider = Provider<IssueRepository>((ref) {
  return IssueRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    locationService: ref.watch(locationServiceProvider),
  );
});

/// All issues stream provider
final allIssuesProvider = StreamProvider<List<Issue>>((ref) {
  final repository = ref.watch(issueRepositoryProvider);
  return repository.getIssues();
});

/// My issues stream provider (issues reported by current user)
final myIssuesProvider = StreamProvider<List<Issue>>((ref) {
  final repository = ref.watch(issueRepositoryProvider);
  final userId = FirebaseAuth.instance.currentUser?.uid;
  
  if (userId == null) {
    return Stream.value([]);
  }
  
  return repository.getIssues(userId: userId);
});

/// Issues by status provider
final issuesByStatusProvider = StreamProvider.family<List<Issue>, String>((ref, status) {
  final repository = ref.watch(issueRepositoryProvider);
  return repository.getIssues(status: status);
});

/// Issues by category provider
final issuesByCategoryProvider = StreamProvider.family<List<Issue>, String>((ref, category) {
  final repository = ref.watch(issueRepositoryProvider);
  return repository.getIssues(category: category);
});

/// Single issue stream provider
final issueStreamProvider = StreamProvider.family<Issue, String>((ref, issueId) {
  final repository = ref.watch(issueRepositoryProvider);
  return repository.getIssueStream(issueId);
});

/// Single issue future provider
final issueDetailProvider = FutureProvider.family<Issue, String>((ref, issueId) {
  final repository = ref.watch(issueRepositoryProvider);
  return repository.getIssueById(issueId);
});

/// Issues count by status provider
final issuesCountProvider = FutureProvider<Map<String, int>>((ref) {
  final repository = ref.watch(issueRepositoryProvider);
  return repository.getIssuesCountByStatus();
});

/// Recent issues stream provider (ordered by updatedAt)
final recentIssuesProvider = StreamProvider<List<Issue>>((ref) {
  return FirebaseFirestore.instance
      .collection('issues')
      .orderBy('updatedAt', descending: true)
      .limit(10)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => IssueModel.fromFirestore(doc) as Issue)
          .toList());
});

/// Issue controller state
class IssueControllerState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const IssueControllerState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  IssueControllerState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return IssueControllerState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

/// Issue controller provider
final issueControllerProvider = StateNotifierProvider<IssueController, IssueControllerState>((ref) {
  return IssueController(
    repository: ref.watch(issueRepositoryProvider),
  );
});

/// Issue controller
class IssueController extends StateNotifier<IssueControllerState> {
  final IssueRepository _repository;

  IssueController({
    required IssueRepository repository,
  })  : _repository = repository,
        super(const IssueControllerState());

  /// Create new issue
  Future<String?> createIssue({
    required String title,
    required String description,
    required String category,
    required String severity,
    required GeoPoint location,
    required List<File> photos,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final issueId = await _repository.createIssue(
        title: title,
        description: description,
        category: category,
        severity: severity,
        location: location,
        photos: photos,
      );

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Issue reported successfully',
      );

      return issueId;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Update issue status
  Future<bool> updateStatus(String issueId, String status) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.updateIssueStatus(issueId, status);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Status updated successfully',
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

  /// Assign issue to official
  Future<bool> assignIssue(
    String issueId,
    String officialId,
    String officialName,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.assignIssue(issueId, officialId, officialName);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Issue assigned successfully',
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

  /// Add official response
  Future<bool> addResponse(String issueId, String response) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.addOfficialResponse(issueId, response);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Response added successfully',
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

  /// Verify issue
  Future<bool> verifyIssue(String issueId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.verifyIssue(issueId);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Issue verified successfully',
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

  /// Remove verification
  Future<bool> removeVerification(String issueId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.removeVerification(issueId);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Verification removed',
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

  /// Delete issue
  Future<bool> deleteIssue(String issueId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.deleteIssue(issueId);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Issue deleted successfully',
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
