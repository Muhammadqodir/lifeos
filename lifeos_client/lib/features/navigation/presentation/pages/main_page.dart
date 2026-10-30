import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/ui/ui.dart';
import '../../../../injection.dart';
import '../../../finance/presentation/pages/finance_main_page.dart';
import '../../../finance/presentation/providers/amount_visibility_provider.dart';
import '../../../health/presentation/bloc/health_home_bloc.dart';
import '../../../health/presentation/bloc/health_home_event.dart';
import '../../../health/presentation/pages/health_main_page.dart';
import '../../../home/presentation/bloc/home_bloc.dart';
import '../../../home/presentation/bloc/home_event.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../projects/presentation/bloc/manage_projects_bloc.dart';
import '../../../projects/presentation/bloc/manage_projects_event.dart';
import '../../../projects/presentation/bloc/manage_todos_bloc.dart';
import '../../../projects/presentation/pages/projects_main_page.dart';
import '../bloc/navigation_bloc.dart';
import '../bloc/navigation_event.dart';
import '../bloc/navigation_state.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../widgets/custom_side_navigation.dart';
import '../widgets/fade_indexed_stack.dart';
import '../widgets/navigation_item_data.dart';
import 'other_page.dart';

/// App shell. Adapts navigation to the window:
///
/// * compact  (iPhone)            – bottom tab bar
/// * medium   (iPad portrait)     – icon rail
/// * expanded (iPad landscape/Mac) – full sidebar
///
/// Each tab owns a nested [Navigator], so detail pages open inside the
/// content area (the sidebar stays visible) and every tab keeps its own
/// back stack, like a native tab bar controller.
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationBloc(),
      child: const _MainShell(),
    );
  }
}

class _MainShell extends StatefulWidget {
  const _MainShell();

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  static const List<NavigationItemData> _items = [
    NavigationItemData(label: 'Home', icon: HugeIcons.strokeRoundedHome01),
    NavigationItemData(
      label: 'Finances',
      icon: HugeIcons.strokeRoundedWallet03,
    ),
    NavigationItemData(
      label: 'Health',
      icon: HugeIcons.strokeRoundedBodyPartMuscle,
    ),
    NavigationItemData(
      label: 'Projects',
      icon: HugeIcons.strokeRoundedFolder01,
    ),
    NavigationItemData(
      label: 'More',
      icon: HugeIcons.strokeRoundedDashboardCircle,
    ),
  ];

  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    _items.length,
    (_) => GlobalKey<NavigatorState>(),
  );

  late final List<Widget> _tabs = _buildTabs();

  List<Widget> _buildTabs() {
    Widget tab(int index, Widget page) =>
        _TabNavigator(navigatorKey: _navigatorKeys[index], child: page);

    return [
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => getIt<HomeBloc>()..add(const HomeStarted()),
          ),
          BlocProvider(create: (_) => getIt<ManageTodosBloc>()),
        ],
        child: tab(0, const HomePage()),
      ),
      ChangeNotifierProvider(
        create: (_) => AmountVisibilityProvider(),
        child: tab(1, const FinanceMainPage()),
      ),
      BlocProvider(
        create: (_) => getIt<HealthHomeBloc>()..add(const HealthHomeStarted()),
        child: tab(2, const GymMainPage()),
      ),
      BlocProvider(
        create: (_) =>
            getIt<ManageProjectsBloc>()..add(const ManageProjectsLoad()),
        child: tab(3, const ProjectsMainPage()),
      ),
      tab(4, const OtherPage()),
    ];
  }

  void _selectTab(int index) {
    final bloc = context.read<NavigationBloc>();
    if (bloc.state.currentIndex == index) {
      // Re-selecting the active tab returns to its root page.
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
      return;
    }
    bloc.add(TabSelected(index));
  }

  void _popCurrentTab() {
    final index = context.read<NavigationBloc>().state.currentIndex;
    _navigatorKeys[index].currentState?.maybePop();
  }

  Map<ShortcutActivator, VoidCallback> get _shortcuts {
    final useMeta = isApplePlatform;
    final digits = [
      LogicalKeyboardKey.digit1,
      LogicalKeyboardKey.digit2,
      LogicalKeyboardKey.digit3,
      LogicalKeyboardKey.digit4,
      LogicalKeyboardKey.digit5,
    ];
    return {
      for (var i = 0; i < _items.length; i++)
        SingleActivator(digits[i], meta: useMeta, control: !useMeta): () =>
            _selectTab(i),
      SingleActivator(
        LogicalKeyboardKey.bracketLeft,
        meta: useMeta,
        control: !useMeta,
      ): _popCurrentTab,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        final content = FadeIndexedStack(
          index: state.currentIndex,
          children: _tabs,
        );

        return NavigatorPopHandler(
          // Android back / predictive back pops inside the active tab first.
          onPopWithResult: (_) => _popCurrentTab(),
          child: CallbackShortcuts(
            bindings: _shortcuts,
            child: Focus(
              autofocus: true,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final windowClass = WindowClass.fromWidth(
                    constraints.maxWidth,
                  );
                  if (windowClass.isCompact) {
                    return Scaffold(
                      footers: [
                        CustomBottomNavigation(
                          currentIndex: state.currentIndex,
                          onTap: _selectTab,
                          items: _items,
                        ),
                      ],
                      child: content,
                    );
                  }
                  return Scaffold(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomSideNavigation(
                          currentIndex: state.currentIndex,
                          onTap: _selectTab,
                          items: _items,
                          collapsed: !windowClass.isExpanded,
                        ),
                        Expanded(child: content),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Nested navigator hosting one tab's back stack.
class _TabNavigator extends StatelessWidget {
  const _TabNavigator({required this.navigatorKey, required this.child});

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) =>
          CupertinoPageRoute(settings: settings, builder: (_) => child),
    );
  }
}
