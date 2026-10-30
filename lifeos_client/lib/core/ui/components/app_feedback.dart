import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../app_theme_x.dart';
import '../breakpoints.dart';
import '../tokens.dart';

enum _ToastKind { success, error, info }

/// Transient notifications. Success and info are brief; errors stay a
/// little longer and use the destructive colour so they are not missed.
abstract final class AppToast {
  static void success(BuildContext context, String title, {String? message}) =>
      _show(context, _ToastKind.success, title, message);

  static void error(BuildContext context, String title, {String? message}) =>
      _show(
        context,
        _ToastKind.error,
        title,
        message == null ? null : friendlyErrorMessage(message),
      );

  static void info(BuildContext context, String title, {String? message}) =>
      _show(context, _ToastKind.info, title, message);

  static void _show(
    BuildContext context,
    _ToastKind kind,
    String title,
    String? message,
  ) {
    if (!context.mounted) return;
    showToast(
      context: context,
      location: isDesktopPlatform
          ? ToastLocation.bottomRight
          : ToastLocation.topCenter,
      showDuration: kind == _ToastKind.error
          ? const Duration(seconds: 5)
          : const Duration(seconds: 3),
      builder: (context, overlay) {
        final semantic = context.semantic;
        final (icon, color) = switch (kind) {
          _ToastKind.success => (
            HugeIcons.strokeRoundedCheckmarkCircle02,
            semantic.success,
          ),
          _ToastKind.error => (
            HugeIcons.strokeRoundedAlertCircle,
            context.colors.destructive,
          ),
          _ToastKind.info => (
            HugeIcons.strokeRoundedInformationCircle,
            semantic.info,
          ),
        };
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: SurfaceCard(
            child: Basic(
              leading: HugeIcon(icon: icon, size: AppIconSize.md, color: color),
              title: Text(title),
              subtitle: message == null || message.isEmpty
                  ? null
                  : Text(message),
              trailing: IconButton.ghost(
                size: ButtonSize.xSmall,
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedCancel01,
                  size: AppIconSize.sm,
                ),
                onPressed: overlay.close,
              ),
              trailingAlignment: Alignment.center,
            ),
          ),
        );
      },
    );
  }
}

/// Turns exception text from the data layer into something a person can
/// act on. Raw `DioException` dumps never reach the UI.
String friendlyErrorMessage(String raw) {
  var message = raw.replaceFirst(RegExp(r'^(Exception|Error):\s*'), '').trim();
  final lower = message.toLowerCase();
  if (lower.contains('socketexception') ||
      lower.contains('connection refused') ||
      lower.contains('connection error') ||
      lower.contains('failed host lookup') ||
      lower.contains('network is unreachable') ||
      lower == 'network error') {
    return "Can't reach the server. Check your connection and try again.";
  }
  if (lower.contains('timeout') || lower.contains('timed out')) {
    return 'The server took too long to respond. Try again.';
  }
  if (lower.contains('dioexception') || lower.contains('stacktrace')) {
    return 'Something went wrong. Try again.';
  }
  if (message.isEmpty) return 'Something went wrong. Try again.';
  return message;
}

/// Confirmation and alert dialogs with one consistent layout.
abstract final class AppDialogs {
  /// Returns true when the user confirms. [destructive] paints the confirm
  /// button red and should be used for deletes.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Text(message),
          ),
          actions: [
            OutlineButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(cancelLabel),
            ),
            if (destructive)
              DestructiveButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(confirmLabel),
              )
            else
              PrimaryButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(confirmLabel),
              ),
          ],
        );
      },
    );
    return result ?? false;
  }

  /// Shorthand for the common delete confirmation.
  static Future<bool> confirmDelete(
    BuildContext context, {
    required String itemName,
    String? message,
  }) {
    return confirm(
      context,
      title: 'Delete $itemName?',
      message: message ?? "This can't be undone.",
      confirmLabel: 'Delete',
      destructive: true,
    );
  }
}
