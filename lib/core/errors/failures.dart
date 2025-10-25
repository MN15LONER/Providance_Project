/// Base failure class
abstract class Failure {
  final String message;
  
  const Failure(this.message);
  
  @override
  String toString() => message;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.message == message;
  }
  
  @override
  int get hashCode => message.hashCode;
}

/// Server failure
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Permission failure
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// Location failure
class LocationFailure extends Failure {
  const LocationFailure(super.message);
}

/// Storage failure
class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

/// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Already exists failure
class AlreadyExistsFailure extends Failure {
  const AlreadyExistsFailure(super.message);
}

/// Data failure
class DataFailure extends Failure {
  const DataFailure(super.message);
}
