import 'package:equatable/equatable.dart';

/// Base failure class — extend for domain-specific failures.
abstract class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error. Please try again.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local cache error.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Invalid input.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
