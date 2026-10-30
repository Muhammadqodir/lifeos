import 'dart:async';

/// App-wide session signals raised by the network layer.
///
/// The [AuthInterceptor] reports an expired/revoked token here and the
/// AuthBloc listens, so the UI returns to the login screen instead of
/// showing parse errors on every screen.
class SessionEvents {
  final StreamController<void> _expired = StreamController<void>.broadcast();

  Stream<void> get onExpired => _expired.stream;

  void notifyExpired() => _expired.add(null);

  Future<void> dispose() => _expired.close();
}
