import 'package:flutter/cupertino.dart';
import 'package:lifeos_client/core/theme/presentation/bloc/theme_bloc.dart';
import 'package:lifeos_client/core/theme/presentation/bloc/theme_event.dart';
import 'package:lifeos_client/core/theme/presentation/bloc/theme_state.dart';
import 'package:lifeos_client/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lifeos_client/features/auth/presentation/bloc/auth_event.dart';
import 'package:lifeos_client/features/navigation/presentation/widgets/custom_app_bar.dart';
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
        Expanded(child: SizedBox.shrink()),
      ],
    );
  }
}
