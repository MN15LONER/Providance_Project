import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../admin/data/repositories/admin_repository.dart';
import '../../../admin/domain/entities/announcement.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Admin repository provider
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

/// Announcements stream provider
final announcementsProvider = StreamProvider<List<Announcement>>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  final userModel = ref.watch(currentUserModelProvider).value;
  
  return repository.getAnnouncements(
    municipality: userModel?.municipality,
    activeOnly: true,
  );
});

/// Recent announcements provider (limited to 3)
final recentAnnouncementsProvider = Provider<List<Announcement>>((ref) {
  final announcementsAsync = ref.watch(announcementsProvider);
  
  return announcementsAsync.when(
    data: (announcements) => announcements.take(3).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});
