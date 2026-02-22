import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  const LoginRequested({
    required this.email,
    required this.password,
    required this.role,
  });
  final String email;
  final String password;
  final UserRole role;

  @override
  List<Object?> get props => [email, password, role];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final UserEntity user;

  @override
  List<Object?> get props => [user.id];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
