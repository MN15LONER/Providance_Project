import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/location_service.dart';
import '../../data/repositories/verification_repository.dart';
import '../../data/repositories/points_repository.dart';
import '../../domain/entities/point_history.dart';
import '../../domain/entities/leaderboard_entry.dart';

/// Verification repository provider
final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  return VerificationRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    locationService: ref.watch(locationServiceProvider),
  );
});

/// Points repository provider
final pointsRepositoryProvider = Provider<PointsRepository>((ref) {
  return PointsRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

/// Current user points stream provider
final currentUserPointsProvider = StreamProvider<int>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return Stream.value(0);
  }
  
  final repository = ref.watch(pointsRepositoryProvider);
  return repository.getUserPoints(userId);
});

/// User points stream provider (by userId)
final userPointsProvider = StreamProvider.family<int, String>((ref, userId) {
  final repository = ref.watch(pointsRepositoryProvider);
  return repository.getUserPoints(userId);
});

/// Points history stream provider
final pointsHistoryProvider = StreamProvider.family<List<PointHistory>, String>((ref, userId) {
  final repository = ref.watch(pointsRepositoryProvider);
  return repository.getPointsHistory(userId, limit: 50);
});

/// Current user points history provider
final currentUserPointsHistoryProvider = StreamProvider<List<PointHistory>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return Stream.value([]);
  }
  
  final repository = ref.watch(pointsRepositoryProvider);
  return repository.getPointsHistory(userId, limit: 50);
});

/// Leaderboard provider
final leaderboardProvider = FutureProvider.family<List<LeaderboardEntry>, String?>((ref, ward) {
  final repository = ref.watch(pointsRepositoryProvider);
  return repository.getLeaderboard(ward: ward, limit: 50);
});

/// Global leaderboard provider
final globalLeaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) {
  final repository = ref.watch(pointsRepositoryProvider);
  return repository.getLeaderboard(limit: 50);
});

/// User rank provider
final userRankProvider = FutureProvider.family<int, Map<String, String?>>((ref, params) {
  final repository = ref.watch(pointsRepositoryProvider);
  return repository.getUserRank(params['userId']!, ward: params['ward']);
});

/// Current user rank provider
final currentUserRankProvider = FutureProvider<int>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return 0;
  
  final repository = ref.watch(pointsRepositoryProvider);
  
  // Get user's ward
  final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
  final ward = userDoc.data()?['ward'] as String?;
  
  return repository.getUserRank(userId, ward: ward);
});

/// Has verified provider
final hasVerifiedProvider = FutureProvider.family<bool, String>((ref, issueId) {
  final repository = ref.watch(verificationRepositoryProvider);
  return repository.hasVerified(issueId);
});

/// Points statistics provider
final pointsStatisticsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, userId) {
  final repository = ref.watch(pointsRepositoryProvider);
  return repository.getPointsStatistics(userId);
});

/// Current user statistics provider
final currentUserStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return {
      'totalPoints': 0,
      'rank': 0,
      'issuesReported': 0,
      'ideasProposed': 0,
      'verificationsGiven': 0,
      'votesGiven': 0,
    };
  }
  
  final repository = ref.watch(pointsRepositoryProvider);
  return repository.getPointsStatistics(userId);
});

/// Points breakdown provider
final pointsBreakdownProvider = FutureProvider.family<Map<String, int>, String>((ref, userId) {
  final repository = ref.watch(pointsRepositoryProvider);
  return repository.getPointsBreakdown(userId);
});

/// Gamification controller state
class GamificationControllerState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const GamificationControllerState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  GamificationControllerState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return GamificationControllerState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

/// Gamification controller provider
final gamificationControllerProvider = StateNotifierProvider<GamificationController, GamificationControllerState>((ref) {
  return GamificationController(
    verificationRepository: ref.watch(verificationRepositoryProvider),
    pointsRepository: ref.watch(pointsRepositoryProvider),
  );
});

/// Gamification controller
class GamificationController extends StateNotifier<GamificationControllerState> {
  final VerificationRepository _verificationRepository;
  final PointsRepository _pointsRepository;

  GamificationController({
    required VerificationRepository verificationRepository,
    required PointsRepository pointsRepository,
  })  : _verificationRepository = verificationRepository,
        _pointsRepository = pointsRepository,
        super(const GamificationControllerState());

  /// Verify an issue
  Future<bool> verifyIssue(String issueId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _verificationRepository.verifyIssue(issueId);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Issue verified! +2 points',
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
      await _verificationRepository.removeVerification(issueId);

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

  /// Award points manually (admin only)
  Future<bool> awardPoints({
    required String userId,
    required int points,
    required String action,
    String? referenceId,
    String? referenceType,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _pointsRepository.awardPoints(
        userId: userId,
        points: points,
        action: action,
        referenceId: referenceId,
        referenceType: referenceType,
      );

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Points awarded successfully',
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
