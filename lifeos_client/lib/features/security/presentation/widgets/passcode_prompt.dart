import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/ui/ui.dart';

/// Shared layout for passcode screens: visual, title, explanation, an
/// error line that keeps its space, the digit input and optional extras.
class PasscodePrompt extends StatelessWidget {
  const PasscodePrompt({
    super.key,
    required this.visual,
    required this.title,
    required this.message,
    required this.input,
    this.error,
    this.footer,
  });

  final Widget visual;
  final String title;
  final String message;
  final Widget input;
  final String? error;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              visual,
              const SizedBox(height: AppSpacing.xl),
              Text(
                title,
                style: context.theme.typography.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(message, style: text.itemSubtitle, textAlign: TextAlign.center),
              SizedBox(
                height: 32,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: error == null ? 0 : 1,
                    duration: AppDurations.fast,
                    child: Text(
                      error ?? '',
                      style: text.label.copyWith(
                        color: context.colors.destructive,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              input,
              if (footer != null) ...[
                const SizedBox(height: AppSpacing.xxl),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
