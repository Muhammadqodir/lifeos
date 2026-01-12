import 'package:shadcn_flutter/shadcn_flutter.dart';

class Dialogs {
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            SecondaryButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            PrimaryButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // Close the dialog
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
