import 'package:flutter/cupertino.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/widgets/action_list_item.dart';
import '../../../navigation/presentation/widgets/custom_app_bar.dart';
import '../bloc/security_bloc.dart';
import '../bloc/security_event.dart';
import '../bloc/security_state.dart';
import 'set_passcode_page.dart';
import '../../../../utils/toast.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SecurityBloc>().add(SecurityCheckRequested());
  }

  void _navigateToSetPasscode() async {
    final result = await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<SecurityBloc>(),
          child: const SetPasscodePage(),
        ),
      ),
    );

    if (result == true && mounted) {
      context.read<SecurityBloc>().add(SecurityCheckRequested());
    }
  }

  void _handleClearPasscode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Passcode'),
        content: const Text(
          'Are you sure you want to remove your passcode? This will also disable biometric authentication.',
        ),
        actions: [
          SecondaryButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          DestructiveButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SecurityBloc>().add(SecurityClearPasscodeRequested());
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<SecurityBloc, SecurityState>(
      listener: (context, state) {
        if (state is SecurityPasscodeCleared) {
          showToast(
            context: context,
            builder: (context, overlay) {
              return Utils.buildToast(
                context,
                overlay,
                'Success',
                'Passcode removed successfully',
              );
            },
            location: ToastLocation.topCenter,
          );
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
            location: ToastLocation.topCenter,
          );
        }
      },
      child: Scaffold(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Security',
              leftActions: [
                AppBarAction(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  tooltip: 'Back',
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Expanded(
              child: BlocBuilder<SecurityBloc, SecurityState>(
                builder: (context, state) {
                  if (state is SecurityLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final hasPasscode = state is SecuritySettingsLoaded &&
                      state.settings.hasPasscode;
                  final biometricEnabled = state is SecuritySettingsLoaded &&
                      state.settings.biometricEnabled;
                  final biometricAvailable = state is SecuritySettingsLoaded &&
                      state.settings.biometricAvailable;

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Text(
                            'App Security',
                            style: theme.typography.normal.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!hasPasscode)
                          ActionListItem(
                            title: 'Set Passcode',
                            description:
                                'Secure your app with a 6-digit passcode',
                            onTap: _navigateToSetPasscode,
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedLock,
                              size: 18,
                              strokeWidth: 2,
                              color: theme.colorScheme.background,
                            ),
                          )
                        else ...[
                          ActionListItem(
                            title: 'Change Passcode',
                            description: 'Update your current passcode',
                            onTap: _navigateToSetPasscode,
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedLock,
                              size: 18,
                              strokeWidth: 2,
                              color: theme.colorScheme.background,
                            ),
                          ),
                          ActionListItem(
                            title: 'Remove Passcode',
                            description: 'Disable passcode protection',
                            onTap: _handleClearPasscode,
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedLockPassword,
                              size: 18,
                              strokeWidth: 2,
                              color: theme.colorScheme.background,
                            ),
                          ),
                        ],
                        if (biometricAvailable) ...[
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Text(
                              'Biometric Authentication',
                              style: theme.typography.normal.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Face ID / Touch ID',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        hasPasscode && biometricEnabled
                                            ? 'Enabled'
                                            : hasPasscode
                                                ? 'Disabled - Enable when setting passcode'
                                                : 'Set a passcode first',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              theme.colorScheme.mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (hasPasscode && biometricEnabled)
                                  Icon(
                                    Icons.check_circle,
                                    color: theme.colorScheme.primary,
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
