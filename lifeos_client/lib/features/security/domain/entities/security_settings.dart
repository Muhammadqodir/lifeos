import 'package:equatable/equatable.dart';

class SecuritySettings extends Equatable {
  final bool hasPasscode;
  final bool biometricEnabled;
  final bool biometricAvailable;

  const SecuritySettings({
    required this.hasPasscode,
    required this.biometricEnabled,
    required this.biometricAvailable,
  });

  SecuritySettings copyWith({
    bool? hasPasscode,
    bool? biometricEnabled,
    bool? biometricAvailable,
  }) {
    return SecuritySettings(
      hasPasscode: hasPasscode ?? this.hasPasscode,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
    );
  }

  @override
  List<Object?> get props => [hasPasscode, biometricEnabled, biometricAvailable];
}
