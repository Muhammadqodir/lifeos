import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import '../widgets/passcode_prompt.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/security_bloc.dart';
import '../bloc/security_event.dart';
import '../bloc/security_state.dart';
import '../widgets/passcode_input.dart';
import 'package:lifeos_client/core/ui/ui.dart';

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

    return BlocListener<SecurityBloc, SecurityState>(
      listener: (context, state) {
        if (state is SecurityPasscodeSet) {
          AppToast.success(context, 'Passcode set');
          Navigator.of(context).pop(true);
        } else if (state is SecurityError) {
          AppToast.error(
            context,
            'Something went wrong',
            message: state.message,
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
            AppHeader(title: 'Set passcode'),
            Expanded(
              child: SafeArea(
                top: false,
                child: PasscodePrompt(
                  visual: LeadingTile.icon(
                    HugeIcons.strokeRoundedLockPassword,
                    size: 64,
                  ),
                  title: _isConfirming ? 'Confirm passcode' : 'Create a passcode',
                  message: _isConfirming
                      ? 'Enter the same 6 digits again.'
                      : 'Choose 6 digits you will remember.',
                  error: _isError ? "Passcodes don't match. Try again." : null,
                  input: PasscodeInput(
                    onCompleted: _handlePasscodeCompleted,
                    onChanged: _handlePasscodeChanged,
                    isError: _isError,
                  ),
                  footer: _biometricAvailable && !_isConfirming
                      ? AppListSection(
                          margin: EdgeInsets.zero,
                          children: [
                            AppListTile(
                              leading: LeadingTile.icon(
                                HugeIcons.strokeRoundedFingerPrint,
                              ),
                              title: 'Unlock with Face ID',
                              subtitle: 'Skip the passcode when it is you',
                              onTap: () => setState(
                                () => _enableBiometric = !_enableBiometric,
                              ),
                              trailing: Switch(
                                value: _enableBiometric,
                                onChanged: (value) =>
                                    setState(() => _enableBiometric = value),
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
