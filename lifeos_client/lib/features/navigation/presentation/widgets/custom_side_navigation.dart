import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lifeos_client/features/auth/presentation/bloc/auth_state.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/features/navigation/presentation/widgets/navigation_item_data.dart';

/// Custom bottom navigation bar following shadcn design principles
class CustomSideNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavigationItemData> items;

  const CustomSideNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: colorScheme.background,
        border: Border(right: BorderSide(color: colorScheme.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Column(
            children: [
              UserProfile(),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(
                    items.length,
                    (index) => _NavigationButton(
                      item: items[index],
                      isSelected: currentIndex == index,
                      onTap: () => onTap(index),
                      colorScheme: colorScheme,
                    ),
                  ),
                ).gap(4),
              ),
              _NavigationButton(
                item: const NavigationItemData(
                  label: 'Log out',
                  icon: HugeIcons.strokeRoundedLogout01,
                ),
                isSelected: currentIndex == items.length,
                onTap: () => {
                  // Handle log out tap
                },
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.network(
                  'https://i.pravatar.cc/150?img=3',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state is AuthAuthenticated
                          ? state.user.firstName
                          : 'Guest User',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      state is AuthAuthenticated
                          ? state.user.email
                          : 'undefined',
                      style: TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Individual navigation button
class _NavigationButton extends StatefulWidget {
  final NavigationItemData item;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _NavigationButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  State<_NavigationButton> createState() => _NavigationButtonState();
}

class _NavigationButtonState extends State<_NavigationButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final colorScheme = widget.colorScheme;

    // Colors based on selection state
    // Use background.withValues(alpha: 0) instead of Colors.transparent to avoid black flashing
    final backgroundColor = isSelected
        ? colorScheme.muted
        : _isHovered
        ? colorScheme.accent
        : colorScheme.background.withValues(alpha: 0);

    final iconColor = isSelected
        ? colorScheme.foreground
        : colorScheme.mutedForeground;

    final textColor = isSelected
        ? colorScheme.foreground
        : colorScheme.mutedForeground;

    double strokeWidth = isSelected ? 2 : 1;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              HugeIcon(
                icon: widget.item.icon,
                color: iconColor,
                size: 24,
                strokeWidth: strokeWidth,
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  widget.item.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: textColor,
                    height: 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
