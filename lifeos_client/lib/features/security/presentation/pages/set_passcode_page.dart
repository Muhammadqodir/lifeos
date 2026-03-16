import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../utils/toast.dart';
import '../../../navigation/presentation/widgets/custom_app_bar.dart';
import '../bloc/security_bloc.dart';
import '../bloc/security_event.dart';
import '../bloc/security_state.dart';
import '../widgets/passcode_input.dart';

class SetPasscodePage extends StatefulWidget {
  const SetPasscodePage({super.key});

  @override
  State<SetPasscodePage> createState() => _SetPasscodePageState();
}

class _SetPasscodePageState extends State<SetPasscodePage> {
  String? _firstPasscode;
  bool _isConfirming = false;
  bool _enableBiometric = false;
  bool _biometricAvailable = false;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    context.read<SecurityBloc>().add(SecurityCheckRequested());
  }

  void _handlePasscodeCompleted(String passcode) {
    if (!_isConfirming) {
      setState(() {
        _firstPasscode = passcode;
        _isConfirming = true;
        _isError = false;
      });
    } else {
      if (passcode == _firstPasscode) {
        context.read<SecurityBloc>().add(
              SecuritySetPasscodeRequested(
                passcode: passcode,
                enableBiometric: _enableBiometric,
              ),
            );
      } else {
        setState(() {
          _isError = true;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            _isConfirming = false;
            _firstPasscode = null;
            _isError = false;
          });
        });
      }
    }
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
        if (state is SecurityPasscodeSet) {
          showToast(
            context: context,
            builder: (context, overlay) {
              return Utils.buildToast(
                context,
                overlay,
                'Success',
                'Passcode set successfully',
              );
            },
          );
          Navigator.of(context).pop(true);
        } else if (state is SecurityError) {
          showToast(
            context: context,
            builder: (context, overlay) {
              return Utils.buildToast(
                context,
                overlay,
                'Error',
                state.message,
              );
            },
          );
        } else if (state is SecuritySettingsLoaded) {
          setState(() {
            _biometricAvailable = state.settings.biometricAvailable;
          });
        }
      },
      child: Scaffold(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Set Passcode',
              leftActions: [
                AppBarAction(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  tooltip: 'Back',
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      Icon(
                        Icons.lock,
                        size: 64,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _isConfirming ? 'Confirm Passcode' : 'Enter Passcode',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isConfirming
                            ? 'Re-enter your passcode to confirm'
                            : 'Enter a 6-digit passcode',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.mutedForeground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_isError) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Passcodes do not match',
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
                      if (_biometricAvailable && !_isConfirming) ...[
                        const SizedBox(height: 48),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.muted.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.fingerprint,
                                color: theme.colorScheme.primary,
                                size: 32,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Enable Face ID',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Unlock with biometric authentication',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.colorScheme.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _enableBiometric,
                                onChanged: (value) {
                                  setState(() {
                                    _enableBiometric = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
