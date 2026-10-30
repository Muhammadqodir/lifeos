import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../app_theme_x.dart';
import '../tokens.dart';

/// List beside detail, like Mail or Notes on iPad and Mac.
///
/// Pages decide with [SplitView.fits] whether there is room, and fall back
/// to pushing the detail page on narrower windows.
class SplitView extends StatelessWidget {
  const SplitView({
    super.key,
    required this.list,
    required this.detail,
    this.listWidth = AppLayout.splitListWidth,
  });

  final Widget list;
  final Widget detail;
  final double listWidth;

  static bool fits(BoxConstraints constraints) =>
      constraints.maxWidth >= AppLayout.splitViewMinWidth;

  /// Whether [context] is inside a detail pane. [AppHeader] uses this to
  /// skip its automatic back button, which would close the whole page.
  static bool isDetailPane(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_DetailPaneScope>() != null;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: listWidth, child: list),
        VerticalDivider(width: 1, thickness: 1, color: context.colors.border),
        Expanded(child: _DetailPaneScope(child: detail)),
      ],
    );
  }
}

class _DetailPaneScope extends InheritedWidget {
  const _DetailPaneScope({required super.child});

  @override
  bool updateShouldNotify(_DetailPaneScope oldWidget) => false;
}
