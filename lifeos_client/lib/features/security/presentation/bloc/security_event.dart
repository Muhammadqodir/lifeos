import 'package:equatable/equatable.dart';

abstract class SecurityEvent extends Equatable {
  const SecurityEvent();

  @override
  List<Object?> get props => [];
}

class SecurityCheckRequested extends SecurityEvent {}

class SecuritySetPasscodeRequested extends SecurityEvent {
  final String passcode;
  final bool enableBiometric;

  const SecuritySetPasscodeRequested({
    required this.passcode,
    required this.enableBiometric,
  });

  @override
  List<Object?> get props => [passcode, enableBiometric];
}

class SecurityVerifyPasscodeRequested extends SecurityEvent {
  final String passcode;

  const SecurityVerifyPasscodeRequested({required this.passcode});

  @override
  List<Object?> get props => [passcode];
}

class SecurityBiometricAuthRequested extends SecurityEvent {}

class SecurityUnlockSuccessful extends SecurityEvent {}

class SecurityClearPasscodeRequested extends SecurityEvent {}
