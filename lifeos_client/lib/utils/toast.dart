import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class Utils {
  static Widget buildToast(
    BuildContext context,
    ToastOverlay overlay,
    String title,
    String message,
  ) {
    return SurfaceCard(
      child: Basic(
        title: Text(title),
        subtitle: Text(message),
        leading: HugeIcon(
          icon: HugeIcons.strokeRoundedInformationCircle,
          size: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
        trailingAlignment: Alignment.center,
      ),
    );
  }
}
