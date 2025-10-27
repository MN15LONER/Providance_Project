import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/errors/failures.dart';
import '../models/idea_model.dart';
import '../../domain/entities/idea.dart';

/// Repository for idea operations
class IdeaRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;
  final LocationService _locationService;

  IdeaRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
    LocationService? locationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _locationService = locationService ?? LocationService();

  /// Create a new idea
  Future<String> createIdea({
    required String title,
    required String description,
    required String category,
    required String budget,
    GeoPoint? location,
    List<File>? photos,
  }) async {
    try {
      // Get current user
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthFailure('User not authenticated');
      }

      // Get user profile
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        throw const DataFailure('User profile not found');
      }

      final userData = userDoc.data()!;

      // Upload photos if provided
      final photoUrls = <String>[];
      if (photos != null && photos.isNotEmpty) {
        for (int i = 0; i < photos.length; i++) {
          // Compress image
          final compressed = await ImageUtils.compressImage(
            photos[i],
            quality: 70,
          );

          if (compressed != null) {
            // Upload to storage
            final url = await ImageUtils.uploadToStorage(
              compressed,
              'ideas/${DateTime.now().millisecondsSinceEpoch}_$i',
              userId: user.uid,
              metadata: {
                'category': category,
                'budget': budget,
              },
            );
            photoUrls.add(url);

            // Clean up compressed file
            if (compressed.path != photos[i].path) {
              await compressed.delete();
            }
          }
        }
      }

      // Get location name if location provided
      String? locationName;
      if (location != null) {
        locationName = await _locationService.getAddressFromCoordinates(
          location.latitude,
          location.longitude,
        );
      }

      // Create idea document
      final ideaData = {
        'createdBy': user.uid,
        'creatorName': userData['displayName'] ?? 'Unknown',
        'creatorPhoto': userData['photoURL'],
        'title': title,
        'description': description,
        'category': category,
        'budget': budget,
        'status': 'open',
        'location': location,
        'locationName': locationName,
        'ward': userData['ward'],
        'photos': photoUrls,
        'voteCount': 0,
        'voters': [],
        'commentCount': 0,
        'officialResponse': null,
        'respondedAt': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('ideas').add(ideaData);

      // Award points for proposing an idea
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'points': FieldValue.increment(15),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Create points history entry
        await _firestore.collection('points_history').add({
          'userId': user.uid,
          'points': 15,
          'action': 'Proposed an idea',
          'referenceId': docRef.id,
          'referenceType': 'idea',
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        // Don't fail the idea creation if points fail
        print('Failed to award points: $e');
      }

      return docRef.id;
    } catch (e) {
      if (e is Failure) rethrow;
      throw DataFailure('Failed to create idea: $e');
    }
  }

  /// Get ideas stream with optional filters
  Stream<List<Idea>> getIdeas({
    String? status,
    String? category,
    String? userId,
    String? ward,
    String sortBy = 'voteCount',
    int? limit,
  }) {
    try {
      Query query = _firestore.collection('ideas');

      // Apply filters
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }
      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      if (userId != null) {
        query = query.where('createdBy', isEqualTo: userId);
      }
      if (ward != null) {
        query = query.where('ward', isEqualTo: ward);
      }

      // Order by specified field
      query = query.orderBy(sortBy, descending: true);

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return IdeaModel.fromFirestore(doc).toEntity();
        }).toList();
      });
    } catch (e) {
      throw DataFailure('Failed to get ideas: $e');
    }
  }

  /// Get single idea by ID
  Future<Idea> getIdeaById(String ideaId) async {
    try {
      final doc = await _firestore.collection('ideas').doc(ideaId).get();

      if (!doc.exists) {
        throw const DataFailure('Idea not found');
      }

      return IdeaModel.fromFirestore(doc).toEntity();
    } catch (e) {
      if (e is Failure) rethrow;
      throw DataFailure('Failed to get idea: $e');
    }
  }

  /// Get idea stream by ID
  Stream<Idea> getIdeaStream(String ideaId) {
    try {
      return _firestore
          .collection('ideas')
          .doc(ideaId)
          .snapshots()
          .map((doc) {
        if (!doc.exists) {
          throw const DataFailure('Idea not found');
        }
        return IdeaModel.fromFirestore(doc).toEntity();
      });
    } catch (e) {
      throw DataFailure('Failed to stream idea: $e');
    }
  }

  /// Vote on an idea
  Future<void> voteOnIdea(String ideaId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthFailure('User not authenticated');
      }

      final ideaRef = _firestore.collection('ideas').doc(ideaId);
      final idea = await ideaRef.get();

      if (!idea.exists) {
        throw const DataFailure('Idea not found');
      }

      final voters = List<String>.from(idea.data()!['voters'] ?? []);

      // Check if user already voted
      if (voters.contains(user.uid)) {
        throw const DataFailure('You have already voted on this idea');
      }

      // Add vote
      voters.add(user.uid);

      await ideaRef.update({
        'voters': voters,
        'voteCount': voters.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create vote document for tracking
      await _firestore.collection('votes').add({
        'userId': user.uid,
        'ideaId': ideaId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Award points for voting
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'points': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Create points history entry
        await _firestore.collection('points_history').add({
          'userId': user.uid,
          'points': 1,
          'action': 'Voted on idea',
          'referenceId': ideaId,
          'referenceType': 'idea',
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        // Don't fail the vote if points fail
        print('Failed to award points: $e');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw DataFailure('Failed to vote on idea: $e');
    }
  }

  /// Remove vote from an idea
  Future<void> removeVote(String ideaId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthFailure('User not authenticated');
      }

      final ideaRef = _firestore.collection('ideas').doc(ideaId);
      final idea = await ideaRef.get();

      if (!idea.exists) {
        throw const DataFailure('Idea not found');
      }

      final voters = List<String>.from(idea.data()!['voters'] ?? []);

      // Check if user has voted
      if (!voters.contains(user.uid)) {
        throw const DataFailure('You have not voted on this idea');
      }

      // Remove vote
      voters.remove(user.uid);

      await ideaRef.update({
        'voters': voters,
        'voteCount': voters.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Delete vote document
      final voteQuery = await _firestore
          .collection('votes')
          .where('userId', isEqualTo: user.uid)
          .where('ideaId', isEqualTo: ideaId)
          .get();

      for (final doc in voteQuery.docs) {
        await doc.reference.delete();
      }

      // Deduct points for removing vote
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'points': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Create points history entry
        await _firestore.collection('points_history').add({
          'userId': user.uid,
          'points': -1,
          'action': 'Removed vote from idea',
          'referenceId': ideaId,
          'referenceType': 'idea',
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        // Don't fail the vote removal if points fail
        print('Failed to deduct points: $e');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw DataFailure('Failed to remove vote: $e');
    }
  }

  /// Check if user has voted on an idea
  Future<bool> hasVoted(String ideaId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final idea = await _firestore.collection('ideas').doc(ideaId).get();

      if (!idea.exists) return false;

      final voters = List<String>.from(idea.data()!['voters'] ?? []);
      return voters.contains(user.uid);
    } catch (e) {
      return false;
    }
  }

  /// Update idea status
  Future<void> updateIdeaStatus(String ideaId, String status) async {
    try {
      await _firestore.collection('ideas').doc(ideaId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw DataFailure('Failed to update idea status: $e');
    }
  }

  /// Add official response
  Future<void> addOfficialResponse(
    String ideaId,
    String response,
  ) async {
    try {
      await _firestore.collection('ideas').doc(ideaId).update({
        'officialResponse': response,
        'respondedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw DataFailure('Failed to add response: $e');
    }
  }

  /// Delete idea (admin only)
  Future<void> deleteIdea(String ideaId) async {
    try {
      final ideaDoc = await _firestore.collection('ideas').doc(ideaId).get();

      if (!ideaDoc.exists) {
        throw const DataFailure('Idea not found');
      }

      final idea = IdeaModel.fromFirestore(ideaDoc);

      // Delete photos from storage
      if (idea.photos.isNotEmpty) {
        await ImageUtils.deleteMultipleFromStorage(idea.photos);
      }

      // Delete idea document
      await _firestore.collection('ideas').doc(ideaId).delete();
    } catch (e) {
      if (e is Failure) rethrow;
      throw DataFailure('Failed to delete idea: $e');
    }
  }

  /// Get ideas count by status
  Future<Map<String, int>> getIdeasCountByStatus() async {
    try {
      final snapshot = await _firestore.collection('ideas').get();

      final counts = <String, int>{
        'open': 0,
        'under_review': 0,
        'approved': 0,
        'rejected': 0,
        'implemented': 0,
      };

      for (final doc in snapshot.docs) {
        final status = doc.data()['status'] as String;
        counts[status] = (counts[status] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      throw DataFailure('Failed to get ideas count: $e');
    }
  }
}
