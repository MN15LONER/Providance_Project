import '../../data/repositories/auth_repository.dart';
import '../entities/user.dart';

/// Sign in use case
class SignIn {
  final AuthRepository _repository;

  SignIn(this._repository);

  Future<User> call({
    required String email,
    required String password,
  }) async {
    return await _repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
