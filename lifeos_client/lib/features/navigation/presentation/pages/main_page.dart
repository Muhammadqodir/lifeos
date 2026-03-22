import 'package:lifeos_client/features/health/presentation/pages/health_main_page.dart';
import 'package:lifeos_client/features/home/presentation/bloc/home_bloc.dart';
import 'package:lifeos_client/features/home/presentation/bloc/home_event.dart';
import 'package:lifeos_client/features/home/presentation/pages/home_page.dart';
import 'package:lifeos_client/features/navigation/presentation/pages/other_page.dart';
import 'package:lifeos_client/features/navigation/presentation/widgets/custom_side_navigation.dart';
import 'package:lifeos_client/features/navigation/presentation/widgets/fade_indexed_stack.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:lifeos_client/features/navigation/presentation/widgets/navigation_item_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../../../injection.dart';
import '../../../finance/presentation/pages/finance_main_page.dart';
import '../../../finance/presentation/providers/amount_visibility_provider.dart';
import '../../../health/presentation/bloc/health_home_bloc.dart';
import '../../../health/presentation/bloc/health_home_event.dart';
import '../../../projects/presentation/pages/projects_main_page.dart';
import '../../../projects/presentation/bloc/manage_projects_bloc.dart';
import '../../../projects/presentation/bloc/manage_projects_event.dart';
import '../../../projects/presentation/bloc/manage_todos_bloc.dart';
import '../bloc/navigation_bloc.dart';
import '../bloc/navigation_event.dart';
import '../bloc/navigation_state.dart';
import '../widgets/custom_bottom_navigation.dart';

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
      label: 'Health',
      icon: HugeIcons.strokeRoundedBodyPartMuscle,
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final useMobileLayout = constraints.maxWidth < 600;
              return Scaffold(
                footers: [
                  if (useMobileLayout)
                    _buildBottomNavigationBar(context, state),
                ],
                child: Row(
                  children: [
                    if (!useMobileLayout)
                      _buildSideNavigationBar(context, state),
                    Expanded(
                      child: FadeIndexedStack(
                        index: state.currentIndex,
                        children: _buildPages(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Builds all pages once and maintains their state
  List<Widget> _buildPages() {
    return [
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => getIt<HomeBloc>()..add(const HomeStarted()),
          ),
          BlocProvider(create: (_) => getIt<ManageTodosBloc>()),
        ],
        child: const HomePage(),
      ),
      ChangeNotifierProvider(
        create: (_) => AmountVisibilityProvider(),
        child: const FinanceMainPage(),
      ),
      BlocProvider(
        create: (_) => getIt<HealthHomeBloc>()..add(const HealthHomeStarted()),
        child: const GymMainPage(),
      ),
      BlocProvider(
        create: (_) =>
            getIt<ManageProjectsBloc>()..add(const ManageProjectsLoad()),
        child: const ProjectsMainPage(),
      ),
      const OtherPage(),
    ];
  }

  /// Builds the side navigation bar
  Widget _buildSideNavigationBar(BuildContext context, NavigationState state) {
    return CustomSideNavigation(
      currentIndex: state.currentIndex,
      onTap: (index) {
        context.read<NavigationBloc>().add(TabSelected(index));
      },
      items: _navigationItems,
    );
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
