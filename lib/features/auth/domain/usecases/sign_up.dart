import '../../data/repositories/auth_repository.dart';
import '../entities/user.dart';

/// Sign up use case
class SignUp {
  final AuthRepository _repository;

  SignUp(this._repository);

  Future<User> call({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return await _repository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}
