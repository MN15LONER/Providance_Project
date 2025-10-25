import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:muni_report_pro/features/issues/data/repositories/issue_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('IssueRepository', () {
    late IssueRepository issueRepository;
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth(signedIn: true);
      fakeFirestore = FakeFirebaseFirestore();
      issueRepository = IssueRepository(
        firestore: fakeFirestore,
        auth: mockAuth,
        locationService: null, // Mock if needed
      );
    });

    group('createIssue', () {
      test('creates issue successfully', () async {
        // Arrange
        const title = 'Test Pothole';
        const description = 'Large pothole on main road';
        const category = 'Potholes';
        const severity = 'High';
        final location = GeoPoint(-26.2041, 28.0473);

        // Act
        final issueId = await issueRepository.createIssue(
          title: title,
          description: description,
          category: category,
          severity: severity,
          location: location,
        );

        // Assert
        expect(issueId, isNotEmpty);

        final issueDoc = await fakeFirestore
            .collection('issues')
            .doc(issueId)
            .get();
        expect(issueDoc.exists, true);
        expect(issueDoc.data()?['title'], title);
        expect(issueDoc.data()?['description'], description);
        expect(issueDoc.data()?['category'], category);
        expect(issueDoc.data()?['severity'], severity);
        expect(issueDoc.data()?['status'], 'Open');
      });

      test('sets reportedBy to current user', () async {
        // Act
        final issueId = await issueRepository.createIssue(
          title: 'Test Issue',
          description: 'Test Description',
          category: 'Potholes',
          severity: 'Medium',
        );

        // Assert
        final issueDoc = await fakeFirestore
            .collection('issues')
            .doc(issueId)
            .get();
        expect(issueDoc.data()?['reportedBy'], mockAuth.currentUser!.uid);
      });
    });

    group('getIssues', () {
      setUp(() async {
        // Create test issues
        await fakeFirestore.collection('issues').add({
          'title': 'Issue 1',
          'description': 'Description 1',
          'category': 'Potholes',
          'severity': 'High',
          'status': 'Open',
          'reportedBy': 'user1',
          'createdAt': Timestamp.now(),
        });

        await fakeFirestore.collection('issues').add({
          'title': 'Issue 2',
          'description': 'Description 2',
          'category': 'Streetlights',
          'severity': 'Medium',
          'status': 'In Progress',
          'reportedBy': 'user2',
          'createdAt': Timestamp.now(),
        });
      });

      test('returns all issues', () async {
        // Act
        final stream = issueRepository.getIssues();
        final issues = await stream.first;

        // Assert
        expect(issues.length, 2);
      });

      test('filters by category', () async {
        // Act
        final stream = issueRepository.getIssues(category: 'Potholes');
        final issues = await stream.first;

        // Assert
        expect(issues.length, 1);
        expect(issues.first.category, 'Potholes');
      });

      test('filters by status', () async {
        // Act
        final stream = issueRepository.getIssues(status: 'Open');
        final issues = await stream.first;

        // Assert
        expect(issues.length, 1);
        expect(issues.first.status, 'Open');
      });

      test('filters by userId', () async {
        // Act
        final stream = issueRepository.getIssues(userId: 'user1');
        final issues = await stream.first;

        // Assert
        expect(issues.length, 1);
        expect(issues.first.reportedBy, 'user1');
      });
    });

    group('getIssueById', () {
      test('returns issue when exists', () async {
        // Arrange
        final docRef = await fakeFirestore.collection('issues').add({
          'title': 'Test Issue',
          'description': 'Test Description',
          'category': 'Potholes',
          'severity': 'High',
          'status': 'Open',
          'reportedBy': 'user1',
          'createdAt': Timestamp.now(),
        });

        // Act
        final issue = await issueRepository.getIssueById(docRef.id);

        // Assert
        expect(issue, isNotNull);
        expect(issue.title, 'Test Issue');
      });

      test('throws error when issue not found', () async {
        // Act & Assert
        expect(
          () => issueRepository.getIssueById('nonexistent'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('updateIssueStatus', () {
      test('updates status successfully', () async {
        // Arrange
        final docRef = await fakeFirestore.collection('issues').add({
          'title': 'Test Issue',
          'status': 'Open',
          'reportedBy': 'user1',
          'createdAt': Timestamp.now(),
        });

        // Act
        await issueRepository.updateIssueStatus(docRef.id, 'In Progress');

        // Assert
        final issueDoc = await fakeFirestore
            .collection('issues')
            .doc(docRef.id)
            .get();
        expect(issueDoc.data()?['status'], 'In Progress');
      });
    });

    group('verifyIssue', () {
      test('adds verification successfully', () async {
        // Arrange
        final docRef = await fakeFirestore.collection('issues').add({
          'title': 'Test Issue',
          'status': 'Open',
          'reportedBy': 'user1',
          'verifications': [],
          'createdAt': Timestamp.now(),
        });

        // Act
        await issueRepository.verifyIssue(docRef.id);

        // Assert
        final issueDoc = await fakeFirestore
            .collection('issues')
            .doc(docRef.id)
            .get();
        final verifications = issueDoc.data()?['verifications'] as List;
        expect(verifications.length, 1);
        expect(verifications.first['userId'], mockAuth.currentUser!.uid);
      });

      test('prevents duplicate verification', () async {
        // Arrange
        final userId = mockAuth.currentUser!.uid;
        final docRef = await fakeFirestore.collection('issues').add({
          'title': 'Test Issue',
          'status': 'Open',
          'reportedBy': 'user1',
          'verifications': [
            {'userId': userId, 'timestamp': Timestamp.now()}
          ],
          'createdAt': Timestamp.now(),
        });

        // Act & Assert
        expect(
          () => issueRepository.verifyIssue(docRef.id),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('deleteIssue', () {
      test('deletes issue successfully', () async {
        // Arrange
        final docRef = await fakeFirestore.collection('issues').add({
          'title': 'Test Issue',
          'reportedBy': mockAuth.currentUser!.uid,
          'createdAt': Timestamp.now(),
        });

        // Act
        await issueRepository.deleteIssue(docRef.id);

        // Assert
        final issueDoc = await fakeFirestore
            .collection('issues')
            .doc(docRef.id)
            .get();
        expect(issueDoc.exists, false);
      });
    });

    group('getIssuesCountByStatus', () {
      setUp(() async {
        await fakeFirestore.collection('issues').add({
          'status': 'Open',
          'createdAt': Timestamp.now(),
        });
        await fakeFirestore.collection('issues').add({
          'status': 'Open',
          'createdAt': Timestamp.now(),
        });
        await fakeFirestore.collection('issues').add({
          'status': 'In Progress',
          'createdAt': Timestamp.now(),
        });
        await fakeFirestore.collection('issues').add({
          'status': 'Resolved',
          'createdAt': Timestamp.now(),
        });
      });

      test('returns correct counts', () async {
        // Act
        final counts = await issueRepository.getIssuesCountByStatus();

        // Assert
        expect(counts['Open'], 2);
        expect(counts['In Progress'], 1);
        expect(counts['Resolved'], 1);
      });
    });
  });
}
