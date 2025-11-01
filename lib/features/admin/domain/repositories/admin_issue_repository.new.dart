import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../issues/domain/entities/issue.dart';
import '../../../issues/data/models/issue_model.dart';

class AdminIssueRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Issue>> getAllIssues() {
    return _firestore
        .collection('issues')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => IssueModel.fromFirestore(doc))
              .toList();
        });
  }

  Stream<List<Map<String, dynamic>>> getAdminIssues({
    String? status,
    String? category,
    String? severity,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection('issues');

    if (status != null && status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    }
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    if (severity != null && severity.isNotEmpty) {
      query = query.where('severity', isEqualTo: severity);
    }

    query = query.orderBy('createdAt', descending: true);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> updateIssueStatus(String issueId, String newStatus) async {
    await _firestore.collection('issues').doc(issueId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
      'lastUpdatedBy': _auth.currentUser?.uid,
    });
  }

  Future<void> deleteIssue(String issueId) async {
    await _firestore.collection('issues').doc(issueId).delete();
  }

  Future<void> assignIssueToDepartment(
    String issueId,
    String department,
  ) async {
    await _firestore.collection('issues').doc(issueId).update({
      'assignedDepartment': department,
      'updatedAt': FieldValue.serverTimestamp(),
      'assignedBy': _auth.currentUser?.uid,
    });
  }

  Future<void> addIssueUpdate(
    String issueId,
    String message,
  ) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data();
    if (userData == null) throw Exception('User data not found');

    await _firestore
        .collection('issues')
        .doc(issueId)
        .collection('updates')
        .add({
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': userId,
      'createdByName': userData['displayName'] ?? 'Unknown Admin',
      'createdByPhoto': userData['photoURL'],
      'type': 'admin_update',
    });
  }
}