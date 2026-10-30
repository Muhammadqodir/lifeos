import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../core/ui/app_theme_x.dart';
import '../core/ui/components/app_feedback.dart';

/// Legacy toast builder. New code should call [AppToast] directly; this
/// stays so any remaining call sites still get the unified look, with the
/// icon chosen from the title.
class Utils {
  static Widget buildToast(
    BuildContext context,
    ToastOverlay overlay,
    String title,
    String message,
  ) {
    final lower = title.toLowerCase();
    final isError = lower.contains('error') || lower.contains('fail');
    final isSuccess =
        !isError &&
        (lower.contains('success') ||
            lower.contains('deleted') ||
            lower.contains('created') ||
            lower.contains('saved'));
    final semantic = context.semantic;
    final (icon, color) = isError
        ? (HugeIcons.strokeRoundedAlertCircle, context.colors.destructive)
        : isSuccess
        ? (HugeIcons.strokeRoundedCheckmarkCircle02, semantic.success)
        : (HugeIcons.strokeRoundedInformationCircle, semantic.info);
    return SurfaceCard(
      child: Basic(
        title: Text(title),
        subtitle: Text(isError ? friendlyErrorMessage(message) : message),
        leading: HugeIcon(icon: icon, size: 20, color: color),
        trailingAlignment: Alignment.center,
      ),
    );
  }
}
