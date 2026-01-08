import 'package:shadcn_flutter/shadcn_flutter.dart';

class LoadingState extends StatelessWidget {
  final String message;

  const LoadingState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(size: 28),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.typography.small.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
