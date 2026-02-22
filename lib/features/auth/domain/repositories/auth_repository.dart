import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
    required UserRole role,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, UserEntity?>> getCachedUser();
}
