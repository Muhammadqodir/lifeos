import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../core/ui/breakpoints.dart';
import '../core/ui/tokens.dart';

/// Presents short tasks (log an entry, pick a project) adaptively:
/// a bottom sheet on iPhone, a centred dialog on iPad and Mac where a
/// full-width sheet would stretch across the whole window.
class BottomSheetModal {
  static Future<T?> openSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
  }) {
    if (context.windowClass.isAtLeastMedium) {
      return _openDialog<T>(context: context, builder: builder);
    }
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return showBarModalBottomSheet<T>(
      backgroundColor: theme.colorScheme.background,
      overlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: theme.colorScheme.background,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      context: context,
      // Cover the tab bar, like a native sheet, rather than opening inside
      // the tab's nested navigator.
      useRootNavigator: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            top: AppSpacing.xl,
            bottom:
                AppSpacing.xl + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: builder(context),
        );
      },
    );
  }

  static Future<T?> _openDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
  }) {
    return showDialog<T>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final maxHeight = MediaQuery.sizeOf(dialogContext).height * 0.85;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppLayout.dialogWidth,
              maxHeight: maxHeight,
            ),
            child: Container(
              margin: const EdgeInsets.all(AppSpacing.xl),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: theme.colorScheme.background,
                borderRadius: theme.cardRadius,
                border: Border.all(color: theme.colorScheme.border),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF000000).withValues(alpha: 0.18),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Builder(
                  // Builders in this app read blocs from the caller's context.
                  builder: (_) => builder(context),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
