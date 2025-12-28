import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/presentation/bloc/theme_bloc.dart';
import '../../../../core/theme/presentation/bloc/theme_event.dart';
import '../../../../core/theme/presentation/bloc/theme_state.dart';
import '../../../../injection.dart';
import '../../../finance/presentation/bloc/finance_home_bloc.dart';
import '../../../finance/presentation/bloc/finance_home_event.dart';
import '../../../finance/presentation/pages/finance_main_page.dart';
import '../../../finance/presentation/pages/add_transaction_page.dart';
import '../../../finance/presentation/providers/amount_visibility_provider.dart';
import '../bloc/navigation_bloc.dart';
import '../bloc/navigation_event.dart';
import '../bloc/navigation_state.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../widgets/custom_app_bar.dart';

/// Main page with bottom navigation bar
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationBloc(),
      child: const _MainPageContent(),
    );
  }
}

class _MainPageContent extends StatelessWidget {
  const _MainPageContent();

  /// List of navigation items
  static final List<NavigationItemData> _navigationItems = [
    const NavigationItemData(
      label: 'Home',
      icon: HugeIcons.strokeRoundedHome01,
    ),
    const NavigationItemData(
      label: 'Finances',
      icon: HugeIcons.strokeRoundedWallet03,
    ),
    const NavigationItemData(
      label: 'Gym',
      icon: HugeIcons.strokeRoundedDumbbell03,
    ),
    const NavigationItemData(
      label: 'Projects',
      icon: HugeIcons.strokeRoundedFolder01,
    ),
    const NavigationItemData(
      label: 'Other',
      icon: HugeIcons.strokeRoundedDashboardCircle,
    ),
  ];

  /// Page titles for each tab
  static const List<String> _pageTitles = [
    'Home',
    'Finances',
    'Gym',
    'Projects',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          footers: [_buildBottomNavigationBar(context, state)],
          child: _buildBody(state.currentIndex),
        );
      },
    );
  }

  /// Builds the body content based on selected tab
  Widget _buildBody(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return const _PlaceholderPage(title: 'Home');
      case 1:
        return ChangeNotifierProvider(
          create: (_) => AmountVisibilityProvider(),
          child: BlocProvider(
            create: (_) =>
                getIt<FinanceHomeBloc>()..add(const FinanceHomeStarted()),
            child: const FinanceMainPage(),
          ),
        );
      case 2:
        return const _PlaceholderPage(title: 'Gym');
      case 3:
        return const _PlaceholderPage(title: 'Projects');
      case 4:
        return const _PlaceholderPage(title: 'Other');
      default:
        return const _PlaceholderPage(title: 'Unknown');
    }
  }

  /// Builds the bottom navigation bar
  Widget _buildBottomNavigationBar(
    BuildContext context,
    NavigationState state,
  ) {
    return CustomBottomNavigation(
      currentIndex: state.currentIndex,
      onTap: (index) {
        context.read<NavigationBloc>().add(TabSelected(index));
      },
      items: _navigationItems,
    );
  }
}

/// Placeholder page for testing navigation
class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title, style: Theme.of(context).typography.p));
  }
}
