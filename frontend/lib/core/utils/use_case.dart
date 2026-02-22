import 'package:dartz/dartz.dart';
import 'failure.dart';

/// Abstract use case with params.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Abstract use case with no params.
abstract class UseCaseNoParams<Type> {
  Future<Either<Failure, Type>> call();
}

/// Marker class for use cases that take no parameters.
class NoParams {}
