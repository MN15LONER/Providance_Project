import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../issues/domain/entities/issue.dart';
import '../../domain/repositories/admin_issue_repository.dart';

/// Admin issue repository provider
final adminIssueRepositoryProvider = Provider<AdminIssueRepository>((ref) {
  return AdminIssueRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

/// Admin issues stream provider - provides all issues with admin privileges
final adminIssuesProvider = StreamProvider<List<Issue>>((ref) {
  final repository = ref.watch(adminIssueRepositoryProvider);
  return repository.getAdminIssues();
});