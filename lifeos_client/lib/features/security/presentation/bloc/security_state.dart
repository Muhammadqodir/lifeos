import 'package:equatable/equatable.dart';
import '../../domain/entities/security_settings.dart';

abstract class SecurityState extends Equatable {
  const SecurityState();

  @override
  List<Object?> get props => [];
}

class SecurityInitial extends SecurityState {}

class SecurityLoading extends SecurityState {}

class SecurityLocked extends SecurityState {
  final bool biometricAvailable;
  final bool biometricEnabled;

  const SecurityLocked({
    required this.biometricAvailable,
    required this.biometricEnabled,
  });

  @override
  List<Object?> get props => [biometricAvailable, biometricEnabled];
}

class SecurityUnlocked extends SecurityState {}

class SecuritySettingsLoaded extends SecurityState {
  final SecuritySettings settings;

  const SecuritySettingsLoaded({required this.settings});

  @override
  List<Object?> get props => [settings];
}

class SecurityPasscodeSet extends SecurityState {}

class SecurityPasscodeCleared extends SecurityState {}

class SecurityVerificationFailed extends SecurityState {
  final String message;

  const SecurityVerificationFailed({required this.message});

  @override
  List<Object?> get props => [message];
}

class SecurityError extends SecurityState {
  final String message;

  const SecurityError({required this.message});

  @override
  List<Object?> get props => [message];
}
