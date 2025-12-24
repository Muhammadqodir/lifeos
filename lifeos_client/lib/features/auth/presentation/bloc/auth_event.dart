import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String? fatherName;
  final DateTime? dateOfBirth;
  final String email;
  final String password;
  final String passwordConfirmation;

  const AuthRegisterRequested({
    required this.firstName,
    required this.lastName,
    this.fatherName,
    this.dateOfBirth,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        fatherName,
        dateOfBirth,
        email,
        password,
        passwordConfirmation,
      ];
}

class AuthLogoutRequested extends AuthEvent {}
