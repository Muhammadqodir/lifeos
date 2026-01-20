import 'package:flutter/cupertino.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class DateSelect extends StatefulWidget {
  const DateSelect({super.key, this.onDateChanged});
  final ValueChanged<DateTime>? onDateChanged;

  @override
  State<DateSelect> createState() => _DateSelectState();
}

class _DateSelectState extends State<DateSelect> {
  final TextEditingController _controller = TextEditingController();

  DateTime? _selectedDate;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (selectedDate == today) {
      return 'Today';
    } else if (selectedDate == yesterday) {
      return 'Yesterday';
    } else if (selectedDate == tomorrow) {
      return 'Tomorrow';
    } else {
      // Format as "1 January, 2026"
      return DateFormat('d MMMM, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      readOnly: true,
      style: Theme.of(
        context,
      ).typography.small.copyWith(fontWeight: FontWeight.w500),
      features: [
        InputFeature.clear(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedCancel01,
            size: 18,
            strokeWidth: 2,
          ),
        ),
        InputFeature.leading(
          HugeIcon(
            icon: HugeIcons.strokeRoundedCalendar02,
            size: 18,
            strokeWidth: 2,
          ),
        ),
      ],
      placeholder: Text(
        'Select date',
        style: Theme.of(
          context,
        ).typography.small.copyWith(fontWeight: FontWeight.w500),
      ),
      onTap: () async {
        DateTime tempDate = _selectedDate ?? DateTime.now();
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: DatePickerDialog(
                initialValue: SingleCalendarValue(
                  tempDate,
                ),
                initialViewType: CalendarViewType.date,
                selectionMode: CalendarSelectionMode.single,
                onChanged: (v) {
                  print(v);
                  if (v != null) {
                    tempDate = v.toSingle().date;
                    print(tempDate);
                  }
                },
              ),
              actions: [
                SecondaryButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                PrimaryButton(
                  onPressed: () {
                    setState(() {
                      _selectedDate = tempDate;
                      _controller.text = _formatDate(_selectedDate!);
                    });
                    if (widget.onDateChanged != null) {
                      widget.onDateChanged!(_selectedDate!);
                    }
                    Navigator.of(context).pop();
                                    },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
