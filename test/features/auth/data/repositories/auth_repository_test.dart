import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:muni_report_pro/features/auth/data/repositories/auth_repository.dart';

void main() {
  group('AuthRepository', () {
    late AuthRepository authRepository;
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth(signedIn: false);
      fakeFirestore = FakeFirebaseFirestore();
      authRepository = AuthRepository(
        auth: mockAuth,
        firestore: fakeFirestore,
      );
    });

    group('signUpWithEmail', () {
      test('creates user and Firestore document successfully', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const name = 'Test User';
        const role = 'citizen';

        // Act
        final result = await authRepository.signUpWithEmail(
          email: email,
          password: password,
          name: name,
          role: role,
        );

        // Assert
        expect(result, isNotNull);
        expect(mockAuth.currentUser, isNotNull);
        expect(mockAuth.currentUser?.email, email);

        // Verify Firestore document was created
        final userDoc = await fakeFirestore
            .collection('users')
            .doc(mockAuth.currentUser!.uid)
            .get();
        expect(userDoc.exists, true);
        expect(userDoc.data()?['email'], email);
        expect(userDoc.data()?['name'], name);
        expect(userDoc.data()?['role'], role);
      });

      test('throws error when email is already in use', () async {
        // Arrange
        const email = 'existing@example.com';
        await mockAuth.createUserWithEmailAndPassword(
          email: email,
          password: 'password',
        );

        // Act & Assert
        expect(
          () => authRepository.signUpWithEmail(
            email: email,
            password: 'newpassword',
            name: 'New User',
            role: 'citizen',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('signInWithEmail', () {
      test('signs in user successfully', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        // Create user first
        await mockAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await mockAuth.signOut();

        // Act
        final result = await authRepository.signInWithEmail(
          email: email,
          password: password,
        );

        // Assert
        expect(result, isNotNull);
        expect(mockAuth.currentUser, isNotNull);
        expect(mockAuth.currentUser?.email, email);
      });

      test('throws error with invalid credentials', () async {
        // Act & Assert
        expect(
          () => authRepository.signInWithEmail(
            email: 'nonexistent@example.com',
            password: 'wrongpassword',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('signOut', () {
      test('signs out user successfully', () async {
        // Arrange
        await mockAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password',
        );
        expect(mockAuth.currentUser, isNotNull);

        // Act
        await authRepository.signOut();

        // Assert
        expect(mockAuth.currentUser, isNull);
      });
    });

    group('getCurrentUser', () {
      test('returns current user when signed in', () async {
        // Arrange
        await mockAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password',
        );

        // Act
        final user = authRepository.getCurrentUser();

        // Assert
        expect(user, isNotNull);
        expect(user?.email, 'test@example.com');
      });

      test('returns null when not signed in', () {
        // Act
        final user = authRepository.getCurrentUser();

        // Assert
        expect(user, isNull);
      });
    });

    group('authStateChanges', () {
      test('emits user when signed in', () async {
        // Arrange
        final stream = authRepository.authStateChanges();

        // Act
        await mockAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password',
        );

        // Assert
        expect(
          stream,
          emits(isNotNull),
        );
      });

      test('emits null when signed out', () async {
        // Arrange
        await mockAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password',
        );
        final stream = authRepository.authStateChanges();

        // Act
        await mockAuth.signOut();

        // Assert
        expect(
          stream,
          emits(isNull),
        );
      });
    });

    group('updateUserProfile', () {
      test('updates user profile successfully', () async {
        // Arrange
        await mockAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password',
        );
        final userId = mockAuth.currentUser!.uid;

        // Create initial user document
        await fakeFirestore.collection('users').doc(userId).set({
          'email': 'test@example.com',
          'name': 'Old Name',
          'role': 'citizen',
        });

        // Act
        await authRepository.updateUserProfile(
          userId: userId,
          data: {'name': 'New Name'},
        );

        // Assert
        final userDoc = await fakeFirestore
            .collection('users')
            .doc(userId)
            .get();
        expect(userDoc.data()?['name'], 'New Name');
      });
    });

    group('deleteAccount', () {
      test('deletes user account and Firestore document', () async {
        // Arrange
        await mockAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password',
        );
        final userId = mockAuth.currentUser!.uid;

        await fakeFirestore.collection('users').doc(userId).set({
          'email': 'test@example.com',
          'name': 'Test User',
        });

        // Act
        await authRepository.deleteAccount();

        // Assert
        expect(mockAuth.currentUser, isNull);

        final userDoc = await fakeFirestore
            .collection('users')
            .doc(userId)
            .get();
        expect(userDoc.exists, false);
      });
    });
  });
}
