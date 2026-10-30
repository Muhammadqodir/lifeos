import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import '../bloc/security_bloc.dart';
import '../bloc/security_event.dart';
import '../bloc/security_state.dart';
import 'set_passcode_page.dart';
import 'package:lifeos_client/core/ui/ui.dart';

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

  Future<void> _handleClearPasscode() async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: 'Remove passcode?',
      message: 'Anyone with your device will be able to open LifeOS.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (confirmed && mounted) {
      context.read<SecurityBloc>().add(SecurityClearPasscodeRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SecurityBloc, SecurityState>(
      listener: (context, state) {
        if (state is SecurityPasscodeCleared) {
          AppToast.success(context, 'Passcode removed');
        } else if (state is SecurityError) {
          AppToast.error(
            context,
            'Something went wrong',
            message: state.message,
          );
        }
      },
      child: Scaffold(
        child: Column(
          children: [
            AppHeader(title: 'Passcode and Face ID'),
            Expanded(
              child: BlocBuilder<SecurityBloc, SecurityState>(
                builder: (context, state) {
                  if (state is SecurityLoading) {
                    return const LoadingState(message: 'Loading…');
                  }

                  final hasPasscode =
                      state is SecuritySettingsLoaded &&
                      state.settings.hasPasscode;
                  final biometricEnabled =
                      state is SecuritySettingsLoaded &&
                      state.settings.biometricEnabled;
                  final biometricAvailable =
                      state is SecuritySettingsLoaded &&
                      state.settings.biometricAvailable;

                  final semantic = context.semantic;
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.page,
                      vertical: AppSpacing.lg,
                    ),
                    child: ContentWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppListSection(
                            title: 'Passcode',
                            footer:
                                'LifeOS asks for the passcode each time you open it.',
                            children: [
                              AppListTile(
                                leading: LeadingTile.icon(
                                  HugeIcons.strokeRoundedLock,
                                  color: hasPasscode ? semantic.success : null,
                                ),
                                title: hasPasscode
                                    ? 'Change passcode'
                                    : 'Set passcode',
                                subtitle: hasPasscode
                                    ? 'Passcode is on'
                                    : 'Protect the app with a 6-digit code',
                                showChevron: true,
                                onTap: _navigateToSetPasscode,
                              ),
                              if (hasPasscode)
                                AppListTile(
                                  leading: LeadingTile.icon(
                                    HugeIcons.strokeRoundedLockPassword,
                                    color: context.colors.destructive,
                                  ),
                                  title: 'Remove passcode',
                                  onTap: _handleClearPasscode,
                                ),
                            ],
                          ),
                          if (biometricAvailable)
                            AppListSection(
                              title: 'Biometrics',
                              children: [
                                AppListTile(
                                  leading: LeadingTile.icon(
                                    HugeIcons.strokeRoundedFingerPrint,
                                    color: hasPasscode && biometricEnabled
                                        ? semantic.success
                                        : null,
                                  ),
                                  title: 'Face ID / Touch ID',
                                  subtitle: hasPasscode && biometricEnabled
                                      ? 'On'
                                      : hasPasscode
                                      ? 'Off · turn on when you set the passcode'
                                      : 'Set a passcode first',
                                  trailing: AppBadge(
                                    label: hasPasscode && biometricEnabled
                                        ? 'On'
                                        : 'Off',
                                    color: hasPasscode && biometricEnabled
                                        ? semantic.success
                                        : semantic.neutral,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
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
