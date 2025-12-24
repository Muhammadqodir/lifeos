import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    // Add delay to simulate network request
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      final result = await authRepository.login(event.email, event.password);
      emit(AuthAuthenticated(user: result.user));
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      print(errorMessage);
      emit(AuthError(message: errorMessage));
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    // Add delay to simulate network request
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      final params = RegisterParams(
        firstName: event.firstName,
        lastName: event.lastName,
        fatherName: event.fatherName,
        dateOfBirth: event.dateOfBirth,
        email: event.email,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
      );
      final result = await authRepository.register(params);
      emit(AuthAuthenticated(user: result.user));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }
}
