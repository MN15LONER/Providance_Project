import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/discussions_repository.dart';
import '../../domain/entities/discussion.dart';
import '../../domain/entities/discussion_comment.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Discussions repository provider
final discussionsRepositoryProvider = Provider<DiscussionsRepository>((ref) {
  return DiscussionsRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

/// All discussions stream provider
final discussionsProvider = StreamProvider<List<Discussion>>((ref) {
  final repository = ref.watch(discussionsRepositoryProvider);
  final userModel = ref.watch(currentUserModelProvider).value;
  
  return repository.getDiscussions(
    municipality: userModel?.municipality,
  );
});

/// Single discussion stream provider
final discussionProvider = StreamProvider.family<Discussion?, String>((ref, discussionId) {
  final repository = ref.watch(discussionsRepositoryProvider);
  return repository.getDiscussion(discussionId);
});

/// Discussion comments stream provider
final discussionCommentsProvider = StreamProvider.family<List<DiscussionComment>, String>((ref, discussionId) {
  final repository = ref.watch(discussionsRepositoryProvider);
  return repository.getComments(discussionId);
});

/// Discussion controller for actions
final discussionControllerProvider = Provider<DiscussionController>((ref) {
  return DiscussionController(
    repository: ref.watch(discussionsRepositoryProvider),
  );
});

/// Controller for discussion actions
class DiscussionController {
  final DiscussionsRepository repository;

  DiscussionController({required this.repository});

  Future<String> createDiscussion({
    required String title,
    required String content,
    required String municipality,
    String? ward,
    List<String> tags = const [],
  }) async {
    return await repository.createDiscussion(
      title: title,
      content: content,
      municipality: municipality,
      ward: ward,
      tags: tags,
    );
  }

  Future<void> updateDiscussion({
    required String discussionId,
    String? title,
    String? content,
    List<String>? tags,
  }) async {
    await repository.updateDiscussion(
      discussionId: discussionId,
      title: title,
      content: content,
      tags: tags,
    );
  }

  Future<void> deleteDiscussion(String discussionId) async {
    await repository.deleteDiscussion(discussionId);
  }

  Future<void> toggleLikeDiscussion(String discussionId) async {
    await repository.toggleLikeDiscussion(discussionId);
  }

  Future<String> addComment({
    required String discussionId,
    required String content,
  }) async {
    return await repository.addComment(
      discussionId: discussionId,
      content: content,
    );
  }

  Future<void> deleteComment(String commentId, String discussionId) async {
    await repository.deleteComment(commentId, discussionId);
  }

  Future<void> toggleLikeComment(String commentId) async {
    await repository.toggleLikeComment(commentId);
  }
}
