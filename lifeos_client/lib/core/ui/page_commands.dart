import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Commands the visible page offers to the app shell: ⌘N ("new item") and
/// ⌘R ("refresh") on iPad and Mac, and File ▸ New / View ▸ Refresh in the
/// Mac menu bar.
///
/// Pages don't use this directly: [AppHeader] registers its `onRefresh` and
/// its primary [HeaderAction]. The shell asks [PageCommandRegistry] for the
/// commands of the page that is on top of the active tab.
class PageCommandRegistry {
  final List<_PageCommandsState> _entries = [];

  /// Commands of the top page in [tabIndex], or null when it has none.
  PageCommandSet? activeFor(int tabIndex) {
    for (final entry in _entries.reversed) {
      if (!entry.mounted || entry.tabIndex != tabIndex) continue;
      if (ModalRoute.isCurrentOf(entry.context) == false) continue;
      return entry.widget.commands;
    }
    return null;
  }
}

@immutable
class PageCommandSet {
  const PageCommandSet({this.onNew, this.onRefresh});

  final VoidCallback? onNew;
  final VoidCallback? onRefresh;

  bool get isEmpty => onNew == null && onRefresh == null;
}

/// Provides the registry and the tab index to one tab's navigator.
class PageCommandScope extends InheritedWidget {
  const PageCommandScope({
    super.key,
    required this.registry,
    required this.tabIndex,
    required super.child,
  });

  final PageCommandRegistry registry;
  final int tabIndex;

  static PageCommandScope? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<PageCommandScope>();

  @override
  bool updateShouldNotify(PageCommandScope oldWidget) =>
      registry != oldWidget.registry || tabIndex != oldWidget.tabIndex;
}

/// Registers [commands] for the page that contains it.
class PageCommands extends StatefulWidget {
  const PageCommands({super.key, required this.commands, required this.child});

  final PageCommandSet commands;
  final Widget child;

  @override
  State<PageCommands> createState() => _PageCommandsState();
}

class _PageCommandsState extends State<PageCommands> {
  PageCommandScope? _scope;

  int? get tabIndex => _scope?.tabIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = PageCommandScope.maybeOf(context);
    if (scope?.registry != _scope?.registry) {
      _scope?.registry._entries.remove(this);
      scope?.registry._entries.add(this);
    }
    _scope = scope;
  }

  @override
  void dispose() {
    _scope?.registry._entries.remove(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
