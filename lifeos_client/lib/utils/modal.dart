import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class BottomSheetModal {
  static Future<T?> openSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
  }) async {
    T? res = await showBarModalBottomSheet<T>(
      backgroundColor: Theme.of(context).colorScheme.background,
      overlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: Theme.of(context).colorScheme.background,
        systemNavigationBarIconBrightness:
            Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      context: context,
      builder: (sheetContext) {
        return Container(
          padding: EdgeInsets.only(
            top: 24,
            bottom: 24 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: builder(context),
        );
      },
    );

    return res;
  }
}
