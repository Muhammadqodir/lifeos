import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/presentation/bloc/theme_bloc.dart';
import '../../../../core/theme/presentation/bloc/theme_event.dart';
import '../../../../core/theme/presentation/bloc/theme_state.dart';
import '../../../../core/ui/ui.dart';
import '../../../../injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../habits/presentation/bloc/habits_list_bloc.dart';
import '../../../habits/presentation/pages/habits_main_page.dart';
import '../../../security/presentation/pages/security_settings_page.dart';
import '../widgets/custom_side_navigation.dart' show UserAvatar, confirmLogout;

/// "More" tab: secondary features, settings and account.
class OtherPage extends StatelessWidget {
  const OtherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = context.semantic;

    return Scaffold(
      headers: const [AppHeader(title: 'More')],
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.page,
          vertical: AppSpacing.lg,
        ),
        child: ContentWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppListSection(
                title: 'Features',
                children: [
                  AppListTile(
                    leading: LeadingTile.icon(
                      HugeIcons.strokeRoundedCheckmarkCircle01,
                      color: semantic.success,
                    ),
                    title: 'Habits',
                    subtitle: 'Track daily habits and streaks',
                    showChevron: true,
                    onTap: () => Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => BlocProvider<HabitsListBloc>(
                          create: (_) => getIt<HabitsListBloc>(),
                          child: const HabitsMainPage(),
                        ),
                      ),
                    ),
                  ),
                  AppListTile(
                    leading: LeadingTile.icon(
                      HugeIcons.strokeRoundedNotebook,
                      color: semantic.info,
                    ),
                    title: 'Daily journal',
                    subtitle: 'Reflect on your day',
                    trailing: const AppBadge.neutral(label: 'Soon'),
                  ),
                ],
              ),
              AppListSection(
                title: 'Settings',
                children: [
                  BlocBuilder<ThemeBloc, ThemeState>(
                    builder: (context, state) => AppListTile(
                      leading: LeadingTile.icon(
                        state.isDark
                            ? HugeIcons.strokeRoundedMoon02
                            : HugeIcons.strokeRoundedSun01,
                      ),
                      title: 'Dark appearance',
                      subtitle: state.isDark ? 'On' : 'Off',
                      onTap: () =>
                          context.read<ThemeBloc>().add(const ThemeToggled()),
                      trailing: Switch(
                        value: state.isDark,
                        onChanged: (value) =>
                            context.read<ThemeBloc>().add(ThemeChanged(value)),
                      ),
                    ),
                  ),
                  AppListTile(
                    leading: LeadingTile.icon(
                      HugeIcons.strokeRoundedLockPassword,
                    ),
                    title: 'Passcode and Face ID',
                    subtitle: 'Lock the app when you leave it',
                    showChevron: true,
                    onTap: () => Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => const SecuritySettingsPage(),
                      ),
                    ),
                  ),
                  AppListTile(
                    leading: LeadingTile.icon(
                      HugeIcons.strokeRoundedNotification01,
                    ),
                    title: 'Notifications',
                    subtitle: 'Reminders for habits and todos',
                    trailing: const AppBadge.neutral(label: 'Soon'),
                  ),
                ],
              ),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final user = state is AuthAuthenticated ? state.user : null;
                  final name = user == null
                      ? 'Signed in'
                      : '${user.firstName} ${user.lastName}'.trim();
                  return AppListSection(
                    title: 'Account',
                    children: [
                      AppListTile(
                        leading: UserAvatar(
                          name: name,
                          size: AppLayout.leadingSize,
                        ),
                        title: name,
                        subtitle: user?.email,
                      ),
                      AppListTile(
                        leading: LeadingTile.icon(
                          HugeIcons.strokeRoundedLogout01,
                          color: context.colors.destructive,
                        ),
                        title: 'Log out',
                        onTap: () => confirmLogout(context),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
