import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

/// AuthRepositoryImpl — In production, delegates to RemoteDataSource (Dio).
/// For now, uses mock data that mirrors real Django REST responses.
class AuthRepositoryImpl implements AuthRepository {
  // Inject remoteDataSource here when backend is ready:
  // AuthRepositoryImpl(this._remoteDataSource);
  // final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1200));

      // Stub validation — replace with actual API call:
      // final response = await _remoteDataSource.login(email, password, role);
      if (email.isEmpty || password.length < 6) {
        return const Left(AuthFailure('Invalid credentials.'));
      }

      final user = UserModel.mock(role);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    // Clear tokens from shared_preferences
    return const Right(null);
  }

  @override
  Future<Either<Failure, UserEntity?>> getCachedUser() async {
    // In production: read from SharedPreferences/secure storage
    return const Right(null);
  }
}
