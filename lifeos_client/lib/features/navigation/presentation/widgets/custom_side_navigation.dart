import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/presentation/bloc/theme_bloc.dart';
import '../../../../core/theme/presentation/bloc/theme_event.dart';
import '../../../../core/theme/presentation/bloc/theme_state.dart';
import '../../../../core/ui/ui.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'navigation_item_data.dart';

/// Sidebar for iPad and Mac. Full width with labels in expanded windows,
/// a compact icon rail when [collapsed].
class CustomSideNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavigationItemData> items;
  final bool collapsed;

  const CustomSideNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.collapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedContainer(
      duration: AppDurations.slow,
      curve: Curves.easeOutCubic,
      width: collapsed ? AppLayout.railWidth : AppLayout.sidebarWidth,
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(right: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        right: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Brand(collapsed: collapsed),
              const SizedBox(height: AppSpacing.lg),
              for (var i = 0; i < items.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                  child: _SideNavButton(
                    item: items[i],
                    isSelected: currentIndex == i,
                    collapsed: collapsed,
                    shortcut: isApplePlatform ? '⌘${i + 1}' : 'Ctrl+${i + 1}',
                    onTap: () => onTap(i),
                  ),
                ),
              const Spacer(),
              const _ThemeToggle(),
              const SizedBox(height: AppSpacing.xs),
              _UserProfile(collapsed: collapsed),
            ],
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.collapsed});
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final logo = ClipRRect(
      borderRadius: context.theme.controlRadius,
      child: Image.asset('assets/logo.png', width: 28, height: 28),
    );
    if (collapsed) return Center(child: logo);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          logo,
          const SizedBox(width: AppSpacing.sm),
          Text(
            'LifeOS',
            style: context.text.sectionTitle.copyWith(letterSpacing: -0.2),
          ),
        ],
      ),
    );
  }
}

class _SideNavButton extends StatelessWidget {
  const _SideNavButton({
    required this.item,
    required this.isSelected,
    required this.collapsed,
    required this.onTap,
    required this.shortcut,
  });

  final NavigationItemData item;
  final bool isSelected;
  final bool collapsed;
  final VoidCallback onTap;
  final String shortcut;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = isSelected ? colors.foreground : colors.mutedForeground;

    final icon = HugeIcon(
      icon: item.icon,
      size: AppIconSize.md,
      strokeWidth: isSelected ? 2 : 1.6,
      color: foreground,
    );

    final Widget body;
    if (collapsed) {
      body = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(height: 3),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.caption.copyWith(
              color: foreground,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      );
    } else {
      body = Row(
        children: [
          icon,
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.label.copyWith(
                color: isSelected ? colors.foreground : null,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
          if (isDesktopPlatform) Text(shortcut, style: context.text.caption),
        ],
      );
    }

    final button = AnimatedContainer(
      duration: AppDurations.base,
      decoration: BoxDecoration(
        color: isSelected ? colors.accent : colors.accent.withValues(alpha: 0),
        borderRadius: context.theme.controlRadius,
      ),
      child: AppPressable(
        onTap: onTap,
        highlight: !isSelected,
        semanticLabel: item.label,
        padding: collapsed
            ? const EdgeInsets.symmetric(vertical: AppSpacing.sm)
            : const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + 2,
                vertical: AppSpacing.sm + 1,
              ),
        child: body,
      ),
    );

    if (!collapsed) return button;
    return Tooltip(
      alignment: Alignment.centerLeft,
      anchorAlignment: Alignment.centerRight,
      tooltip: (context) =>
          TooltipContainer(child: Text('${item.label}  $shortcut')),
      child: button,
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Center(
          child: HeaderAction(
            icon: state.isDark
                ? HugeIcons.strokeRoundedSun01
                : HugeIcons.strokeRoundedMoon02,
            tooltip: state.isDark ? 'Light appearance' : 'Dark appearance',
            onTap: () => context.read<ThemeBloc>().add(const ThemeToggled()),
          ),
        );
      },
    );
  }
}

class _UserProfile extends StatelessWidget {
  const _UserProfile({required this.collapsed});
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        final name = user == null
            ? 'Guest'
            : [
                user.firstName,
                user.lastName,
              ].where((part) => part.isNotEmpty).join(' ');
        final email = user?.email ?? '';
        final avatar = UserAvatar(name: name);

        final actions = [
          AppAction(
            label: 'Log out',
            icon: HugeIcons.strokeRoundedLogout01,
            destructive: true,
            onSelected: () => confirmLogout(context),
          ),
        ];

        if (collapsed) {
          return Center(
            child: AppContextActions(
              actions: actions,
              child: AppPressable(
                onTap: () => confirmLogout(context),
                borderRadius: BorderRadius.circular(40),
                semanticLabel: 'Log out',
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: avatar,
                ),
              ),
            ),
          );
        }

        return AppListTile(
          leading: avatar,
          title: name,
          subtitle: email,
          actions: actions,
          borderRadius: context.theme.controlRadius,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
        );
      },
    );
  }
}

/// Initials avatar used wherever the signed-in user is shown.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.name, this.size = 32});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.colors.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: context.text.caption.copyWith(
          color: context.colors.primaryForeground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Asks before signing out, then dispatches the logout.
Future<void> confirmLogout(BuildContext context) async {
  final confirmed = await AppDialogs.confirm(
    context,
    title: 'Log out?',
    message: "You'll need to sign in again to see your data.",
    confirmLabel: 'Log out',
    destructive: true,
  );
  if (confirmed && context.mounted) {
    context.read<AuthBloc>().add(AuthLogoutRequested());
  }
}
