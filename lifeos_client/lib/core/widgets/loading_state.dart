import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../ui/app_theme_x.dart';
import '../ui/tokens.dart';

/// Centered spinner with a short status line.
class LoadingState extends StatelessWidget {
  final String message;

  const LoadingState({super.key, this.message = 'Loading…'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(size: 24),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: context.text.itemSubtitle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
