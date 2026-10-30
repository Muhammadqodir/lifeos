import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../widgets/passcode_prompt.dart';
import '../../../../core/ui/ui.dart';
import 'package:hugeicons/hugeicons.dart';
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
              PasscodePrompt(
                visual: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) => Transform.scale(
                    scale: value,
                    child: Opacity(opacity: value.clamp(0, 1), child: child),
                  ),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 72,
                    height: 72,
                    color: theme.colorScheme.foreground,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
                title: 'Welcome back',
                message: 'Enter your passcode to unlock LifeOS.',
                error: _isError ? 'Wrong passcode. Try again.' : null,
                input: PasscodeInput(
                  onCompleted: _handlePasscodeCompleted,
                  onChanged: _handlePasscodeChanged,
                  isError: _isError,
                ),
                footer: _biometricAvailable && _biometricEnabled
                    ? OutlineButton(
                        onPressed: _handleBiometricAuth,
                        leading: const HugeIcon(
                          icon: HugeIcons.strokeRoundedFaceId,
                          size: AppIconSize.md,
                        ),
                        child: const Text('Use Face ID'),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
