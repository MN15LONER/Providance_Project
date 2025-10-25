import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:muni_report_pro/features/auth/domain/repositories/auth_repository.dart';
import 'auth_repository_provider.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<User?>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository);
});

class AuthController extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _authRepository;

  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.getCurrentUser();
      state = user != null ? AsyncValue.data(user) : const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      await _authRepository.signIn(email, password);
      final user = await _authRepository.getCurrentUser();
      return user;
    });
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      await _authRepository.signUp(email, password);
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        await _authRepository.completeProfileSetup(
          user.uid,
          user.displayName ?? 'User',
          user.phoneNumber ?? '',
          'citizen',
          null,
          null,
        );
      }
      return user;
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      await _authRepository.signOut();
      return null;
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      await _authRepository.signInWithGoogle();
      final user = await _authRepository.getCurrentUser();
      return user;
    });
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      await _authRepository.resetPassword(email);
      return null;
    });
  }

  Future<void> completeProfileSetup(
    String uid,
    String displayName,
    String phoneNumber,
    String role,
    String? ward,
    String? municipality,
  ) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      await _authRepository.completeProfileSetup(
        uid,
        displayName,
        phoneNumber,
        role,
        ward,
        municipality,
      );
      
      // Refresh the user data
      final updatedUser = await _authRepository.getCurrentUser();
      return updatedUser;
    });
  }

  // Get the current user stream
  Stream<User?> get userStream => _authRepository.authStateChanges();
}
