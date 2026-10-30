import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/session_events.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  /// Started for the signed-in user; cleared on sign-out.
  final SyncEngine? sync;
  StreamSubscription<void>? _sessionSubscription;

  AuthBloc({
    required this.authRepository,
    SessionEvents? sessionEvents,
    this.sync,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthSessionExpired>(_onAuthSessionExpired);
    _sessionSubscription = sessionEvents?.onExpired.listen(
      (_) => add(AuthSessionExpired()),
    );
  }

  @override
  Future<void> close() async {
    await _sessionSubscription?.cancel();
    return super.close();
  }

  void _onAuthSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) {
    // The interceptor already cleared the token; only react while signed in.
    // Local data stays, so unsent changes survive signing in again.
    if (state is AuthAuthenticated) {
      sync?.stop();
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthChecking());
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        await sync?.start('${user.id}');
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

    try {
      final result = await authRepository.login(event.email, event.password);
      await sync?.start('${result.user.id}');
      emit(AuthAuthenticated(user: result.user));
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      emit(AuthError(message: errorMessage));
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

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
      await sync?.start('${result.user.id}');
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
    // Push what's left, then remove this account's data from the device.
    await sync?.signOut();
    try {
      await authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }
}
