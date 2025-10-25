import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/location_service.dart';
import '../../data/repositories/idea_repository.dart';
import '../../data/repositories/comment_repository.dart';
import '../../domain/entities/idea.dart';
import '../../domain/entities/comment.dart';

/// Idea repository provider
final ideaRepositoryProvider = Provider<IdeaRepository>((ref) {
  return IdeaRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    locationService: ref.watch(locationServiceProvider),
  );
});

/// Comment repository provider
final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

/// All ideas stream provider
final allIdeasProvider = StreamProvider<List<Idea>>((ref) {
  final repository = ref.watch(ideaRepositoryProvider);
  return repository.getIdeas(sortBy: 'voteCount');
});

/// My ideas stream provider
final myIdeasProvider = StreamProvider<List<Idea>>((ref) {
  final repository = ref.watch(ideaRepositoryProvider);
  final userId = FirebaseAuth.instance.currentUser?.uid;
  
  if (userId == null) {
    return Stream.value([]);
  }
  
  return repository.getIdeas(userId: userId);
});

/// Ideas by status provider
final ideasByStatusProvider = StreamProvider.family<List<Idea>, String>((ref, status) {
  final repository = ref.watch(ideaRepositoryProvider);
  return repository.getIdeas(status: status, sortBy: 'voteCount');
});

/// Ideas by category provider
final ideasByCategoryProvider = StreamProvider.family<List<Idea>, String>((ref, category) {
  final repository = ref.watch(ideaRepositoryProvider);
  return repository.getIdeas(category: category, sortBy: 'voteCount');
});

/// Single idea stream provider
final ideaStreamProvider = StreamProvider.family<Idea, String>((ref, ideaId) {
  final repository = ref.watch(ideaRepositoryProvider);
  return repository.getIdeaStream(ideaId);
});

/// Single idea future provider
final ideaDetailProvider = FutureProvider.family<Idea, String>((ref, ideaId) {
  final repository = ref.watch(ideaRepositoryProvider);
  return repository.getIdeaById(ideaId);
});

/// Has voted provider
final hasVotedProvider = FutureProvider.family<bool, String>((ref, ideaId) {
  final repository = ref.watch(ideaRepositoryProvider);
  return repository.hasVoted(ideaId);
});

/// Comments stream provider
final commentsProvider = StreamProvider.family<List<Comment>, String>((ref, ideaId) {
  final repository = ref.watch(commentRepositoryProvider);
  return repository.getComments(ideaId);
});

/// Has liked comment provider
final hasLikedCommentProvider = FutureProvider.family<bool, Map<String, String>>((ref, params) {
  final repository = ref.watch(commentRepositoryProvider);
  return repository.hasLikedComment(params['ideaId']!, params['commentId']!);
});

/// Ideas count by status provider
final ideasCountProvider = FutureProvider<Map<String, int>>((ref) {
  final repository = ref.watch(ideaRepositoryProvider);
  return repository.getIdeasCountByStatus();
});

/// Idea controller state
class IdeaControllerState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const IdeaControllerState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  IdeaControllerState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return IdeaControllerState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

/// Idea controller provider
final ideaControllerProvider = StateNotifierProvider<IdeaController, IdeaControllerState>((ref) {
  return IdeaController(
    ideaRepository: ref.watch(ideaRepositoryProvider),
    commentRepository: ref.watch(commentRepositoryProvider),
  );
});

/// Idea controller
class IdeaController extends StateNotifier<IdeaControllerState> {
  final IdeaRepository _ideaRepository;
  final CommentRepository _commentRepository;

  IdeaController({
    required IdeaRepository ideaRepository,
    required CommentRepository commentRepository,
  })  : _ideaRepository = ideaRepository,
        _commentRepository = commentRepository,
        super(const IdeaControllerState());

  /// Create new idea
  Future<String?> createIdea({
    required String title,
    required String description,
    required String category,
    required String budget,
    GeoPoint? location,
    List<File>? photos,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('🚀 Creating idea: $title');
      final ideaId = await _ideaRepository.createIdea(
        title: title,
        description: description,
        category: category,
        budget: budget,
        location: location,
        photos: photos,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timed out. Please check your internet connection.');
        },
      );

      print('✅ Idea created successfully: $ideaId');
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Idea proposed successfully! +3 points',
      );

      return ideaId;
    } catch (e) {
      print('❌ Error creating idea: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Vote on idea
  Future<bool> voteOnIdea(String ideaId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _ideaRepository.voteOnIdea(ideaId);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Vote recorded! +1 point',
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

  /// Remove vote
  Future<bool> removeVote(String ideaId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _ideaRepository.removeVote(ideaId);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Vote removed',
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

  /// Add comment
  Future<bool> addComment(String ideaId, String commentText) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _commentRepository.addComment(ideaId, commentText);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Comment added! +1 point',
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

  /// Like comment
  Future<bool> likeComment(String ideaId, String commentId) async {
    try {
      await _commentRepository.likeComment(ideaId, commentId);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Unlike comment
  Future<bool> unlikeComment(String ideaId, String commentId) async {
    try {
      await _commentRepository.unlikeComment(ideaId, commentId);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Delete comment
  Future<bool> deleteComment(String ideaId, String commentId) async {
    try {
      await _commentRepository.deleteComment(ideaId, commentId);
      state = state.copyWith(successMessage: 'Comment deleted');
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Update idea status (officials only)
  Future<bool> updateStatus(String ideaId, String status) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _ideaRepository.updateIdeaStatus(ideaId, status);

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

  /// Add official response
  Future<bool> addResponse(String ideaId, String response) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _ideaRepository.addOfficialResponse(ideaId, response);

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

  /// Delete idea
  Future<bool> deleteIdea(String ideaId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _ideaRepository.deleteIdea(ideaId);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Idea deleted successfully',
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
