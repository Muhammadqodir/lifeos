import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos_client/core/ui/ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() {
  testWidgets('⌘N and ⌘R target the top page of the requested tab', (
    tester,
  ) async {
    final registry = PageCommandRegistry();
    final navigatorKey = GlobalKey<NavigatorState>();
    final calls = <String>[];

    Widget page(String name) => PageCommands(
      commands: PageCommandSet(
        onNew: () => calls.add('new $name'),
        onRefresh: () => calls.add('refresh $name'),
      ),
      child: Text(name),
    );

    await tester.pumpWidget(
      ShadcnApp(
        home: Row(
          children: [
            Expanded(
              child: PageCommandScope(
                registry: registry,
                tabIndex: 0,
                child: Navigator(
                  key: navigatorKey,
                  onGenerateRoute: (_) =>
                      CupertinoPageRoute(builder: (_) => page('list')),
                ),
              ),
            ),
            Expanded(
              child: PageCommandScope(
                registry: registry,
                tabIndex: 1,
                child: page('other tab'),
              ),
            ),
          ],
        ),
      ),
    );

    registry.activeFor(0)!.onNew!();
    registry.activeFor(1)!.onRefresh!();
    expect(calls, ['new list', 'refresh other tab']);

    // A detail page without commands hides the list's commands.
    navigatorKey.currentState!.push(
      CupertinoPageRoute(builder: (_) => const Text('detail')),
    );
    await tester.pumpAndSettle();
    expect(registry.activeFor(0), isNull);

    navigatorKey.currentState!.push(
      CupertinoPageRoute(builder: (_) => page('detail with actions')),
    );
    await tester.pumpAndSettle();
    calls.clear();
    registry.activeFor(0)!.onNew!();
    expect(calls, ['new detail with actions']);

    navigatorKey.currentState!.pop();
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    calls.clear();
    registry.activeFor(0)!.onRefresh!();
    expect(calls, ['refresh list']);
    expect(registry.activeFor(2), isNull);
  });

  testWidgets('split view panes fill in each other\'s commands', (
    tester,
  ) async {
    final registry = PageCommandRegistry();
    final calls = <String>[];

    await tester.pumpWidget(
      ShadcnApp(
        home: PageCommandScope(
          registry: registry,
          tabIndex: 0,
          child: Row(
            children: [
              PageCommands(
                commands: PageCommandSet(
                  onNew: () => calls.add('new habit'),
                  onRefresh: () => calls.add('refresh list'),
                ),
                child: const SizedBox(width: 10),
              ),
              PageCommands(
                commands: PageCommandSet(
                  onRefresh: () => calls.add('refresh detail'),
                ),
                child: const SizedBox(width: 10),
              ),
            ],
          ),
        ),
      ),
    );

    final commands = registry.activeFor(0)!;
    commands.onNew!();
    commands.onRefresh!();
    expect(calls, ['new habit', 'refresh detail']);
  });

  testWidgets('AppHeader registers refresh and its primary action', (
    tester,
  ) async {
    final registry = PageCommandRegistry();
    var created = 0;
    var refreshed = 0;

    await tester.pumpWidget(
      ShadcnApp(
        home: PageCommandScope(
          registry: registry,
          tabIndex: 0,
          child: Scaffold(
            headers: [
              AppHeader(
                title: 'Projects',
                onRefresh: () => refreshed++,
                actions: [
                  HeaderAction(icon: const [], tooltip: 'Filter', onTap: () {}),
                  HeaderAction(
                    icon: const [],
                    tooltip: 'New project',
                    primary: true,
                    onTap: () => created++,
                  ),
                ],
              ),
            ],
            child: const SizedBox(),
          ),
        ),
      ),
    );

    final commands = registry.activeFor(0)!;
    commands.onNew!();
    commands.onRefresh!();
    expect((created, refreshed), (1, 1));
  });
}
