import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../core/ui/components/app_feedback.dart';

/// Kept for existing call sites; delegates to [AppDialogs].
class Dialogs {
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    bool destructive = false,
  }) {
    return AppDialogs.confirm(
      context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      destructive: destructive,
    );
  }
}
