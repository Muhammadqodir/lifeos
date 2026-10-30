import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../ui/app_theme_x.dart';
import '../ui/components/app_feedback.dart';
import 'empty_state.dart';

/// Full-area error with a retry button. Raw exception text is translated
/// into a readable message.
class ErrorState extends StatelessWidget {
  final String message;
  final String title;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.title = 'Something went wrong',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: title,
      description: friendlyErrorMessage(message),
      color: context.colors.destructive,
      icon: const HugeIcon(icon: HugeIcons.strokeRoundedAlert02),
      action: onRetry == null
          ? null
          : OutlineButton(
              onPressed: onRetry,
              leading: const HugeIcon(
                icon: HugeIcons.strokeRoundedRefresh,
                size: 16,
              ),
              child: const Text('Try again'),
            ),
    );
  }
}
