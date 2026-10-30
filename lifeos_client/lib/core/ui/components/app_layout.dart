import 'dart:math' as math;

import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../app_theme_x.dart';
import '../tokens.dart';

/// Centers page content and caps its width so lists and forms stay
/// readable in wide iPad and Mac windows.
class ContentWidth extends StatelessWidget {
  const ContentWidth({
    super.key,
    required this.child,
    this.maxWidth = AppLayout.maxContentWidth,
  });

  const ContentWidth.wide({super.key, required this.child})
    : maxWidth = AppLayout.maxWideContentWidth;

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // A tight width keeps stretch layouts full-width up to the cap.
        final width = constraints.hasBoundedWidth
            ? math.min(constraints.maxWidth, maxWidth)
            : maxWidth;
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: width, child: child),
        );
      },
    );
  }
}

/// Sliver equivalent of [ContentWidth]: pads the sliver horizontally so its
/// content never exceeds [maxWidth] and keeps the page gutter on phones.
class SliverContentWidth extends StatelessWidget {
  const SliverContentWidth({
    super.key,
    required this.sliver,
    this.maxWidth = AppLayout.maxContentWidth,
    this.vertical = EdgeInsets.zero,
  });

  final Widget sliver;
  final double maxWidth;
  final EdgeInsets vertical;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final side = width > maxWidth + AppSpacing.page * 2
            ? (width - maxWidth) / 2
            : AppSpacing.page;
        return SliverPadding(
          padding: EdgeInsets.only(
            left: side,
            right: side,
            top: vertical.top,
            bottom: vertical.bottom,
          ),
          sliver: sliver,
        );
      },
    );
  }
}

/// Labelled form control: label, control, optional helper text.
class AppFormField extends StatelessWidget {
  const AppFormField({
    super.key,
    required this.label,
    required this.child,
    this.hint,
    this.optional = false,
  });

  final String label;
  final Widget child;
  final String? hint;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              text: label,
              children: [
                if (optional) TextSpan(text: '  Optional', style: text.caption),
              ],
            ),
            style: text.label,
          ),
          const SizedBox(height: AppSpacing.sm - 2),
          child,
          if (hint != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(hint!, style: text.caption),
          ],
        ],
      ),
    );
  }
}

/// Full-width primary button pinned to the bottom of a form.
class FormSubmitButton extends StatelessWidget {
  const FormSubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.loadingLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(loadingLabel ?? label),
                ],
              )
            : Text(label),
      ),
    );
  }
}
