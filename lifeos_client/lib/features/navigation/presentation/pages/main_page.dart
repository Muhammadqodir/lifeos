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
///
/// Keyboard (iPad/Mac): ⌘1–5 switch tabs, ⌘[ or Esc go back, ⌘N runs the
/// page's primary action and ⌘R refreshes it. On macOS the same commands
/// are in the menu bar (see MainFlutterWindow.swift).
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

  final PageCommandRegistry _commands = PageCommandRegistry();

  /// Menu bar items added natively in MainFlutterWindow.swift.
  static const _menuChannel = MethodChannel('lifeos/menu');

  late final List<Widget> _tabs = _buildTabs();

  @override
  void initState() {
    super.initState();
    _menuChannel.setMethodCallHandler(_onMenuCommand);
    HardwareKeyboard.instance.addHandler(_onHardwareKey);
  }

  @override
  void dispose() {
    _menuChannel.setMethodCallHandler(null);
    HardwareKeyboard.instance.removeHandler(_onHardwareKey);
    super.dispose();
  }

  Future<void> _onMenuCommand(MethodCall call) async {
    if (!mounted) return;
    // Ignore the menu while a dialog or a full-screen flow (workout) is
    // on top of the shell.
    if (ModalRoute.isCurrentOf(context) == false) return;
    switch (call.method) {
      case 'newItem':
        _runPageCommand((c) => c.onNew);
      case 'refresh':
        _runPageCommand((c) => c.onRefresh);
      case 'back':
        _popCurrentTab();
      case 'selectTab':
        final index = call.arguments as int;
        if (index >= 0 && index < _items.length) _selectTab(index);
    }
  }

  /// Runs a command of the top page in the active tab, if it has one.
  bool _runPageCommand(VoidCallback? Function(PageCommandSet) pick) {
    final index = context.read<NavigationBloc>().state.currentIndex;
    final commands = _commands.activeFor(index);
    final callback = commands == null ? null : pick(commands);
    callback?.call();
    return callback != null;
  }

  List<Widget> _buildTabs() {
    Widget tab(int index, Widget page) => PageCommandScope(
      registry: _commands,
      tabIndex: index,
      child: _TabNavigator(navigatorKey: _navigatorKeys[index], child: page),
    );

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

  /// Goes back inside the active tab. Returns false on a tab's root page.
  bool _popCurrentTab() {
    final index = context.read<NavigationBloc>().state.currentIndex;
    final navigator = _navigatorKeys[index].currentState;
    if (navigator == null || !navigator.canPop()) return false;
    navigator.maybePop();
    return true;
  }

  static const _tabKeys = [
    LogicalKeyboardKey.digit1,
    LogicalKeyboardKey.digit2,
    LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.digit4,
    LogicalKeyboardKey.digit5,
  ];

  /// App-wide shortcuts. Registered on [HardwareKeyboard] rather than as
  /// focus-based [Shortcuts], so they keep working after a click moves
  /// focus out of the shell (common with a mouse). Returning false leaves
  /// the key to text fields, the browser or the Mac menu bar.
  bool _onHardwareKey(KeyEvent event) {
    if (event is! KeyDownEvent || !mounted) return false;
    // A dialog, sheet, menu or full-screen flow is on top of the shell.
    if (ModalRoute.isCurrentOf(context) == false) return false;

    final keyboard = HardwareKeyboard.instance;
    final key = event.logicalKey;
    final command = isApplePlatform
        ? keyboard.isMetaPressed
        : keyboard.isControlPressed;
    final otherModifiers =
        keyboard.isAltPressed ||
        keyboard.isShiftPressed ||
        (isApplePlatform && keyboard.isControlPressed);

    if (command && !otherModifiers) {
      final tab = _tabKeys.indexOf(key);
      if (tab >= 0 && tab < _items.length) {
        _selectTab(tab);
        return true;
      }
      if (key == LogicalKeyboardKey.bracketLeft) return _popCurrentTab();
      if (key == LogicalKeyboardKey.keyN) {
        return _runPageCommand((c) => c.onNew);
      }
      if (key == LogicalKeyboardKey.keyR) {
        return _runPageCommand((c) => c.onRefresh);
      }
      return false;
    }

    if (key == LogicalKeyboardKey.escape && !command && !otherModifiers) {
      // First Esc leaves a text field, so a half-typed form isn't lost.
      final focused = FocusManager.instance.primaryFocus;
      if (focused?.context?.findAncestorWidgetOfExactType<EditableText>() !=
          null) {
        focused!.unfocus();
        return true;
      }
      return _popCurrentTab();
    }
    return false;
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final windowClass = WindowClass.fromWidth(constraints.maxWidth);
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
