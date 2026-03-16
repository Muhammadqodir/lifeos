import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/security_settings.dart';
import '../../domain/repositories/security_repository.dart';
import 'security_event.dart';
import 'security_state.dart';

class SecurityBloc extends Bloc<SecurityEvent, SecurityState> {
  final SecurityRepository repository;

  SecurityBloc({required this.repository}) : super(SecurityInitial()) {
    on<SecurityCheckRequested>(_onCheckRequested);
    on<SecuritySetPasscodeRequested>(_onSetPasscodeRequested);
    on<SecurityVerifyPasscodeRequested>(_onVerifyPasscodeRequested);
    on<SecurityBiometricAuthRequested>(_onBiometricAuthRequested);
    on<SecurityUnlockSuccessful>(_onUnlockSuccessful);
    on<SecurityClearPasscodeRequested>(_onClearPasscodeRequested);
  }

  Future<void> _onCheckRequested(
    SecurityCheckRequested event,
    Emitter<SecurityState> emit,
  ) async {
    try {
      emit(SecurityLoading());
      
      final hasPasscode = await repository.hasPasscode();
      
      if (hasPasscode) {
        final biometricEnabled = await repository.isBiometricEnabled();
        final biometricAvailable = await repository.isBiometricAvailable();
        
        emit(SecurityLocked(
          biometricAvailable: biometricAvailable,
          biometricEnabled: biometricEnabled,
        ));
      } else {
        final biometricAvailable = await repository.isBiometricAvailable();
        
        emit(SecuritySettingsLoaded(
          settings: SecuritySettings(
            hasPasscode: false,
            biometricEnabled: false,
            biometricAvailable: biometricAvailable,
          ),
        ));
      }
    } catch (e) {
      emit(SecurityError(message: e.toString()));
    }
  }

  Future<void> _onSetPasscodeRequested(
    SecuritySetPasscodeRequested event,
    Emitter<SecurityState> emit,
  ) async {
    try {
      emit(SecurityLoading());
      
      await repository.setPasscode(event.passcode, event.enableBiometric);
      
      emit(SecurityPasscodeSet());
      
      // Load updated settings
      final biometricAvailable = await repository.isBiometricAvailable();
      final biometricEnabled = await repository.isBiometricEnabled();
      
      emit(SecuritySettingsLoaded(
        settings: SecuritySettings(
          hasPasscode: true,
          biometricEnabled: biometricEnabled,
          biometricAvailable: biometricAvailable,
        ),
      ));
    } catch (e) {
      emit(SecurityError(message: e.toString()));
    }
  }

  Future<void> _onVerifyPasscodeRequested(
    SecurityVerifyPasscodeRequested event,
    Emitter<SecurityState> emit,
  ) async {
    try {
      final isValid = await repository.verifyPasscode(event.passcode);
      
      if (isValid) {
        emit(SecurityUnlocked());
      } else {
        emit(const SecurityVerificationFailed(message: 'Invalid passcode'));
        
        // Return to locked state
        final biometricEnabled = await repository.isBiometricEnabled();
        final biometricAvailable = await repository.isBiometricAvailable();
        
        emit(SecurityLocked(
          biometricAvailable: biometricAvailable,
          biometricEnabled: biometricEnabled,
        ));
      }
    } catch (e) {
      emit(SecurityError(message: e.toString()));
    }
  }

  Future<void> _onBiometricAuthRequested(
    SecurityBiometricAuthRequested event,
    Emitter<SecurityState> emit,
  ) async {
    try {
      final authenticated = await repository.authenticateWithBiometrics();
      
      if (authenticated) {
        emit(SecurityUnlocked());
      } else {
        emit(const SecurityVerificationFailed(message: 'Biometric authentication failed'));
        
        // Return to locked state
        final biometricEnabled = await repository.isBiometricEnabled();
        final biometricAvailable = await repository.isBiometricAvailable();
        
        emit(SecurityLocked(
          biometricAvailable: biometricAvailable,
          biometricEnabled: biometricEnabled,
        ));
      }
    } catch (e) {
      emit(SecurityError(message: e.toString()));
    }
  }

  Future<void> _onUnlockSuccessful(
    SecurityUnlockSuccessful event,
    Emitter<SecurityState> emit,
  ) async {
    emit(SecurityUnlocked());
  }

  Future<void> _onClearPasscodeRequested(
    SecurityClearPasscodeRequested event,
    Emitter<SecurityState> emit,
  ) async {
    try {
      emit(SecurityLoading());
      
      await repository.clearPasscode();
      
      emit(SecurityPasscodeCleared());
      
      final biometricAvailable = await repository.isBiometricAvailable();
      
      emit(SecuritySettingsLoaded(
        settings: SecuritySettings(
          hasPasscode: false,
          biometricEnabled: false,
          biometricAvailable: biometricAvailable,
        ),
      ));
    } catch (e) {
      emit(SecurityError(message: e.toString()));
    }
  }
}
