import 'package:flutter/cupertino.dart';
import 'package:lifeos_client/core/theme/presentation/bloc/theme_bloc.dart';
import 'package:lifeos_client/core/theme/presentation/bloc/theme_event.dart';
import 'package:lifeos_client/core/theme/presentation/bloc/theme_state.dart';
import 'package:lifeos_client/core/widgets/action_list_item.dart';
import 'package:lifeos_client/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lifeos_client/features/auth/presentation/bloc/auth_event.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habits_list_bloc.dart';
import 'package:lifeos_client/features/habits/presentation/pages/habits_main_page.dart';
import 'package:lifeos_client/features/navigation/presentation/widgets/custom_app_bar.dart';
import 'package:lifeos_client/features/security/presentation/pages/security_settings_page.dart';
import 'package:lifeos_client/injection.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OtherPage extends StatefulWidget {
  const OtherPage({super.key});

  @override
  State<OtherPage> createState() => _OtherPageState();
}

class _OtherPageState extends State<OtherPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppBar(
          title: "Other",
          rightActions: [
            AppBarAction(
              icon: HugeIcons.strokeRoundedLogout01,
              tooltip: 'Logout',
              onTap: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
            ),
            BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, themeState) {
                return AppBarAction(
                  icon: themeState.isDark
                      ? HugeIcons.strokeRoundedSun01
                      : HugeIcons.strokeRoundedMoon,
                  tooltip: 'Change Theme',
                  onTap: () {
                    context.read<ThemeBloc>().add(ThemeToggled());
                  },
                );
              },
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    'Features',
                    style: Theme.of(
                      context,
                    ).typography.normal.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                ActionListItem(
                  title: "Habits",
                  description: "Track your daily habits and routines",
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) {
                          return BlocProvider<HabitsListBloc>(
                            create: (context) => getIt<HabitsListBloc>(),
                            child: const HabitsMainPage(),
                          );
                        },
                      ),
                    );
                  },
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                    size: 18,
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.background,
                  ),
                ),
                ActionListItem(
                  title: "Daily journal",
                  description: "Write daily journal entries to reflect on your day",
                  onTap: () {},
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedNotebook,
                    size: 18,
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.background,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    'Settings',
                    style: Theme.of(
                      context,
                    ).typography.normal.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                ActionListItem(
                  title: "Notifications",
                  description: "Manage your notification preferences",
                  onTap: () {},
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedNotification01,
                    size: 18,
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.background,
                  ),
                ),
                ActionListItem(
                  title: "Passcode",
                  description: "Manage your passcode settings",
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const SecuritySettingsPage(),
                      ),
                    );
                  },
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedLock,
                    size: 18,
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.background,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
