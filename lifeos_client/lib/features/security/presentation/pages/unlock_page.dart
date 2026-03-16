import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/security_bloc.dart';
import '../bloc/security_event.dart';
import '../bloc/security_state.dart';
import '../widgets/passcode_input.dart';

class UnlockPage extends StatefulWidget {
  final VoidCallback onUnlocked;

  const UnlockPage({
    super.key,
    required this.onUnlocked,
  });

  @override
  State<UnlockPage> createState() => _UnlockPageState();
}

class _UnlockPageState extends State<UnlockPage> {
  bool _isError = false;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  bool _biometricAttempted = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  void _checkBiometric() {
    context.read<SecurityBloc>().add(SecurityCheckRequested());
  }

  void _handleBiometricAuth() {
    if (_biometricAvailable && _biometricEnabled) {
      setState(() {
        _biometricAttempted = true;
      });
      context.read<SecurityBloc>().add(SecurityBiometricAuthRequested());
    }
  }

  void _handlePasscodeCompleted(String passcode) {
    context.read<SecurityBloc>().add(
          SecurityVerifyPasscodeRequested(passcode: passcode),
        );
  }

  void _handlePasscodeChanged() {
    if (_isError) {
      setState(() {
        _isError = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<SecurityBloc, SecurityState>(
      listener: (context, state) {
        if (state is SecurityUnlocked) {
          widget.onUnlocked();
        } else if (state is SecurityVerificationFailed) {
          setState(() {
            _isError = true;
          });
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _isError = false;
              });
            }
          });
        } else if (state is SecurityLocked) {
          setState(() {
            _biometricAvailable = state.biometricAvailable;
            _biometricEnabled = state.biometricEnabled;
          });

          // Auto-trigger biometric auth if available and not yet attempted
          if (state.biometricAvailable &&
              state.biometricEnabled &&
              !_biometricAttempted) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _handleBiometricAuth();
              }
            });
          }
        }
      },
      child: Scaffold(
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 64),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          theme.colorScheme.foreground,
                          BlendMode.srcIn,
                        ),
                        child: Image.asset(
                          'assets/logo.png',
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Enter Passcode',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your passcode to unlock',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.mutedForeground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_isError) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Invalid passcode',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.destructive,
                        ),
                      ),
                    ],
                    const SizedBox(height: 48),
                    PasscodeInput(
                      onCompleted: _handlePasscodeCompleted,
                      onChanged: _handlePasscodeChanged,
                      isError: _isError,
                    ),
                    if (_biometricAvailable && _biometricEnabled) ...[
                      const SizedBox(height: 32),
                      OutlineButton(
                        onPressed: _handleBiometricAuth,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fingerprint,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text('Use Face ID'),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
