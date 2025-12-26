import 'package:flutter/widgets.dart';
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
        trailing: PrimaryButton(
          size: ButtonSize.small,
          onPressed: () {
            // Close the toast programmatically when clicking Undo.
            overlay.close();
          },
          child: const Text('Undo'),
        ),
        trailingAlignment: Alignment.center,
      ),
    );
  }
}
