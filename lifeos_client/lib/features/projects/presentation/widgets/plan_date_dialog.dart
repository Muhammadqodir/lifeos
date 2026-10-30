import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Asks for a planned date. Returns null when cancelled.
Future<DateTime?> pickPlannedDate(BuildContext context) {
  final now = DateTime.now();
  DateTime selected = DateTime(now.year, now.month, now.day);
  return showDialog<DateTime>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Plan for'),
        content: DatePickerDialog(
          initialValue: SingleCalendarValue(selected),
          initialViewType: CalendarViewType.date,
          selectionMode: CalendarSelectionMode.single,
          onChanged: (value) {
            if (value != null) selected = value.toSingle().date;
          },
        ),
        actions: [
          OutlineButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            onPressed: () => Navigator.of(dialogContext).pop(selected),
            child: const Text('Plan'),
          ),
        ],
      );
    },
  );
}
