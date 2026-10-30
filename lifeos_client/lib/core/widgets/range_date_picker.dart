import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../ui/app_theme_x.dart';
import '../ui/tokens.dart';

class RangeDatePicker extends StatefulWidget {
  final DateTime dateFrom;
  final DateTime dateTo;
  final Function(DateTime, DateTime) onDateRangeChanged;

  const RangeDatePicker({
    super.key,
    required this.dateFrom,
    required this.dateTo,
    required this.onDateRangeChanged,
  });

  @override
  State<RangeDatePicker> createState() => _RangeDatePickerState();
}

class _RangeDatePickerState extends State<RangeDatePicker> {
  late DateTime _dateFrom;
  late DateTime _dateTo;
  DateTimeRange? _value;

  @override
  void initState() {
    super.initState();
    _dateFrom = widget.dateFrom;
    _dateTo = widget.dateTo;
    _value = DateTimeRange(_dateFrom, _dateTo);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Period', style: context.text.label),
        const SizedBox(height: AppSpacing.sm - 2),
        SizedBox(
          width: double.infinity,
          child: DateRangePicker(
            value: _value,
            mode: PromptMode.dialog,
            dialogTitle: const Text('Choose period'),
            onChanged: (value) {
              setState(() {
                _value = value;
                if (value != null) {
                  _dateFrom = value.start;
                  _dateTo = value.end;
                }
              });
              if (value != null) {
                widget.onDateRangeChanged(_dateFrom, _dateTo);
              }
            },
          ),
        ),
      ],
    );
  }
}
