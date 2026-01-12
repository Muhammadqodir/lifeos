import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class BottomSheetModal {
  static Future<T?> openSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
  }) async {
    final originalStyle = SystemChrome.latestStyle;
    
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    T? res = await showBarModalBottomSheet<T>(
      context: context,
      builder: (sheetContext) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                top: 24,
                bottom: 24 + MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: builder(sheetContext),
            ),
          ),
        );
      },
    );

    // Restore original style
    if (originalStyle != null) {
      SystemChrome.setSystemUIOverlayStyle(originalStyle);
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      );
    }
    
    return res;
  }
}
