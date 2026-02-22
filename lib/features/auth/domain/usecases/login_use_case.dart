import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  const LoginParams({
    required this.email,
    required this.password,
    required this.role,
  });
  final String email;
  final String password;
  final UserRole role;
}

class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  const LoginUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) {
    return _repository.login(
      email: params.email,
      password: params.password,
      role: params.role,
    );
  }
}
